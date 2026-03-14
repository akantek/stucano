org $8000

header:
  db "AB"
  dw main
  dw 0, 0, 0
  dw 0, 0, 0
include "header.asm"
include "vblank.asm"
include "vdp.asm"
include "stars.asm"
include "font.asm"
include "strings.asm"
include "main.asm"
  ds $c000 - $, 0

