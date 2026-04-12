intro:
  di

  ; Initialize the number of frames to wait after pressing space
  ld a, 60
  ld (intro_frame_countdown), a

  ; Initialize the flash timer and state to 0
  xor a
  ld (frame_count), a
  ld (intro_flash_state), a

  ; Initialize intro_flash_delay to 20
  ld a, 20
  ld (intro_flash_delay), a

  ; Print title
  PRINT_AT 10, 8, 0, stucano_title_str

  ; Print 'PUSH SPACE KEY'
  PRINT_AT 9, 12, 0, push_space_key_str

  ; Print Kanteko
  PRINT_AT 10, 25, 0, kanteko_str
 
  call ENASCR
  ei

.intro_loop:
  ; Wait for the hardware V-Blank
  call wait_vsync

  ; scan keyboard
  call scan_keypad
  ld E, A

  ; Check if space key is pressed
  bit KEY_SPACE_BIT, E        
  jr nz, .not_intro_space_key     ; if (space_key NOT pressed): skip ahead

  ; Space key pressed, change `intro_flash_delay` to 5
  ld a, 5
  ld (intro_flash_delay), a

.not_intro_space_key:
  ; if (intro_flash_delay == 5): then starts counting dow `intro_frame_countdown`
  ld a, (intro_flash_delay)
  cp 5
  jr nz, .skip_fast_space_key_flash
  ; if ( intro_frame_countdown-- == 0): go to demo !!!
  ld a, (intro_frame_countdown)
  dec a
  ld (intro_frame_countdown), a    ; Store back the decremented value
  jp z, demo

.skip_fast_space_key_flash
  ; frame_counter++
  ld hl, frame_count
  inc (hl)
  ld a, (hl)

  ; if (frame_count < intro_flash_delay): goto .intro_loop
  ld hl, intro_flash_delay
  cp (hl)                 ; Compares A (frame_count) with (hl) (intro_flash_delay)
  jr c, .intro_loop       ; If frame_count < flash_delay (Carry flag set), keep waiting

  ; Timer hit the delay limit -> frame_count = 0
  xor a
  ld (frame_count), a     ; Reset frame count directly

  ; Toggle the flash state (0 becomes 1, 1 becomes 0)
  ld hl, intro_flash_state
  ld a, (hl)
  xor 1
  ld (hl), a
  ; if (a == 0): goto .draw_intro_text
  jr z, .draw_intro_text

.draw_intro_blank:
  ; Overwrite with spaces
  PRINT_AT 9, 12, 0, push_space_key_blank_str
  jr .intro_loop

.draw_intro_text:
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

