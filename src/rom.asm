include "header.asm"

org $8000

header:
  db "AB"
  dw main
  dw 0, 0, 0
  dw 0, 0, 0
include "keypad.asm"
include "vblank.asm"
include "vdp.asm"
include "stars.asm"
include "font.asm"
include "strings.asm"
include "tilesheet.asm"
include "tiles.asm"
include "spritesheet.asm"
include "sprites.asm"
include "player.asm"
include "msx_helicopters.asm"
include "playfield.asm"
include "palettes.asm"
include "scroll.asm"
include "test.asm"
include "main.asm"
  ds $c000 - $, 0

