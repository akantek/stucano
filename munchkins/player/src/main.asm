main:
  ld sp, $f380  ; ROM standard SP initialization (move to top-of-RAM)

  call boot
  jp start_player


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

  ; CLICK OFF
  xor a
  ld (CLIKSW), a  ; Set Click Switch ($F3DB) to 0

  ; SCREEN OFF
  call DISSCR

  ; Install VBlank hook
  call install_vblank_hook

  ; TODO: Set 16X16 sprites
  ; TODO: load sprites patterns
  ; TODO: load sprites colors
  ; TODO: load sprites attributes

  ret

