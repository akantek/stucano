intro:
  di

  ; Print title
  PRINT_AT 10, 8, 0, stucano_title_str

  ; Print 'PUSH SPACE KEY'
  PRINT_AT 10, 12, 0, push_space_key_str

  ; Print Kanteko
  PRINT_AT 10, 25, 0, kanteko_str
 
  call ENASCR
  ei
.intro_loop:

  jr .intro_loop


intro_strings:

stucano_title_str:
  db LETTER_S, LETTER_U, LETTER_P, LETTER_E, LETTER_R, LETTER_SPACE
  db LETTER_T, LETTER_U, LETTER_C, LETTER_A, LETTER_N, LETTER_O, 255

push_space_key_str:
  db LETTER_P, LETTER_U, LETTER_S, LETTER_H, LETTER_SPACE
  db LETTER_S, LETTER_P, LETTER_A, LETTER_C, LETTER_E, LETTER_SPACE
  db LETTER_K, LETTER_E, LETTER_Y, 255

kanteko_str:
  db LETTER_K, LETTER_A, LETTER_N, LETTER_T, LETTER_E, LETTER_K, LETTER_O
  db LETTER_SPACE, DIGIT_2, DIGIT_0, DIGIT_2, DIGIT_6, 255

