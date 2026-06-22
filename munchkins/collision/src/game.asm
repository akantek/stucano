PLAYER_X: equ 120
PLAYER_Y: equ 180
SPRITE_X: equ 20
SPRITE_Y: equ 20
NUM_SPRITES: equ 12     ; Changed to 2 (11 active sprite + 1 terminator)

collision_demo:
  ; Setup
  di
  call loadSpritePatterns
  call loadSpriteColors
  call initSpriteAttributes
  call loadSpriteAttributes

  ; --- NEW: Initialize Hitbox Dimensions ---
  ; Set the static dimensions (Width and Height) of both hitboxes to 8x8 pixels
  ld a, 8
  ld (player_hitbox + HB_H), a
  ld (player_hitbox + HB_W), a
  ld (enemy_hitbox + HB_H), a
  ld (enemy_hitbox + HB_W), a
  ; -----------------------------------------

  call ENASCR
  ei

.loop:
  call wait_vsync        ; Spin until vblank is fired
.vblank_trace_start:
  ; >>>>>>> Change VRAM here <<<<<<<
  ld a, NUM_SPRITES              ; Load 1 sprite (sprite0)
  call loadSpriteAttributes
.vblank_trace_end:
  ; Starting here, no more VRAM changes

  call animate_sprite0         ; Run our new animation logic first
  call update_player_movement  

; ==========================================
  ; --- 0. UPDATE HITBOX COORDINATES ---
  ; Update enemy_hitbox (Y, X) with current sprite0 coordinates
  ld a, (sprite0_y)
  ld (enemy_hitbox + HB_Y), a
  ld a, (sprite0_x)
  ld (enemy_hitbox + HB_X), a

  ; Sync player hitbox to sprite, shifting X by +4 to center the 8px collision core
  ld a, (sprite1_y)
  ld (player_hitbox + HB_Y), a
  ld a, (sprite1_x)
  add a, 4     ; <--- Shift the hitbox 4 pixels to the right
  ld (player_hitbox + HB_X), a

  ; --- 1. SET UP THE POINTERS ---
  ld ix, player_hitbox      ; Point IX to the updated Player RAM struct
  ld iy, enemy_hitbox       ; Point IY to the updated Enemy RAM struct

  ; --- 2. EXECUTE THE CHECK ---
  call check_collision_generic

  ; --- 3. HANDLE THE RESULT ---
  jr nc, .skip_hit_logic    ; If No Carry (missed), jump over the hit logic

  ; >> If we get here, a collision happened! <<
  call BEEP                 ; Play a sound
; ==========================================

.skip_hit_logic:
  ; frame_count++
  ld a, (frame_count)
  inc a
  ld (frame_count), a

  ; if (frame_count != 59) then jump to the end
  cp 59
  jr nz, .skip_beep

  ; else
  ; call BEEP
  xor a
  ld (frame_count), a

.skip_beep:
  jr .loop


initSpriteAttributes:
  ; 1. Copy the initial data into the RAM Shadow Buffer
  ld hl, init_sprite_attributes
  ld de, shadow_sat
  ld bc, NUM_SPRITES * 4
  ldir

  ; 2. Send it to VDP
  ld hl, shadow_sat
  ld a, SPRITE_VRAM_BANK
  ld de, VRAM_SPR_ATTRIBS
  ld bc, NUM_SPRITES * 4
  call write_vram_fast
  ret

init_sprite_attributes:
  ; Enemy, Pattern 0
  db SPRITE_Y, SPRITE_X, 0, 0

  ; Player left
  db PLAYER_Y, PLAYER_X, 3, 0

  ; Player right
  db PLAYER_Y, PLAYER_X + 8, 4, 0

  ; Player's fire
  db $D8, PLAYER_X + 8, 2, 0 

  ; Sprite 2: The Terminator
  ; Setting Y to $D8 (216) hides this sprite AND aborts rendering for Sprites 2-31
  db $D8, 0, 0, 0

loadSpritePatterns:
  ld HL, sprite_patterns_start
  ld DE, VRAM_SPR_PATTERNS
  ld A, SPRITE_VRAM_BANK
  ld BC, sprite_patterns_end - sprite_patterns_start
  call write_vram_large
  ret

loadSpriteColors:
  ld hl, msx_ufo_colors_start   ; Source RAM
  ld de, VRAM_SPR_COLORS        ; Dest VRAM ($7400)
  ld a, SPRITE_VRAM_BANK        ; Bank 1
  ld c, msx_ufo_colors_end - msx_ufo_colors_start
  call write_vram_fast
  ret

; Screen 5, the VDP uses Sprite Mode 2. In Sprite Mode 2, the VDP expects 
; exactly 16 bytes of color data per sprite, even if you have 8x8 sprites
; enabled.
msx_ufo_colors_start:
; Sprite 0 (Enemy)
db 15,15,14,14, 14,14,15,15, 0,0,0,0, 0,0,0,0 

; Sprite 1 (Player left)
db 15,15,15,15, 15,15,15,15, 0,0,0,0, 0,0,0,0 

; Sprite 2 (Player right)
db 15,15,15,15, 15,15,15,15, 0,0,0,0, 0,0,0,0

; Sprite 3  ; Player's fire
db  8, 8, 8, 8,  8, 8, 8, 8, 0,0,0,0, 0,0,0,0  

msx_ufo_colors_end:

; ==============================================================================
; Routine:      animate_sprite0
; Description:  Increments the 4th byte (timer) of Sprite 0.
;               At 60 frames: Changes pattern to 1.
;               At 120 frames: Changes pattern to 0, resets timer to 0.
; Destroys:     A, HL
; ==============================================================================
animate_sprite0:
  ld hl, sprite0_timer       ; HL points to the 4th byte of Sprite 0 ($C023)
  ld a, (hl)                 ; Load the current timer value into A
  inc a                      ; Increment the timer by 1
  ld (hl), a                 ; Store the updated timer back into RAM

  cp 60                      ; Has the timer reached exactly 60?
  jr z, .set_frame_1         ; If yes, jump to set the second pattern
  
  cp 120                     ; Has the timer reached exactly 120?
  jr z, .reset_to_frame_0    ; If yes, jump to reset timer and pattern
  
  ret                        ; Otherwise, return and do nothing this frame

.set_frame_1:
  ld a, 1                    ; Pattern Index 1 (Robot Frame B)
  ld (sprite0_pat), a        ; Update the shadow RAM pattern byte
  ret

.reset_to_frame_0:
  xor a                      ; Fast way to set A = 0
  ld (sprite0_pat), a        ; Reset shadow RAM pattern back to 0 (Robot Frame A)
  ld (hl), a                 ; Reset the timer back to 0 (HL still points to sprite0_timer)
  ret

; ==============================================================================
; Routine:      update_player_movement
; Description:  Reads keyboard and joypad. Updates sprite1 and sprite2 
;               (left and right halves of the player ship) based on input.
; Destroys:     A, C
; ==============================================================================
update_player_movement:
    ; 1. Read Keyboard First
    call scan_keypad
    
    ; 2. Check if ANY tracked keyboard key is pressed
    ld c, a               ; Backup the exact keypad state into C
    cp %11110111          ; Are all tracked bits 1? (Meaning nothing is pressed)
    jr nz, .process_input ; If ANY key is pressed (a bit is 0), skip the joypad check

    ; 3. Keyboard is totally idle, so read the Joypad
    call scan_joypad
    ld c, a               ; Overwrite C with the new joypad state

.process_input:
    ; At this point, C holds the active input (either keyboard or joypad)
    ; Bit 7: Right, Bit 6: Down, Bit 5: Up, Bit 4: Left (0 = pressed)

    ; --- X AXIS (Horizontal) ---
.check_left:
    bit 4, c              ; Check bit 4 (Left)
    jr nz, .check_right   ; If 1 (not pressed), skip to checking Right
    
    ; Move Left (Both Sprite Halves)
    ld a, (sprite1_x)
    dec a
    ld (sprite1_x), a
    
    ld a, (sprite2_x)
    dec a
    ld (sprite2_x), a
    
    jr .check_y_axis      ; Skip right check (can't go left and right simultaneously)

.check_right:
    bit 7, c              ; Check bit 7 (Right)
    jr nz, .check_y_axis  ; If 1 (not pressed), skip to Y axis
    
    ; Move Right (Both Sprite Halves)
    ld a, (sprite1_x)
    inc a
    ld (sprite1_x), a
    
    ld a, (sprite2_x)
    inc a
    ld (sprite2_x), a

    ; --- Y AXIS (Vertical) ---
.check_y_axis:

.check_up:
    bit 5, c              ; Check bit 5 (Up)
    jr nz, .check_down    ; If 1 (not pressed), skip to checking Down
    
    ; Move Up (Both Sprite Halves)
    ld a, (sprite1_y)
    dec a
    ld (sprite1_y), a
    
    ld a, (sprite2_y)
    dec a
    ld (sprite2_y), a
    
    ret                   ; Skip down check and exit

.check_down:
    bit 6, c              ; Check bit 6 (Down)
    ret nz                ; If 1 (not pressed), we are done, so return
    
    ; Move Down (Both Sprite Halves)
    ld a, (sprite1_y)
    inc a
    ld (sprite1_y), a
    
    ld a, (sprite2_y)
    inc a
    ld (sprite2_y), a
    
    ret

