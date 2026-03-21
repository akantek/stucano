; Formula for HL: HL=(Y * 128) + X/2
loadTilesheet:
  ; --- STEP 1: Draw tile8 to Page 2 ---
  ; Page 2 starts at Bank 4 (each bank is 16KB, Page 2 is at 64KB)
  ; In Screen 5, Page 2 Y-offset is 512.
  ld hl, 0            ; Top-left of the page
  ld a, 4             ; Bank 4 = Page 2 (VRAM $10000)
  ld ix, tile8
  call drawTile

  ld hl, 4              ; lin:0, pos:1
  ld a, 4               ; Bank 4 - Page 2 (VRAM $10000)
  ld ix, tileE
  call drawTile

  ld hl, 8              ; lin:0, pos:1
  ld a, 4               ; Bank 4 - Page 2 (VRAM $10000)
  ld ix, tank_left
  call drawTile

  ld hl, 12              ; lin:0, pos:1
  ld a, 4               ; Bank 4 - Page 2 (VRAM $10000)
  ld ix, tank_right
  call drawTile

  ld hl, 16              ; lin:0, pos:1
  ld a, 4               ; Bank 4 - Page 2 (VRAM $10000)
  ld ix, tank_cannon
  call drawTile

  ret


; =============================================================================
; draw_tile: Draws an 8x8 tile (from mem to vram) in Screen 5
; Inputs: 
;   A  = Page/Bank (0 for Page 0, 2 for Page 1)
;   HL = VRAM Offset (0 to $3FFF)
;   IX = Pointer to 32-byte tile data
; =============================================================================
drawTile:
  ex af, af'          ; Store the Page/Bank byte in A'
    
    ; --- INITIALIZE SHADOW PORT ---
    exx
    ld c, VDP_DATA_PORT ; Pre-load $98 into alternate C for the "pixel blast"
    exx

    ld b, 8             ; 8 scanlines per tile
.draw_tile_line_loop:
    push bc
    push hl

    ; 1. SET VDP ADDRESS (17-bit addressing)
    ex af, af'
    push af             ; Keep page byte safe
    
    ; Set Register 14 (Bank)
    out (VDP_CONTROL_PORT), a
    ld a, 128 + 14
    out (VDP_CONTROL_PORT), a

    ; Set Low/High Address Bytes
    ld a, l
    out (VDP_CONTROL_PORT), a
    ld a, h
    or $40              ; Set Write Bit (Bit 6)
    out (VDP_CONTROL_PORT), a
    
    pop af              ; Restore page byte to A
    ex af, af'          ; Put back in A' for next line

    ; 2. PRE-LOAD TILE DATA
    exx
    ld h, (ix+0)	; Pixel 1 & 2
    ld l, (ix+1)	; Pixel 3 & 4
    ld d, (ix+2)	; Pixel 5 & 6
    ld e, (ix+3)	; Pixel 7 & 8
    
    ; 3. DRAW LINE (The Pixel Blast)
    ; Since we are drawing 1 tile width, we don't need a nested DJNZ loop here.
    ; This is much faster.
    out (c), h          ; Pixels 1-2
    out (c), l          ; Pixels 3-4
    out (c), d          ; Pixels 5-6
    out (c), e          ; Pixels 7-8
    exx

    ; 4. PREPARE NEXT SCANLINE
    pop hl
    ld de, 128          ; 256 pixels / 2 = 128 bytes per line
    add hl, de
    
    ; Move IX to the next 4 bytes of tile data
    inc ix
    inc ix
    inc ix
    inc ix

    pop bc
    djnz .draw_tile_line_loop
    ret

