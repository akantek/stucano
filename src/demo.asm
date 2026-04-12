PLAYER_Y_MIN:   equ 24

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

.game_loop:
  call wait_vsync        ; Spin until vblank is fired
.vblank_trace_start:
  call loadSpriteAttributes
  call flip_page
.vblank_trace_end:
  ; Move player
  call move_player
  call handle_scroll_input
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

