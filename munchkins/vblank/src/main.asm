main:
  ld sp, $f380  ; ROM standard SP initialization (move to top-of-RAM)

  call boot
  jr demo_vblank


demo_vblank:
.loop:
  call wait_vsync        ; Spin until vblank is fired
.vblank_trace_start:
  ; >>>>>>> Change VRAM here <<<<<<<
.vblank_trace_end:
  ; Starting here, no more VRAM changes
  
  ; frame_count++
  ld a, (frame_count)
  inc a
  ld (frame_count), a

  ; if (frame_count != 59) then jump to the end
  cp 59
  jr nz, .skip_beep

  ; else
  call BEEP
  xor a
  ld (frame_count), a

.skip_beep:
  jr .loop  


boot:
  ; COLOR 15,1,1
  ld a, WHITE
  ld (FORCLR), a  ; Store in Foreground system variable ($F3E9)
  ld a, BLACK
  ld (BAKCLR), a  ; Store in Background system variable ($F3EA)
  ld (BDRCLR), a  ; Store in Border system variable ($F3EB)
  call CHGCLR     ; BIOS Call ($0062): Update VDP registers with new colors

  ; SCREEN 5
  ld a, 5         ; Screen mode 5 (256x212, 16 colors - MSX2)
  call CHGMOD

  ; Install VBlank hook
  xor a
  ld (frame_count), a
  call install_vblank_hook

  ret

