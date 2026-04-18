stucano_palette:
  ; 0: Transparent (R0, G0, B0)
  db $00, $00 

  ; 1: Black (R0, G0, B0)
  db $00, $00 

  ; 2: Medium Green (R1, G6, B1)
  ;db $11, $06 
  db $11, $03

  ; 3: Light Green (R3, G7, B3)
  ; db $37, $03
  db $55, 05 

  ; 4: Dark Blue (R1, G1, B7)
  db $17, $01 

  ; 5: Light Blue (R2, G3, B7)
  db $27, $03 

  ; 6: Dark Red (R5, G1, B1)
  db $51, $01 

  ; 7: Cyan (R2, G7, B7)
  db $27, $07 

  ; 8: Medium Red (R7, G1, B1)
  ; idb $71, $01 
  db $77, $07

  ; 9: Light Red (R7, G3, B3)
  ; db $73, $03 
  db $70, $00

  ; 10: Dark Yellow (R6, G6, B1)
  db $61, $06 

  ; 11: Light Yellow (R6, G7, B4)
  db $64, $07 

  ; 12: Dark Green (R1, G4, B1)
  ; db $11, $04 
  db $33, $03

  ; 13: Magenta (R6, G1, B5)
  db $65, $01 

  ; 14: Gray (R5, G5, B5)
  db $55, $05 

  ; 15: White (R7, G7, B7)
  db $77, $07


; Kept for reference
msx1_palette:
  ; 0: Transparent (R0, G0, B0)
  db $00, $00 

  ; 1: Black (R0, G0, B0)
  db $00, $00 

  ; 2: Medium Green (R1, G6, B1)
  db $11, $06 

  ; 3: Light Green (R3, G7, B3)
  db $33, $07 

  ; 4: Dark Blue (R1, G1, B7)
  db $17, $01 

  ; 5: Light Blue (R2, G3, B7)
  db $27, $03 

  ; 6: Dark Red (R5, G1, B1)
  db $51, $01 

  ; 7: Cyan (R2, G7, B7)
  db $27, $07 

  ; 8: Medium Red (R7, G1, B1)
  db $71, $01 

  ; 9: Light Red (R7, G3, B3)
  db $73, $03 

  ; 10: Dark Yellow (R6, G6, B1)
  db $61, $06 

  ; 11: Light Yellow (R6, G7, B4)
  db $64, $07 

  ; 12: Dark Green (R1, G4, B1)
  db $11, $04 

  ; 13: Magenta (R6, G1, B5)
  db $65, $01 

  ; 14: Gray (R5, G5, B5)
  db $55, $05 

  ; 15: White (R7, G7, B7)
  db $77, $07


; ==============================================================================
; set_palette_color
; Changes a single color in the MSX2/MSX2+ palette dynamically.
;
; Inputs:
;   A: Color Index (0 - 15)
;   B: Red   (0 - 7)
;   C: Green (0 - 7)
;   D: Blue  (0 - 7)
;
; Registers modified: A
; ==============================================================================
set_palette_color:
  di               ; Disable interrupts (critical to prevent VBLANK from 
                   ; interrupting our two-part write to VDP port $99)

  ; 1. Set VDP Register 16 (Palette Pointer) to the target color index
  out ($99), a     ; Send the color index (0-15)
  ld a, $90        ; $90 is 128 + 16 (Tells VDP to write to Register 16)
  out ($99), a

  ; 2. Format Byte 1: (Red << 4) | Blue
  ld a, b          ; Load Red into A
  rlca             ; Shift left 4 times. Using 4x RLCA is significantly 
  rlca             ; faster (16 cycles) than setting up a loop or math.
  rlca
  rlca
  or d             ; Merge the Blue value into the lower 4 bits

  ; 3. Write Byte 1 to the Palette Data Port
  out ($9A), a

  ; 4. Format and Write Byte 2: Green
  ld a, c          ; Load Green into A
  out ($9A), a

  ei               ; Restore interrupts
  ret


