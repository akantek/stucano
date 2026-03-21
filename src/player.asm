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

animatePlayerSprite:
  ; --- 1. Frame Delay Logic ---
  ld hl, player_anim_frame_counter
  dec (hl)
  ret nz                     ; If counter hasn't reached 0, exit and wait

  ; Reset counter to 4 frames
  ld (hl), 4

  ; --- 2. Advance Player Animation State ---
  ld a, (player_anim_state)
  inc a
  cp 3
  jr nz, .save_player_anim_state
  xor a
.save_player_anim_state:
  ld (player_anim_state), a

  ; --- 3. Determine Source Address based on State ---
  or a
  jr z, .load_player_pattern_A
  cp 1
  jr z, .load_player_pattern_B

.load_player_pattern_C:
  ld hl, sprite_patterns_helicopter_C_start
  jr .update_player_pattern

.load_player_pattern_B:
  ld hl, sprite_patterns_helicopter_B_start
  jr .update_player_pattern

.load_player_pattern_A:
  ld hl, sprite_patterns_helicopter_A_start

.update_player_pattern:
  ; --- 4. Blast new patterns to VDP ---
  ; We are updating Sprite Patterns 0, 1, 2, and 3.
  ; Each pattern is 32 bytes. 4 * 32 = 128 bytes total.
  ld de, VRAM_SPR_PATTERNS     ; Dest: $7800 (Patterns 0-3)
  ld a, SPRITE_VRAM_BANK       ; Bank 1
  ld c, 128                    ; Size: 128 bytes (safe for fast write)
  call write_vram_fast
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


