PRINT_AT MACRO col, row, page, label
  ld c, col       ; 8-bit load (faster and uses less ROM)
  ld e, row       ; 8-bit load
  ld a, page
  ld hl, label
  call print_str
ENDM

strings:

stucano_title_str:
  db LETTER_S, LETTER_U, LETTER_P, LETTER_E, LETTER_R, LETTER_SPACE
  db LETTER_T, LETTER_U, LETTER_C, LETTER_A, LETTER_N, LETTER_O, 255

kanteko_str:
  db LETTER_K, LETTER_A, LETTER_N, LETTER_T, LETTER_E, LETTER_K, LETTER_O
  db LETTER_SPACE, DIGIT_2, DIGIT_0, DIGIT_2, DIGIT_6, 255


; ==============================================================================
; print_str
; INPUTS: HL = String Pointer, C = Column (0-31), E = Row (0-26), A = Page (0-1)
; ==============================================================================
print_str:
  ld   b, a             ; Move Page Number to B so we don't lose it

.char_loop:
  ld   a, (hl)          ; Get the next character
  cp   255              ; Is it the string terminator?
  ret  z                ; If yes, return to the caller

  ; Save our loop variables before calling the helpers
  push hl               ; Save String Pointer
  push bc               ; Save Page (B) and Column (C)
  push de               ; Save Row (E)

  ; --- The 3 Steps to Draw a Character ---
  call get_font_address ; 1. A  -> HL (Calculates Font Data Address)
  call set_vdp_address  ; 2. BC,E -> DE (Calculates VRAM Addr & Sets Bank)
  call copy_font_to_vdp ; 3. HL,DE -> VDP (Draws the 8 lines)

  ; Restore our loop variables
  pop  de               ; Restore Row
  pop  bc               ; Restore Page and Column
  pop  hl               ; Restore String Pointer
  
  inc  c                ; Move 1 grid column to the right
  inc  hl               ; Point to the next character in the string
  jr   .char_loop       ; Repeat!


; ------------------------------------------------------------------------------
; Helper 1: get_font_address
; Input:  A = Character Index
; Output: HL = Address of the font data in ROM
; ------------------------------------------------------------------------------
get_font_address:
  push de               ; Save DE so we don't clobber the Row variable
  
  ld   l, a             ; HL = Character Index
  ld   h, 0
  add  hl, hl           ; * 2
  add  hl, hl           ; * 4
  add  hl, hl           ; * 8
  add  hl, hl           ; * 16
  add  hl, hl           ; * 32 (Because each char is 32 bytes)
  
  ld   de, font_data_start
  add  hl, de           ; HL now points to the exact font pixels

  pop  de
  ret

; ------------------------------------------------------------------------------
; Helper 2: set_vdp_address
; Input:  B = Page (0 or 1), C = Column, E = Row
; Output: DE = 14-bit VRAM Address (Register 14 is also updated)
; ------------------------------------------------------------------------------
set_vdp_address:
  ; 1. Calculate Row Base (D = Row * 4)
  ld   a, e
  add  a, a
  add  a, a
  ld   d, a
  
  ; 2. Calculate Column Base (E = Col * 4)
  ld   a, c
  add  a, a
  add  a, a
  push af               ; Briefly save this result

  ; 3. Handle the 16KB VRAM Bank Crossing
  ld   a, b
  add  a, a             ; Base Bank (Page 0 -> Bank 0, Page 1 -> Bank 2)
  bit  6, d             ; Are we in the bottom half of the page?
  jr   z, .write_r14
  inc  a                ; If yes, shift to the next 16KB bank (+1)
  res  6, d             ; Mask off the overflow bit to keep it 14-bit safe

.write_r14:
  di
  out  (VDP_CONTROL_PORT), a       ; Set the 16KB Bank
  ld   a, 14 or $80
  out  (VDP_CONTROL_PORT), a
  ei

  pop  af
  ld   e, a             ; DE is now fully assembled: [Row Math] [Col Math]
  ret

; ------------------------------------------------------------------------------
; Helper 3: copy_font_to_vdp
; Input:  HL = Font Address, DE = VRAM Address
; ------------------------------------------------------------------------------
copy_font_to_vdp:
  ld   b, 8             ; A character is 8 pixels tall
  
.line_loop:
  push bc               ; Save the loop counter
  
  ; Set the VDP Write Pointer to DE
  di
  ld   a, e
  out  (VDP_CONTROL_PORT), a
  ld   a, d
  or   $40              ; $40 is the VDP Write Flag
  out  (VDP_CONTROL_PORT), a
  ei
  
  ; Blast 4 bytes (8 pixels wide) to the screen
  ld   c, VDP_DATA_PORT
  ld   a, (hl)
  out  (c), a
  inc  hl
  ld   a, (hl)
  out  (c), a
  inc  hl
  ld   a, (hl)
  out  (c), a
  inc  hl
  ld   a, (hl)
  out  (c), a
  inc  hl
  
  ; Move VRAM address down 1 line (DE = DE + 128 bytes)
  ex   de, hl
  ld   bc, 128
  add  hl, bc
  ex   de, hl
  
  pop  bc               ; Restore the loop counter
  djnz .line_loop       ; Loop until B = 0
  
  ret

