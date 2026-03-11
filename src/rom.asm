org $8000

header:
  db "AB"
  dw main
  dw 0, 0, 0
  dw 0, 0, 0

include "main.asm"
  ds $c000 - $, 0

