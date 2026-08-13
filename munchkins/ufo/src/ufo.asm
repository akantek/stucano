MSX_UFO_Y:   equ 140
MSX_UFO_X:   equ 112
NUM_SPRITES: equ 1

ufo_demo:
  di

  call loadSpritePatterns
  call loadSpriteColors
  call initSpriteAttributes
  call loadUfoSpriteAttributes

  ; Initialize the sine wave angle
  xor a
  ld (ufo_angle), a

  ld a, MSX_UFO_Y
  ld (ufo_base_y), a

  call ENASCR
  ei


.ufo_loop:
  call wait_vsync        ; Spin until vblank is fired
.vblank_trace_start:
  call loadUfoSpriteAttributes
.vblank_trace_end:

  call update_ufo_position

  jr .ufo_loop


; ==============================================================================
; Routine:      update_ufo_position
; Description:  Moves X leftwards, reads a signed offset from the sine LUT, 
;               and adds it to the base Y coordinate.
; ==============================================================================
update_ufo_position:
  ; 1. Move X linearly leftwards
  ld hl, msx_ufo_x
  dec (hl)             

  ; 2. Advance the sine wave angle
  ld a, (ufo_angle)
  add a, 2             ; Speed of the sine wave
  ld (ufo_angle), a    

  ; 3. Fetch the signed Y offset from the lookup table
  ld hl, sine_offset_table
  ld e, a              ; Set E to current angle
  ld d, 0              
  add hl, de           ; HL points to sine_offset_table[ufo_angle]
  ld a, (hl)           ; A now holds the signed offset (e.g., $FF for -1)

  ; 4. Add the offset to the UFO's Base Y
  ld b, a              ; Store offset temporarily in B
  ld a, (ufo_base_y)   ; Load the UFO's center line (e.g., 96)
  add a, b             ; Add them together (Z80 handles the negative math perfectly!)

  ; 5. Store the final calculated Y into the Sprite Attribute Table
  ld (msx_ufo_y), a    

  ret


loadSpritePatterns:
  ld HL, sprite_patterns_start
  ld DE, VRAM_SPR_PATTERNS
  ld A, SPRITE_VRAM_BANK
  ld BC, sprite_patterns_end - sprite_patterns_start
  call write_vram_large
  ret

loadSpriteColors:
  ld hl, msx_ufo_colors_start   ; Source RAM
  ld de, VRAM_SPR_COLORS        ; Dest VRAM ($7400)
  ld a, SPRITE_VRAM_BANK        ; Bank 1
  ld c, msx_ufo_colors_end - msx_ufo_colors_start
  call write_vram_fast
  ret

; ==============================================================================
; Routine:      loadUfoSpriteAttributes
; Description:  Transfers Shadow RAM to VRAM. 
; This routine 2,775 T-states (cycles), approximately 0.775 milliseconds
; (or 775 microseconds).
; ==============================================================================
loadUfoSpriteAttributes:
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

msx_ufo_colors_start:
; Sprite 0
db 14,14,14,14, 14,14,14,14, 14,14,14,14, 8,8,8,8
msx_ufo_colors_end:

init_sprite_attributes:
  ; Sprite 0: Right Facing - Layer 1 (White)
  ; Y ($60=96), X ($70=112), Pattern 0
  db MSX_UFO_Y, MSX_UFO_X, 0, 0


; Generated Sine Offset Table (Amplitude: +/-30, Size: 256)
sine_offset_table:
  db $00, $00, $01, $02, $02, $03, $04, $05
  db $05, $06, $07, $08, $08, $09, $0A, $0A
  db $0B, $0C, $0C, $0D, $0E, $0E, $0F, $10
  db $10, $11, $11, $12, $13, $13, $14, $14
  db $15, $15, $16, $16, $17, $17, $18, $18
  db $18, $19, $19, $1A, $1A, $1A, $1B, $1B
  db $1B, $1B, $1C, $1C, $1C, $1C, $1D, $1D
  db $1D, $1D, $1D, $1D, $1D, $1D, $1D, $1D
  db $1E, $1D, $1D, $1D, $1D, $1D, $1D, $1D
  db $1D, $1D, $1D, $1C, $1C, $1C, $1C, $1B
  db $1B, $1B, $1B, $1A, $1A, $1A, $19, $19
  db $18, $18, $18, $17, $17, $16, $16, $15
  db $15, $14, $14, $13, $13, $12, $11, $11
  db $10, $10, $0F, $0E, $0E, $0D, $0C, $0C
  db $0B, $0A, $0A, $09, $08, $08, $07, $06
  db $05, $05, $04, $03, $02, $02, $01, $00
  db $00, $00, $FF, $FE, $FE, $FD, $FC, $FB
  db $FB, $FA, $F9, $F8, $F8, $F7, $F6, $F6
  db $F5, $F4, $F4, $F3, $F2, $F2, $F1, $F0
  db $F0, $EF, $EF, $EE, $ED, $ED, $EC, $EC
  db $EB, $EB, $EA, $EA, $E9, $E9, $E8, $E8
  db $E8, $E7, $E7, $E6, $E6, $E6, $E5, $E5
  db $E5, $E5, $E4, $E4, $E4, $E4, $E3, $E3
  db $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3
  db $E2, $E3, $E3, $E3, $E3, $E3, $E3, $E3
  db $E3, $E3, $E3, $E4, $E4, $E4, $E4, $E5
  db $E5, $E5, $E5, $E6, $E6, $E6, $E7, $E7
  db $E8, $E8, $E8, $E9, $E9, $EA, $EA, $EB
  db $EB, $EC, $EC, $ED, $ED, $EE, $EF, $EF
  db $F0, $F0, $F1, $F2, $F2, $F3, $F4, $F4
  db $F5, $F6, $F6, $F7, $F8, $F8, $F9, $FA
  db $FB, $FB, $FC, $FD, $FE, $FE, $FF, $00


