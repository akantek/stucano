include "../../../src/header.asm"

org $8000

header:
  db "AB"
  dw main
  dw 0, 0, 0
  dw 0, 0, 0

include "../../../src/vblank.asm"
include "main.asm"
include "gauntlet.asm"
include "ram.asm"
include "spritesheet.asm"
include "palette.asm"
include "../../../src/vdp.asm"
include "../../../src/joypad.asm"
include "../../../src/keypad.asm"

  ds $c000 - $, 0

