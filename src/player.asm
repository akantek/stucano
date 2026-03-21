; ==============================================================================
; Scan keypad and move player
; ==============================================================================
move_player:
  ; scan keyboard
  call scan_keypad
  ld E, A

  bit KEY_UP_BIT, E        ; Check UP
  jp NZ, .check_down_key
  ld HL, player_y
  dec (HL)
.check_down_key:
  bit KEY_DOWN_BIT, E      ; Check DOWN
  jp NZ, .check_left_key
  ld HL, player_y
  inc (HL)
.check_left_key:
  bit KEY_LEFT_BIT, E      ; Check DOWN
  jp NZ, .check_right_key
  ld HL, player_x
  dec (HL)
.check_right_key:
  bit KEY_RIGHT_BIT, E      ; Check DOWN
  jp NZ, .end_move_player
  ld HL, player_x
  inc (HL)
.end_move_player:
  ret


update_player_sat:
  ; Update Y
  ld a, (player_y)
  ld (playerA_y), a
  ld (playerB_y), a
  ld (playerC_y), a
  ld (playerD_y), a

  ; Update X
  ld a, (player_x)
  ld (playerA_x), a
  ld (playerB_x), a
  add a, 14
  ld (playerC_x), a
  ld (playerD_x), a
  ret


