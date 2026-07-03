SPRITE_X: equ 90
SPRITE_Y: equ 90
NUM_SPRITES: equ 3     ; Changed to 2 (2 active sprite + 1 terminator)

gauntlet:
  ; Setup
  di
  
  ; load palette
  ld HL, palette
  call loadPalette

  ; Load and initialize sprites
  call loadSpritePatterns
  call loadSpriteColors
  call initSpriteAttributes
  call loadSpriteAttributes
  call ENASCR
  ei
.loop:
  jp .loop

loadSpritePatterns:
  ld HL, sprite_patterns_start
  ld DE, VRAM_SPR_PATTERNS
  ld A, SPRITE_VRAM_BANK
  ld BC, sprite_patterns_end - sprite_patterns_start
  call write_vram_large
  ret

loadSpriteColors:
  ld hl, gauntlet_colors_start   ; Source RAM
  ld de, VRAM_SPR_COLORS        ; Dest VRAM ($7400)
  ld a, SPRITE_VRAM_BANK        ; Bank 1
  ld c, gauntlet_colors_end - gauntlet_colors_start
  call write_vram_fast
  ret

gauntlet_colors_start:
  ; 4: 0100
  ; 8: 1000
  ; 

  ; Wizard A (Layer 1) - Color 1 (with one line of color 15)
  db 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4

  ; Wizard B (Layer 2) - Color 2 + OR effect (CC bit 64)
  ; %00000010  (Color 2)
  ; | %01000000  (CC Flag - 64)
  ; ---------------------------
  ; %01000010  (Result - 66)
  ;db 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66

  ; %00001000  (Color 8)
  ; | %01000000  (CC Flag - 64)
  ; ---------------------------
  ; %01001000  (Result - 72)
; Wizard B (Layer 2) - Color 8 blended with the sprite below
  db 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72
gauntlet_colors_end:

initSpriteAttributes:
  ; 1. Copy the initial data into the RAM Shadow Buffer
  ld hl, init_sprite_attributes
  ld de, shadow_sat
  ld bc, NUM_SPRITES * 4
  ldir

  ; 2. Send it to VDP
  ld hl, shadow_sat
  ld a, SPRITE_VRAM_BANK
  ld de, VRAM_SPR_ATTRIBS
  ld bc, NUM_SPRITES * 4
  call write_vram_fast
  ret


init_sprite_attributes:
  ; Wizard A (Layer 1)
  db SPRITE_Y, SPRITE_X, 0, 0

  ; Wizard B (Layer 2)
  db SPRITE_Y, SPRITE_X, 4, 0

  db $D8, 0, 0, 0

