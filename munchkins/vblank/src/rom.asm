include "../../../src/header.asm"

org $8000

header:
  db "AB"
  dw main
  dw 0, 0, 0
  dw 0, 0, 0

include "vblank.asm"
include "main.asm"
include "ram.asm"

  ds $c000 - $, 0

