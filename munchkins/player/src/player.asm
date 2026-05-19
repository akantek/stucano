start_player:
  di

  ; Initialize frame_count to 0
  xor a
  ld (frame_count), a

  call ENASCR
  ei

.player_loop:
  call wait_vsync        ; Spin until vblank is fired
.vblank_trace_start:
  ; frame_count++
  ld a, (frame_count)
  inc a
  ld (frame_count), a

  ; if (frame_count != 59) then jump to the end
  cp 59
  jr nz, .skip_beep
  
  call BEEP
  xor a
  ld (frame_count), a
  

.vblank_trace_end:

.skip_beep:
  jr .player_loop

