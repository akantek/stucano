intro:
  di

  ; Initialize the flash timer and state to 0
  xor a
  ld (frame_count), a
  ld (intro_flash_state), a

  ; Print title
  PRINT_AT 10, 8, 0, stucano_title_str

  ; Print 'PUSH SPACE KEY'
  PRINT_AT 9, 12, 0, push_space_key_str

  ; Print Kanteko
  PRINT_AT 10, 25, 0, kanteko_str
 
  call ENASCR
  ei

.intro_loop:
  ; 1. Wait for the hardware V-Blank
  call wait_vsync

  ; 2. Increment our 20-frame counter
  ld hl, frame_count
  inc (hl)
  ld a, (hl)
  cp 20
  jr nz, .intro_loop      ; If it hasn't reached 20 yet, keep waiting

  ; 3. Timer hit 20! Reset the timer back to 0
  ld (hl), 0

  ; 4. Toggle the flash state (0 becomes 1, 1 becomes 0)
  ld hl, intro_flash_state
  ld a, (hl)
  xor 1
  ld (hl), a
  
  ; 5. Branch based on the new state
  jr z, .draw_text

.draw_blank:
  ; Overwrite with spaces
  PRINT_AT 9, 12, 0, push_space_key_blank_str
  jr .intro_loop

.draw_text:
  ; Redraw the actual text
  PRINT_AT 9, 12, 0, push_space_key_str
  jr .intro_loop


intro_strings:

stucano_title_str:
  db LETTER_S, LETTER_U, LETTER_P, LETTER_E, LETTER_R, LETTER_SPACE
  db LETTER_T, LETTER_U, LETTER_C, LETTER_A, LETTER_N, LETTER_O, 255

push_space_key_str:
  db LETTER_P, LETTER_U, LETTER_S, LETTER_H, LETTER_SPACE
  db LETTER_S, LETTER_P, LETTER_A, LETTER_C, LETTER_E, LETTER_SPACE
  db LETTER_K, LETTER_E, LETTER_Y, 255

push_space_key_blank_str:
  db LETTER_SPACE, LETTER_SPACE, LETTER_SPACE, LETTER_SPACE, LETTER_SPACE
  db LETTER_SPACE, LETTER_SPACE, LETTER_SPACE, LETTER_SPACE, LETTER_SPACE
  db LETTER_SPACE, LETTER_SPACE, LETTER_SPACE, LETTER_SPACE, 255

kanteko_str:
  db LETTER_K, LETTER_A, LETTER_N, LETTER_T, LETTER_E, LETTER_K, LETTER_O
  db LETTER_SPACE, DIGIT_2, DIGIT_0, DIGIT_2, DIGIT_6, 255

