include "../../../src/header.asm"

org $8000

header:
  db "AB"
  dw main
  dw 0, 0, 0
  dw 0, 0, 0

include "main.asm"
include "player_vs_ufo.asm"
include "ram.asm"
include "palette.asm"
include "collision.asm"

include "../../../src/vblank.asm"
include "../../../src/spritesheet.asm"
include "../../../src/vdp.asm"
include "../../../src/joypad.asm"
include "../../../src/keypad.asm"

  ds $c000 - $, 0

