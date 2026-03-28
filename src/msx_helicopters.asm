moveMsxHelicopters:
  ld hl, msx_heli1A_x
  dec (hl)
  ld hl, msx_heli1B_x
  dec (hl)

  ld hl, msx_heli2A_x
  dec (hl)
  dec (hl)
  ld hl, msx_heli2B_x
  dec (hl)
  dec (hl)

  ld hl, msx_heli3A_x
  dec (hl)
  dec (hl)
  dec (hl)
  ld hl, msx_heli3B_x
  dec (hl)
  dec (hl)
  dec (hl)

  ret


; ==============================================================================
; Update the MSX sprite pattern
; ==============================================================================
updateMsxHeliSpritePattern:
  ; --- SLOW DOWN LOGIC ---
  ld  hl, msx_heli_frame_counter
  inc (hl)
  ld  a, (hl)
  cp  8               ; Slowed down to 8 for better visibility
  ret c

  ld  (hl), 0         ; Reset timer
  ld  a, (msx_heli_pattern)
  or  a
  jr  z, .set_msx_heli_frame_B ; If 0, go to Frame B (Index 8)

.set_msx_heli_frame_A:
  ld  d, 0            ; <--- Frame A starts at Index 0
  xor a               ; Next State = 0
  ld  (msx_heli_pattern), a
  ; MSX Helicopter 1
  ld a, 48
  ld (msx_heli1A_pat), a
  add a, 4
  ld (msx_heli1B_pat), a
  ; MSX Helicopter 2
  ld a, 56
  ld (msx_heli2A_pat), a
  add a, 4
  ld (msx_heli2B_pat), a
  ; MSX Helicopter 3
  ld a, 48
  ld (msx_heli3A_pat), a
  add a, 4
  ld (msx_heli3B_pat), a

  jr  .end_update_msx_heli_pattern

.set_msx_heli_frame_B:
  ld  d, 4
  ld  a, 1            ; Next State = 14
  ld  (msx_heli_pattern), a
  ; MSX Helicopter 1
  ld a, 56
  ld (msx_heli1A_pat), a
  add a, 4
  ld (msx_heli1B_pat), a
  ; MSX Helicopter 2
  ld a, 48
  ld (msx_heli2A_pat), a
  add a, 4
  ld (msx_heli2B_pat), a
  ; MSX Helicopter 1
  ld a, 56
  ld (msx_heli3A_pat), a
  add a, 4
  ld (msx_heli3B_pat), a
  ; Fallthrough to apply

.end_update_msx_heli_pattern:
  ret

