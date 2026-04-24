
demo:
  ; Init
  di

  ; Clear VRAM page 0
  ld a, 0
  call clear_vram_page
  call wait_vdp_ready
  ; Clear VRAM page 1
  ld a, 1
  call clear_vram_page
  call wait_vdp_ready

  ; Initialize vars
  ld hl, player_anim_frame_counter
  ld (hl), 4

  ; Draw stars
  ld c, 0                 ; Target Page 0
  ld hl, stars_array0
  call draw_stars

  ld c, 1                 ; Target Page 1
  ld hl, stars_array0
  call draw_stars    

  ; Init sprites
  call initSpriteAttributes

  ; Draw playfield on both pages 0 and 1
  call drawPlayfield

  ; load palette
  ld HL, stucano_palette
  call loadPalette

  call setUpHorizontalScroll

  call ENASCR
  ei

  ; Start page flipping
  ld hl, page_ready_flip
  ld (hl), 1

  call start_helicopter_fx

  ; Position player
  ld hl, player_x
  ld (hl), 30
  ld hl, player_y
  ld (hl), 100

.game_loop:
  call wait_vsync        ; Spin until vblank is fired
.vblank_trace_start:
  call loadSpriteAttributes
  call flip_page
.vblank_trace_end:
  ; Move player
  call move_player
  call check_background_collision
  jr c, player_died      ; C flag is set! The player hit the terrain!

  call update_auto_scroll
  call animatePlayerSprite
  
  ; Move MSX helicopters
  call moveMsxHelicopters
  call updateMsxHeliSpritePattern

  call handleMissleSpawn

  ; Update SAT with player and enemies location
  call update_player_sat

  ; --- Two-Frame Star Twinkle Sync ---
  ld a, (frame_count)     
  inc a                   
  ld (frame_count), a     
  
  cp 59                   ; Is it Frame 60?
  jr z, .sync_frame_1
  
  cp 60                   ; Is it Frame 61?
  jr z, .sync_frame_2
  
  jr .skip_stars          ; Otherwise, do nothing

.sync_frame_1:
  ; Step 1: Flip the global state and update the first hidden page
  ld a, (stars_flag)
  xor 1
  ld (stars_flag), a
  call update_hidden_stars
  jr .skip_stars

.sync_frame_2:
  ; Step 2: The pages have swapped! Update the OTHER hidden page.
  call update_hidden_stars

  ; Reset the timer for the next second
  xor a
  ld (frame_count), a

.skip_stars:
  jr .game_loop


player_died:
  ld HL, player_x
  ld (HL), 20
  ld HL, player_y
  ld (HL), 100
  jr .game_loop

PLAYER_Y_MIN:   equ 24
MAP_WIDTH: EQU 128
SCREEN_TILES_X: EQU 32

; Playfield Map Data (128 tiles wide x 3 rows tall)
playfield_map:
  ; Row 1 (Y=192) - 128 tiles (_8s)
  db _8,_8,_0,_A,_A,_A,_A,_A,_A,_A,_A,_A,_A,_A,_A,_4,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8
  db _8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8
  db _8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8
  db _8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8,_8

  ; Row 2 (Y=200) - 128 tiles (_Es)
  db _E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E
  db _E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E
  db _E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E
  db _E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E

  ; Row 3 (Y=208) - 128 tiles (_Es)
  db _E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E
  db _E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E
  db _E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E
  db _E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E,_E

