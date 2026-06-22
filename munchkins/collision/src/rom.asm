include "../../../src/header.asm"

org $8000

header:
  db "AB"
  dw main
  dw 0, 0, 0
  dw 0, 0, 0

include "../../../src/vblank.asm"
include "collision.asm"
include "main.asm"
include "game.asm"
include "ram.asm"
include "spritesheet.asm"
include "../../../src/vdp.asm"
include "../../../src/joypad.asm"
include "../../../src/keypad.asm"

  ds $c000 - $, 0

