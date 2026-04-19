NUM_SPRITES:    equ 10

loadSpritePatterns:
  ld HL, sprite_patterns_start
  ld DE, VRAM_SPR_PATTERNS
  ld A, SPRITE_VRAM_BANK
  ld BC, sprite_patterns_end - sprite_patterns_start
  call write_vram_large
  ret

loadSpriteColors:
  ; --- Load colors for Sprites 0 & 1 ---
  ld hl, player_helicopter_colors_start   ; Source RAM
  ld de, VRAM_SPR_COLORS                  ; Dest VRAM ($7400)
  ld a, SPRITE_VRAM_BANK                  ; Bank 1
  ld c, player_helicopter_colors_end - player_helicopter_colors_start
  call write_vram_fast

  ; --- Load colors for Sprites 2 & 3 ---
  ld hl, player_helicopter_colors_start   ; Source RAM
  ld de, VRAM_SPR_COLORS + 32             ; Dest VRAM ($7400)
  ld a, SPRITE_VRAM_BANK                  ; Bank 1
  ld c, player_helicopter_colors_end - player_helicopter_colors_start
  call write_vram_fast

  ; --- Load colors for Sprites 4 & 5 ---
  ld hl, msx_helicopter_colors_start   ; Source RAM
  ld de, VRAM_SPR_COLORS + 64          ; Dest VRAM ($7400)
  ld a, SPRITE_VRAM_BANK               ; Bank 1
  ld c, msx_helicopter_colors_end - msx_helicopter_colors_start ; Length in C (max 256)
  call write_vram_fast

  ; --- Load colors for Sprites 6 & 7 ---
  ld hl, msx_helicopter_colors_start   ; Source RAM (re-use the same colors)
  ld de, VRAM_SPR_COLORS + 96          ; Dest VRAM offset by 32 bytes ($7420)
  ld a, SPRITE_VRAM_BANK               ; Bank 1
  ld c, msx_helicopter_colors_end - msx_helicopter_colors_start ; Length in C (max 256)
  call write_vram_fast
  
  ; --- Load colors for Sprites 8 & 9 ---
  ld hl, msx_helicopter_colors_start   ; Source RAM (re-use the same colors)
  ld de, VRAM_SPR_COLORS + 128         ; Dest VRAM offset by 32 bytes ($7420)
  ld a, SPRITE_VRAM_BANK               ; Bank 1
  ld c, msx_helicopter_colors_end - msx_helicopter_colors_start ; Length in C (max 256)
  call write_vram_fast

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
  ld b, NUM_SPRITES * 4
  otir          ; Output (HL) -> PORT C, HL++, B--
  ret


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
  ; Sprite 0: Right Facing - Layer 1 (White)
  ; Y ($60=96), X ($70=112), Pattern 0
  db PLAYER_Y_MIN + 10, $78, 0, 0

  ; Sprite 1: Right Facing - Layer 2 (Red)
  ; Same X,Y as above to overlay them
  db PLAYER_Y_MIN + 10, $78, 4, 0 

  ; Sprite 2: Left Facing - Layer 1 (White)
  ; Y ($60=96), X ($90=144), Pattern 8
  db PLAYER_Y_MIN + 10, $86, 8, 0

  ; Sprite 3: Left Facing - Layer 2 (Red)
  ; Same X,Y as above to overlay them
  db PLAYER_Y_MIN + 10, $86, 12, 0

  ; Sprite 4: MSX Helicopter left facing (Frame A)
  db 60, 188, 52, 0       ; Shifted from 48 -> 52

  ; Sprite 5: MSX Helicopter right facing (Frame A)
  db 60, 188 + 14, 56, 0  ; Shifted from 52 -> 56

  ; Sprite 6: MSX Helicopter left facing (Frame B)
  db 120, 188, 60, 0      ; Shifted from 56 -> 60

  ; Sprite 7: MSX Helicopter right facing (Frame B)
  db 120, 188 + 14, 64, 0 ; Shifted from 60 -> 64

  ; Sprite 8: MSX Helicopter left facing (Frame B reused)
  db 30, 40, 60, 0        ; Shifted from 56 -> 60

  ; Sprite 9: MSX Helicopter right facing (Frame B reused)
  db 30, 40 + 14, 64, 0   ; Shifted from 60 -> 64

  ; Sprite 10: Helicopter Explosion / Fire
  ; Pattern 48 (inserted right after Player Heli C)
  ; Spawns at Y=212 to remain hidden off-screen
  db 212, 0, 48, 0
  ret


sprite_color_data_start:
player_helicopter_colors_start:
; Sprite 0
db 12,12,12,12, 8,8,8,8, 8,8,8,8, 8,8,8,8
; Sprite 1
db $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44
; Sprite 2
db 8,8,8,8, 8,8,8,8, 8,8,8,8, 8,8,8,8
; Sprite 3
db $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44
player_helicopter_colors_end:

msx_helicopter_colors_start:
; MSX Helicopter Left Sprite
db 4,12,4,12, 15,12,12,12, 12,12,12,12, 12,12,12,12

; MSX Helicopter Right Sprite
db $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44
msx_helicopter_colors_end:
sprite_color_data_end:

