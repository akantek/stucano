SPRITE_X: equ 20
SPRITE_Y: equ 20
NUM_SPRITES: equ 2     ; Changed to 2 (1 active sprite + 1 terminator)

simple_sprite_demo:
  ; Setup
  di
  call loadSpritePatterns
  call loadSpriteColors
  call initSpriteAttributes
  call loadSpriteAttributes
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

  ; frame_count++
  ld a, (frame_count)
  inc a
  ld (frame_count), a

  ; if (frame_count != 59) then jump to the end
  cp 59
  jr nz, .skip_beep

  ; else
  call BEEP
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
  ; Sprite 0: Right Facing - Layer 1 (White)
  ; Y ($60=96), X ($70=112), Pattern 0
  db SPRITE_Y, SPRITE_X, 0, 0

  ; Sprite 1: The Terminator
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

msx_ufo_colors_start:
; Sprite 0
db 15,15,14,14, 14,14,15,15
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
; Description:  Reads keyboard. If no direction or action key is pressed, 
;               reads joypad. Updates sprite0 based on input.
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
    
    ; Move Left
    ld a, (sprite0_x)
    dec a
    ld (sprite0_x), a
    jr .check_y_axis      ; Skip right check (can't go left and right simultaneously)

.check_right:
    bit 7, c              ; Check bit 7 (Right)
    jr nz, .check_y_axis  ; If 1 (not pressed), skip to Y axis
    
    ; Move Right
    ld a, (sprite0_x)
    inc a
    ld (sprite0_x), a

    ; --- Y AXIS (Vertical) ---
.check_y_axis:

.check_up:
    bit 5, c              ; Check bit 5 (Up)
    jr nz, .check_down    ; If 1 (not pressed), skip to checking Down
    
    ; Move Up
    ld a, (sprite0_y)
    dec a
    ld (sprite0_y), a
    ret                   ; Skip down check and exit

.check_down:
    bit 6, c              ; Check bit 6 (Down)
    ret nz                ; If 1 (not pressed), we are done, so return
    
    ; Move Down
    ld a, (sprite0_y)
    inc a
    ld (sprite0_y), a
    ret


