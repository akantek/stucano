;------------------------------------------------------------------------------
; Scans MSX Joystick Port 1 via direct PSG hardware access.
; Returns the exact same bitmask as the keyboard routine.
; Output: A = 8-bit key state. 0 = pressed, 1 = not pressed.
;------------------------------------------------------------------------------
scan_joypad:
    ; 1. Set PSG to read Joystick Port 1
    di                    ; CRITICAL: Disable interrupts during PSG access
    ld a, 15              ; PSG Register 15 (Joystick config)
    out ($A0), a          ; Send register index to PSG address port
    in a, ($A2)           ; Read current Register 15 state
    and %10111111         ; Clear bit 6 to select Joystick Port 1
    out ($A1), a          ; Write it back to PSG data port

    ; 2. Read the joystick state
    ld a, 14              ; PSG Register 14 (Joystick data)
    out ($A0), a          ; Send register index
    in a, ($A2)           ; Read joystick state into A
    ei                    ; Re-enable interrupts
    
    ; Raw PSG A format: [xx | Trig B | Trig A | Right | Left | Down | Up] (0 = pressed)
    
    ld c, a               ; Backup raw state into C
    ld a, $FF             ; Initialize A to %11111111 (Nothing pressed)

    ; 3. Map Directions
    bit 0, c              ; Check Up
    jr nz, .skip_up
    res 5, a              ; Set KEY_UP_BIT
.skip_up:
    bit 1, c              ; Check Down
    jr nz, .skip_down
    res 6, a              ; Set KEY_DOWN_BIT
.skip_down:
    bit 2, c              ; Check Left
    jr nz, .skip_left
    res 4, a              ; Set KEY_LEFT_BIT
.skip_left:
    bit 3, c              ; Check Right
    jr nz, .skip_right
    res 7, a              ; Set KEY_RIGHT_BIT
.skip_right:

    ; 4. Map Triggers
    bit 4, c              ; Check Trigger A
    jr nz, .skip_ta
    res 0, a              ; Set KEY_SPACE_BIT
    res 2, a              ; Set KEY_CTRL_BIT
.skip_ta:
    bit 5, c              ; Check Trigger B
    jr nz, .done_joypad
    res 1, a              ; Set KEY_SHIFT_BIT
.done_joypad:
    ret

