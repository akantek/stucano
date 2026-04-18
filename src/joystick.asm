; Raw Joystick Bit definitions (PSG Register 14)
JOY_UP_BIT:      equ 0
JOY_DOWN_BIT:    equ 1
JOY_LEFT_BIT:    equ 2
JOY_RIGHT_BIT:   equ 3
JOY_TRIG_A_BIT:  equ 4
JOY_TRIG_B_BIT:  equ 5

; ==============================================================================
; scan_joystick_1
; Reads the raw state of Joystick Port 1 via the PSG.
; 
; Output: A = raw joystick state (0 = pressed, 1 = not pressed)
;   Bit 7: Unused
;   Bit 6: Unused
;   Bit 5: Trigger B
;   Bit 4: Trigger A
;   Bit 3: Right
;   Bit 2: Left
;   Bit 1: Down
;   Bit 0: Up
;
; Registers modified: A
; ==============================================================================

PSG_DATA_WR   equ $A1   ; Port to write data to PSG
PSG_DATA_RD   equ $A2   ; Port to read data from PSG

internal_scan_joystick_1:
  ; --- 1. Select Joystick Port 1 ---
  ld a, 15
  out (PSG_REG_PORT), a
  in a, (PSG_DATA_RD)   ; Read the current state of Reg 15 (Don't break the Caps LED!)
  and %10111111         ; Clear Bit 6 to select Joystick Port 1 
                        ; (To read Port 2, use 'or %01000000' instead)
  out (PSG_DATA_WR), a  ; Write it back to the PSG

  ; --- 2. Read the Input ---
  ld a, 14
  out (PSG_REG_PORT), a
  in a, (PSG_DATA_RD)   ; Read the joystick state into A
  
  ; Bits 6 and 7 are undefined for the joystick, force them to 1 (not pressed)
  or %11000000          
  ret


; ==============================================================================
; scan_joystick_1
; Reads Joystick 1 and maps it to the unified input definitions
;
; Output: A = 8-bit input state (0 = pressed, 1 = not pressed).
;   Bit 7: Right Arrow / Joy Right
;   Bit 6: Down Arrow  / Joy Down
;   Bit 5: Up Arrow    / Joy Up
;   Bit 4: Left Arrow  / Joy Left
;   Bit 3: (Unused)
;   Bit 2: CTRL        / (Unmapped)
;   Bit 1: SHIFT       / Joy Trigger B
;   Bit 0: Space Bar   / Joy Trigger A
; ==============================================================================
scan_joystick_1:
  call internal_scan_joystick_1  ; Get raw joystick bits in A
  ld c, %11111111       ; C will hold our mapped output (Start with all released)

.check_up:
  bit JOY_UP_BIT, a     ; Is Joy Up pressed?
  jr nz, .check_down
  res INPUT_UP_BIT, c   ; If yes, clear the unified UP bit

.check_down:
  bit JOY_DOWN_BIT, a
  jr nz, .check_left
  res INPUT_DOWN_BIT, c

.check_left:
  bit JOY_LEFT_BIT, a
  jr nz, .check_right
  res INPUT_LEFT_BIT, c

.check_right:
  bit JOY_RIGHT_BIT, a
  jr nz, .check_trig_a
  res INPUT_RIGHT_BIT, c

; Map Trigger A to unified Button A (Spacebar equivalent)
.check_trig_a:
  bit JOY_TRIG_A_BIT, a
  jr nz, .check_trig_b
  res INPUT_BTN_A_BIT, c

; Map Trigger B to unified Button B (Shift equivalent)
.check_trig_b:
  bit JOY_TRIG_B_BIT, a
  jr nz, .done
  res INPUT_BTN_B_BIT, c

.done:
  ld a, c  ; Move mapped result back to A
  ret


