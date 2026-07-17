INIT_NUM_SPRITES:    equ 5
PLAYER_Y_MIN:   equ 24

player_fire_demo:
  di
  call loadSpritePatterns
  call loadSpriteColors
  call initSpriteAttributes

  ; Initialize starting coordinates
  ld a, 120
  ld (player_x), a
  ld (player_y), a

  ; Pre-configure Bullet Sprites & State
  ld a, 7
  ld (active_sprites), a     ; Always draw 7 sprites (5 player + 2 bullets)

  xor a
  ld (fire1_active), a
  ld (fire2_active), a
  ld (space_was_pressed), a
  ld (cooldown_timer), a     ; Initialize cooldown to 0

  ; Sprite 4 (Bullet 1)
  ld a, 48
  ld (sprite4_pat), a
  ld a, 10
  ld (sprite4_timer), a      
  ld a, 217                  ; Hide cleanly offscreen
  ld (sprite4_y), a

  ; Sprite 5 (Bullet 2)
  ld a, 48
  ld (sprite5_pat), a
  ld a, 10
  ld (sprite5_timer), a
  ld a, 217
  ld (sprite5_y), a

  ; Sprite 6 (Terminator)
  ld a, $D8
  ld (sprite6_y), a          ; Lock the terminator to Sprite 6
  ei

.main_loop:
  call wait_vsync
.vblank_trace_start:
  ld a, (active_sprites)
  call loadSpriteAttributes
.vblank_trace_end:

  ; --- PROCESS GLOBAL COOLDOWN ---
  ld a, (cooldown_timer)
  or a
  jr z, .scan_input          ; If 0, skip decrement
  dec a
  ld (cooldown_timer), a

.scan_input:
  call scan_keypad
  ld c, a

  ; --- X AXIS (Horizontal) ---
.check_left:
  bit 4, c
  jr nz, .check_right

  ld a, (player_x)
  dec a
  ld (player_x), a
  jr .check_y_axis

.check_right:
  bit 7, c
  jr nz, .check_y_axis

  ld a, (player_x)
  inc a
  ld (player_x), a

.check_y_axis:
.check_up:
  bit 5, c
  jr nz, .check_down

  ld a, (player_y)
  dec a
  ld (player_y), a
  jr .check_space

.check_down:
  bit 6, c
  jr nz, .check_space

  ld a, (player_y)
  inc a
  ld (player_y), a

.check_space:
  bit 0, c
  jr nz, .space_released

  ; Space IS pressed. Check debounce.
  ld a, (space_was_pressed)
  or a
  jr nz, .update_bullets     ; Already pressed, wait for the player to release the key

  ; Check if the 7-frame cooldown is active
  ld a, (cooldown_timer)
  or a
  jr nz, .update_bullets     ; Can't fire yet, cooldown active

  ; We want to fire. Set debounce flag and cooldown timer.
  ld a, 1
  ld (space_was_pressed), a
  ld a, 7
  ld (cooldown_timer), a

  ; Find an available bullet slot
  ld a, (fire1_active)
  or a
  jr z, .use_slot_1

  ld a, (fire2_active)
  or a
  jr z, .use_slot_2

  ; If we get here, both bullets are currently on screen. Do nothing.
  jr .update_bullets

.space_released:
  xor a
  ld (space_was_pressed), a  ; Clear debounce flag so the player can fire again
  jr .update_bullets

.use_slot_1:
  ld a, 1
  ld (fire1_active), a
  ld a, (player_x)
  add a, 25
  ld (fire1_x), a
  ld a, (player_y)
  add a, 8
  ld (fire1_y), a
  jr .update_bullets

.use_slot_2:
  ld a, 1
  ld (fire2_active), a
  ld a, (player_x)
  add a, 25
  ld (fire2_x), a
  ld a, (player_y)
  add a, 8
  ld (fire2_y), a
  ; Falls through to .update_bullets

.update_bullets:
  ; --- Update Bullet 1 ---
  ld a, (fire1_active)
  or a
  jr z, .check_bullet2

  ld a, (fire1_x)
  add a, 6
  ld (fire1_x), a
  cp 217
  jr nc, .despawn_b1

  ld (sprite4_x), a
  ld a, (fire1_y)
  ld (sprite4_y), a
  jr .check_bullet2

.despawn_b1:
  xor a
  ld (fire1_active), a
  ld a, 217                  ; Park it safely offscreen
  ld (sprite4_y), a

.check_bullet2:
  ; --- Update Bullet 2 ---
  ld a, (fire2_active)
  or a
  jr z, .end_keypad

  ld a, (fire2_x)
  add a, 6
  ld (fire2_x), a
  cp 217
  jr nc, .despawn_b2

  ld (sprite5_x), a
  ld a, (fire2_y)
  ld (sprite5_y), a
  jr .end_keypad

.despawn_b2:
  xor a
  ld (fire2_active), a
  ld a, 217
  ld (sprite5_y), a

.end_keypad:
  call update_player_sprites
  jp .main_loop


update_player_sprites:
  ; --- Update Y Coordinates ---
  ld a, (player_y)
  ld (sprite0_y), a   ; Layer 1 (Left)
  ld (sprite1_y), a   ; Layer 2 (Left overlay)
  ld (sprite2_y), a   ; Layer 1 (Right)
  ld (sprite3_y), a   ; Layer 2 (Right overlay)

  ; --- Update X Coordinates ---
  ld a, (player_x)
  ld (sprite0_x), a   ; Layer 1 (Left)
  ld (sprite1_x), a   ; Layer 2 (Left overlay)

  add a, 16           ; Shift 16 pixels right for the second half
  ld (sprite2_x), a   ; Layer 1 (Right)
  ld (sprite3_x), a   ; Layer 2 (Right overlay)
  ret

loadSpritePatterns:
  ld HL, sprite_patterns_start
  ld DE, VRAM_SPR_PATTERNS
  ld A, SPRITE_VRAM_BANK
  ld BC, sprite_patterns_end - sprite_patterns_start
  call write_vram_large
  ret

loadSpriteColors:
; --- Load colors for Sprites 0 through 5 ---
  ld hl, player_helicopter_colors_start   ; Source RAM
  ld de, VRAM_SPR_COLORS                  ; Dest VRAM ($7400)
  ld a, SPRITE_VRAM_BANK                  ; Bank 1
  ld c, player_helicopter_colors_end - player_helicopter_colors_start ; Now 96 bytes
  call write_vram_fast
  ret

initSpriteAttributes:
  ; 1. Copy the initial data into the RAM Shadow Buffer
  ld hl, init_sprite_attributes
  ld de, shadow_sat
  ld bc, INIT_NUM_SPRITES * 4
  ldir

  ; 2. Send it to VDP
  ld hl, shadow_sat
  ld a, SPRITE_VRAM_BANK
  ld de, VRAM_SPR_ATTRIBS
  ld bc, INIT_NUM_SPRITES * 4
  call write_vram_fast
  ret

sprite_color_data_start:
player_helicopter_colors_start:
; Sprite 0
db 12,12,12,12, 8,8,8,8, 8,8,8,8, 8,8,8,8
; Sprite 1
db $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44
; Sprite 2
db 8,8,8,8, 8,8,8,8, 8,8,8,8, 8,8,8,8
; Sprite 3
db $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44
; Sprite 4 (Bullet 1 - Color 10, CC=0)
db 10,10,10,10, 10,10,10,10, 10,10,10,10, 10,10,10,10
; Sprite 5 (Bullet 2 - Color 10, CC=0)
db 10,10,10,10, 10,10,10,10, 10,10,10,10, 10,10,10,10
player_helicopter_colors_end:
sprite_color_data_end:

init_sprite_attributes:
  ; Sprite 0: Right Facing - Layer 1 (White)
  ; Y ($60=96), X ($70=112), Pattern 0
  db 10, 10, 0, 0

  ; Sprite 1: Right Facing - Layer 2 (Red)
  ; Same X,Y as above to overlay them
  ;
  ; [!] MSX2 Sprite Mode 2 requires this overlay sprite to have the EXACT 
  ; same Y coordinate as Sprite 0 above it because the CC (Color Combine) 
  ; bit is set in its color table. If Y differs, it will be invisible. 
  db 10, 10, 4, 0 

  ; Sprite 2: Left Facing - Layer 1 (White)
  ; Y ($60=96), X ($90=144), Pattern 8
  db 10, 26, 8, 0

  ; Sprite 3: Left Facing - Layer 2 (Red)
  ; Same X,Y as above to overlay them
  db 10, 26, 12, 0

  ; End sprite
  db $D8, 0, 0, 0
  ret
