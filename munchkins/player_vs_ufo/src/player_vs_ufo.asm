INIT_NUM_SPRITES:    equ 8
PLAYER_Y_MIN:   equ 24

player_vs_ufo:
  di
  call loadSpritePatterns
  call loadSpriteColors
  call initSpriteAttributes

  ; Initialize starting coordinates
  ld a, 120
  ld (player_x), a
  ld (player_y), a

  ; Initialize UFO logical state ---
  ld a, 200
  ld (ufo_x), a
  ld a, 100
  ld (ufo_y), a

  ; Pre-configure Bullet Sprites & State
  ld a, 8
  ld (active_sprites), a     ; Always draw 8 sprites (5 player + 2 bullets + 1 ufo)

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
  ld (sprite7_y), a          ; Lock the terminator to Sprite 6
  ei

.main_loop:
  call wait_vsync
.vblank_trace_start:
  ld a, (active_sprites)
  call loadSpriteAttributes
.vblank_trace_end:

; --- ANIMATION LOGIC ---
  ld a, (ufo_state)
  or a
  jr z, .no_explosion    ; If state is 0, keep UFO alive/normal
  
  ; We are exploding!
  ld a, 84              ; Set UFO to the Explosion pattern index
  ld (sprite6_pat), a    ; (Ensure index 120 matches your sprite sheet!)
  
  ld a, (ufo_anim_timer)
  dec a
  ld (ufo_anim_timer), a
  jr nz, .no_explosion   ; Keep exploding
  
  ; Explosion finished: hide UFO
  xor a
  ld (ufo_state), a      ; Reset state
  
  ld a, 217
  ld (ufo_y), a          ; --- NEW: Hide the logical hitbox ---
  ld (sprite6_y), a      ; Move UFO off-screen

.no_explosion:
  ld a, (ufo_x)
  ld (sprite6_x), a
  ld a, (ufo_y)
  ld (sprite6_y), a

  call .update_hitboxes

.perform_collisions:
  ; Check Bullet 1
  ld a, (fire1_active)
  or a
  jr z, .check_b2 
  ld ix, fire1_hitbox
  ld iy, ufo_hitbox
  call check_collision_generic
  jr nc, .check_b2

  ; HIT DETECTED for B1!
; Trigger state change instead of immediate despawn:
  ld a, 1
  ld (ufo_state), a      ; Set state to "Exploding"
  ld a, 10               ; Set animation duration (e.g., 10 frames)
  ld (ufo_anim_timer), a

  xor a
  ld (fire1_active), a
  ld a, 217
  ld (sprite4_y), a


.check_b2:
  ; Check Bullet 2
  ld a, (fire2_active)
  or a
  jr z, .end_collision_checks
  ld ix, fire2_hitbox
  ld iy, ufo_hitbox
  call check_collision_generic
  jr nc, .end_collision_checks

  ; HIT DETECTED for B2!
  ld a, 1
  ld (ufo_state), a      ; Set state to "Exploding"
  ld a, 10               ; Set animation duration (e.g., 10 frames)
  ld (ufo_anim_timer), a

  xor a
  ld (fire2_active), a
  ld a, 217
  ld (sprite5_y), a

.end_collision_checks:


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
  ld hl, player_x    ; Point HL to player_x once
.check_left:
  bit 4, c
  jr nz, .check_right
  dec (hl)           ; Modifies RAM directly
  jr .check_y_axis

.check_right:
  bit 7, c
  jr nz, .check_y_axis
  inc (hl)           ; Modifies RAM directly

.check_y_axis:
  ld hl, player_y    ; Shift pointer to player_y
.check_up:
  bit 5, c
  jr nz, .check_down
  dec (hl)
  jr .check_space

.check_down:
  bit 6, c
  jr nz, .check_space
  inc (hl)


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
  ld a, (player_x)
  add a, 25
  jr c, .update_bullets      ; BUG FIX: If math overflowed past 255, abort spawn!
  
  ld (fire1_x), a            ; It's safe! Store X coordinate
  ld a, 1
  ld (fire1_active), a       ; Activate the bullet
  ld a, (player_y)
  add a, 8
  ld (fire1_y), a
  jr .update_bullets

.use_slot_2:
  ld a, (fire2_active)    ; Ensure we check if bullet 2 is actually free
  or a
  jr nz, .update_bullets  ; If active, skip
  
  ld a, 1
  ld (fire2_active), a
  ld a, (player_x)
  add a, 25
  ld (fire2_x), a
  ld a, (player_y)
  add a, 8
  ld (fire2_y), a
  jr .update_bullets

.update_bullets:
  ; --- Update Bullet 1 ---
  ld a, (fire1_active)
  or a
  jr z, .check_bullet2

  ld a, (fire1_x)
  add a, 6
  ld (fire1_x), a
  ; cp 217
  cp 248
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
  ; cp 217
  cp 248
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


.update_hitboxes:
  ; --- Update UFO Hitbox ---
  ld a, (ufo_y)
  ld (ufo_hitbox + HB_Y), a
  ld a, (ufo_x)
  ld (ufo_hitbox + HB_X), a
  ld a, 14               ; Set height/width (14x14)
  ld (ufo_hitbox + HB_H), a
  ld (ufo_hitbox + HB_W), a

  ; --- Update Bullet 1 Hitbox ---
  ld a, (fire1_y)
  ld (fire1_hitbox + HB_Y), a
  ld a, (fire1_x)
  ld (fire1_hitbox + HB_X), a
  ld a, 4                ; Bullet is 4x4
  ld (fire1_hitbox + HB_H), a
  ld (fire1_hitbox + HB_W), a
  
  ; --- Update Bullet 2 Hitbox ---
  ld a, (fire2_y)
  ld (fire2_hitbox + HB_Y), a
  ld a, (fire2_x)
  ld (fire2_hitbox + HB_X), a
  ld a, 4                ; Bullet is 4x4
  ld (fire2_hitbox + HB_H), a
  ld (fire2_hitbox + HB_W), a  
  ret


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
  ld hl, player_vs_ufo_colors_start       ; Source RAM
  ld de, VRAM_SPR_COLORS                  ; Dest VRAM ($7400)
  ld a, SPRITE_VRAM_BANK                  ; Bank 1
  ld c, player_vs_ufo_colors_end - player_vs_ufo_colors_start
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
player_vs_ufo_colors_start:
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
; Sprite 6 (UFO)
db 4,4,4,4, 4,4,4,4, 4,4,4,4, 4,4,4,4
player_vs_ufo_colors_end:
sprite_color_data_end:

init_sprite_attributes:
  ; Sprite 0: Right Facing - Layer 1 (White)
  db 10, 10, 0, 0

  ; Sprite 1: Right Facing - Layer 2 (Red)
  db 10, 10, 4, 0 

  ; Sprite 2: Left Facing - Layer 1 (White)
  db 10, 26, 8, 0

  ; Sprite 3: Left Facing - Layer 2 (Red)
  db 10, 26, 12, 0

  ; Sprite 4: Bullet 1 (Safely hidden off-screen using 217, NOT 216!)
  db 217, 0, 0, 0

  ; Sprite 5: Bullet 2 (Safely hidden off-screen)
  db 217, 0, 0, 0

  ; Sprite 6: UFO (Pattern updated to 80)
  db 100, 200, 80, 0

  ; End sprite terminator ($D8 = 216)
  db 216, 0, 0, 0
  ret

