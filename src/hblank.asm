; Install hblank, must be under di and then ei
; Hook HKEYI (Line Interrupt / H-Blank)
install_hblank:
  ld  hl, HKEYI
  ld  de, OLD_HKEYI
  ld  bc, 5
  ldir
  ld  a, $C3
  ld  (HKEYI), a
  ld  hl, hblank_hook
  ld  (HKEYI + 1), hl
  ret

; ==============================================================================
; H-BLANK INTERRUPT (Triggered at your specified split line)
; ==============================================================================
hblank_hook:
  push af                    ; <--- CRITICAL: Add this to save AF!

  ; 1. Select VDP Status Register 1
  ld a, 1
  out (VDP_CONTROL_PORT), a
  ld a, 15 + 128
  out (VDP_CONTROL_PORT), a

  ; 2. Read S#1 to check if a Line Interrupt fired
  in a, (VDP_CONTROL_PORT)
  rrca                       ; Shift bit 0 (Line Int Flag) into the Carry flag
  jr nc, .exit_hblank        ; If Carry is 0, this wasn't a Line Interrupt, skip!

  ; --- IT IS A LINE INTERRUPT! APPLY SCROLL FOR THE BOTTOM ---
  
  ; 3. Calculate and write R#26 (8-pixel block offset)
  ld a, (camera_x)
  rrca
  rrca
  rrca
  and 31                     ; Mask to 0-31
  out (VDP_CONTROL_PORT), a
  ld a, 26 + 128
  out (VDP_CONTROL_PORT), a

  ; 4. Calculate and write R#27 (1-pixel fine scroll offset)
  ld a, (camera_x)
  and 7                      ; Mask lowest 3 bits
  out (VDP_CONTROL_PORT), a
  ld a, 27 + 128
  out (VDP_CONTROL_PORT), a

.exit_hblank:
  ; 5. CRITICAL: Restore VDP to Status Register 0 for the BIOS!
  xor a
  out (VDP_CONTROL_PORT), a
  ld a, 15 + 128
  out (VDP_CONTROL_PORT), a

  pop af                     ; <--- CRITICAL: Add this to restore AF!
  jp OLD_HKEYI


enable_split_screen:
  ; 1. Set the Line Interrupt to trigger at Line 180
  ld a, 180
  out (VDP_CONTROL_PORT), a
  ld a, 19 + 128             ; VDP Register 19 sets the Line Interrupt Y
  out (VDP_CONTROL_PORT), a

  ; 2. Enable Line Interrupts (IE1) in Register 0
  ld a, (RG0SAV)             ; Read BIOS mirror to keep other flags safe
  or %00010000               ; Set bit 4 (IE1)
  ld (RG0SAV), a
  out (VDP_CONTROL_PORT), a
  ld a, 0 + 128
  out (VDP_CONTROL_PORT), a
  ret

