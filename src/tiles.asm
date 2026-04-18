; --- Tile IDs ---

; -- Row 1 (IDs 0 to 31) --
_0: EQU 0   ; tile0
_1: EQU 1   ; tile1
_2: EQU 2   ; tile2
_3: EQU 3   ; tile3
_4: EQU 4   ; tile4
_5: EQU 5   ; tile5
_6: EQU 6   ; tile6
_7: EQU 7   ; tile7
_8: EQU 8   ; tile8 (Playfield Map Row 1: Ground Top Edge)
_9: EQU 9   ; tile9
_A: EQU 10  ; tileA
_B: EQU 11  ; tileB
_C: EQU 12  ; tileC
_D: EQU 13  ; tileD
_E: EQU 14  ; tileE (Playfield Map Rows 2 & 3: Solid Ground)
_F: EQU 15  ; tileF
_G: EQU 16  ; tileG
_H: EQU 17  ; tileH
_I: EQU 18  ; tileI
_J: EQU 19  ; tileJ
_K: EQU 20  ; tileK
_L: EQU 21  ; tileL
_M: EQU 22  ; tileM
_N: EQU 23  ; tileN

; Entities (Still in Row 1)
TANK_CANNON:       EQU 24  ; tank_cannon
TANK_LEFT:         EQU 25  ; tank_left
TANK_RIGHT_1:      EQU 26  ; tank_right (First draw)
TANK_RIGHT_2:      EQU 27  ; tank_right (Second draw)
FUEL_BOTTOM_LEFT:  EQU 28  ; fuel_bottom_left
FUEL_BOTTOM_RIGHT: EQU 29  ; fuel_bottom_right
FUEL_UP_LEFT:      EQU 30  ; fuel_up_left
FUEL_UP_RIGHT:     EQU 31  ; fuel_up_right

; -- Row 2 (IDs 32 to 63) --
MISSILE_A_LEFT:    EQU 32  ; HL = 1024
MISSILE_A_RIGHT:   EQU 33  ; HL = 1028
MISSILE_B:         EQU 34  ; HL = 1032
MISSILE_C:         EQU 35  ; HL = 1036
SKULL_LEFT:        EQU 36  ; HL = 1040

; Formula for HL: HL=(Y * 128) + X/2
loadTilesheet:
  ; --- STEP 1: Draw tile8 to Page 2 ---
  ; Page 2 starts at Bank 4 (each bank is 16KB, Page 2 is at 64KB)
  ; In Screen 5, Page 2 Y-offset is 512.
  ld hl, 0            ; Top-left of the page
  ld a, 4             ; Bank 4 = Page 2 (VRAM $10000)
  ld ix, tile0
  call drawTile

  ld hl, 4              ; lin:0, pos:1
  ld a, 4               ; Bank 4 - Page 2 (VRAM $10000)
  ld ix, tile1
  call drawTile

  ld hl, 8              ; lin:0, pos:1
  ld a, 4               ; Bank 4 - Page 2 (VRAM $10000)
  ld ix, tile2
  call drawTile

  ld hl, 12              ; lin:0, pos:1
  ld a, 4               ; Bank 4 - Page 2 (VRAM $10000)
  ld ix, tile3
  call drawTile

  ld hl, 16              ; lin:0, pos:1
  ld a, 4               ; Bank 4 - Page 2 (VRAM $10000)
  ld ix, tile4
  call drawTile

  ld hl, 20
  ld a, 4
  ld ix, tile5
  call drawTile

  ld hl, 24              
  ld a, 4
  ld ix, tile6
  call drawTile

  ld hl, 28
  ld a, 4
  ld ix, tile7
  call drawTile

  ld hl, 32
  ld a, 4
  ld ix, tile8
  call drawTile

  ld hl, 36
  ld a, 4
  ld ix, tile9
  call drawTile

  ld hl, 40
  ld a, 4
  ld ix, tileA
  call drawTile

  ld hl, 44
  ld a, 4
  ld ix, tileB
  call drawTile

  ld hl, 48
  ld a, 4
  ld ix, tileC
  call drawTile

  ld hl, 52
  ld a, 4
  ld ix, tileD
  call drawTile

  ld hl, 56
  ld a, 4
  ld ix, tileE
  call drawTile

  ld hl, 60
  ld a, 4
  ld ix, tileF
  call drawTile

  ld hl, 64
  ld a, 4
  ld ix, tileG
  call drawTile

  ld hl, 68
  ld a, 4
  ld ix, tileH
  call drawTile

  ld hl, 72
  ld a, 4
  ld ix, tileI
  call drawTile

  ld hl, 76
  ld a, 4
  ld ix, tileJ
  call drawTile

  ld hl, 80
  ld a, 4
  ld ix, tileK
  call drawTile

  ld hl, 84
  ld a, 4
  ld ix, tileL
  call drawTile

  ld hl, 88
  ld a, 4
  ld ix, tileM
  call drawTile

  ld hl, 92
  ld a, 4
  ld ix, tileN
  call drawTile

  ld hl, 96
  ld a, 4
  ld ix, tank_cannon
  call drawTile

  ld hl, 100
  ld a, 4
  ld ix, tank_left
  call drawTile

  ld hl, 104
  ld a, 4
  ld ix, tank_right
  call drawTile

  ld hl, 108
  ld a, 4
  ld ix, tank_right
  call drawTile

  ld hl, 112
  ld a, 4
  ld ix, fuel_bottom_left
  call drawTile

  ld hl, 116
  ld a, 4
  ld ix, fuel_bottom_right
  call drawTile

  ld hl, 120
  ld a, 4
  ld ix, fuel_up_left
  call drawTile

  ld hl, 124
  ld a, 4
  ld ix, fuel_up_right
  call drawTile

; Next line: HL = (Y * 128) + X/2
; Row 2, Column 0 (X=0, Y=8): (8 * 128) + 0 = 1024
; Row 2, Column 1 (X=8, Y=8): (8 * 128) + 4 = 1028
; etc

  ld hl, 1024
  ld a, 4
  ld ix, missile_A_left
  call drawTile

  ld hl, 1028
  ld a, 4
  ld ix, missile_A_right
  call drawTile

  ld hl, 1032
  ld a, 4
  ld ix, missile_B
  call drawTile

  ld hl, 1036
  ld a, 4
  ld ix, missile_C
  call drawTile

  ld hl, 1040
  ld a, 4
  ld ix, skull_left
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

; ==============================================================================
; Routine: draw_tile_to_both_pages
; Description: Uses HMMM to copy an 8x8 tile to the same X/Y on Pages 0 and 1.
;
; Inputs:
;   HL = Source X (0-255)  - X coordinate of the tile in Page 2
;   DE = Source Y (512+)   - Y coordinate of the tile in Page 2
;   B  = Destination X (0-255)
;   C  = Destination Y (0-211)
;
; Destroys: A, BC, HL, DE
; ==============================================================================
draw_tile_to_both_pages:
  ; --- 1. Set Source Coordinates ---
  ld (source_x), hl
  ld (source_y), de

  ; --- 2. Set Destination X ---
  ld l, b
  ld h, 0
  ld (dest_x), hl          ; Write 16-bit X to HMMM table

  ; --- 3. Set Destination Y (Page 0) ---
  ld l, c
  ld h, 0
  ld (dest_y), hl          ; Write 16-bit Y for Page 0

  ; --- 4. Set Dimensions & Command ---
  ld hl, 8
  ld (width), hl           ; 8 pixels wide
  ld (height), hl          ; 8 pixels tall
  
  ld a, $D0                ; $D0 = HMMM Command
  ld (command), a

  ; --- 5. Draw to Page 0 ---
  call execute_hmmm
  call wait_vdp_ready      ; Wait for VDP to finish Page 0

  ; --- 6. Draw to Page 1 ---
  ; FIX: Read dest_y from RAM because execute_hmmm destroyed register C
  ld hl, (dest_y)          
  ld de, 256
  add hl, de               ; Add 256 to Y coordinate for Page 1
  ld (dest_y), hl

  call execute_hmmm
  call wait_vdp_ready      ; Wait for VDP to finish Page 1
  ret

