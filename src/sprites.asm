loadSpritePatterns:
  ld HL, sprite_patterns_start
  ld DE, VRAM_SPR_PATTERNS
  ld A, SPRITE_VRAM_BANK
  ld BC, sprite_patterns_end - sprite_patterns_start
  call write_vram_large
  ret


loadSpriteColors:
  ld hl, sprite_color_data_start        ; Source RAM
  ld de, VRAM_SPR_COLORS                ; Dest VRAM ($7400)
  ld a, SPRITE_VRAM_BANK                ; Bank 1
  ld bc, sprite_color_data_end - sprite_color_data_start
  call write_vram_large
  ret


; ==============================================================================
; Routine:      loadSpriteAttributes
; Description:  Transfers Shadow RAM to VRAM. 
; This routine 2,775 T-states (cycles), approximately 0.775 milliseconds
; (or 775 microseconds).
; ==============================================================================
loadSpriteAttributes:
  ld hl, shadow_sat      ; Source RAM
  ld c, VDP_DATA_PORT           ; VDP data port

  di
  ; Set VRAM address: low byte
  ld a, VRAM_SPR_ATTRIBS and $FF
  out (VDP_CONTROL_PORT), a

  ; Set VRAM address: high byte 
  ld a, VRAM_SPR_ATTRIBS / 256  ; Load the raw high byte (e.g. $76)
  and $3F                       ; Clear top 2 bits (safety mask)
  or $40                        ; Set bit 6 to enable VDP WRITE mode
  out (VDP_CONTROL_PORT), a
  ei

  ; ld b, 2*4  ; 2 sprites (4 bytes each)
  ld b, 2 * 4
  otir          ; Output (HL) -> PORT C, HL++, B--
  ret


initSpriteAttributes:
  ; 1. Copy the initial data into the RAM Shadow Buffer
  ld hl, init_sprite_attributes
  ld de, shadow_sat
  ld bc, 2 * 4
  ldir

  ; 2. Send it to VDP
  ld hl, shadow_sat
  ld a, SPRITE_VRAM_BANK
  ld de, VRAM_SPR_ATTRIBS
  ld bc, 2 * 4
  call write_vram_fast
  ret


init_sprite_attributes:
  ; Sprite 0: MSX Helicopter left facing
  db 80, 188, 0, 0

  ; Sprite 1: MSX Helicopter right facing
  db 80, 188 + 14, 4, 0
  ret


sprite_color_data_start:
msx_helicopter_colors_start:
; MSX Helicopter Left Sprite
db 4,12,4,12, 13,12,12,12, 12,12,12,12, 12,12,12,12

; MSX Helicopter Right Sprite
db $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44
msx_helicopter_colors_end:
sprite_color_data_end:

