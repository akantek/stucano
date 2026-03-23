; --- Tile IDs ---
TILE_8: EQU 0  ; Source X = 0
TILE_E: EQU 1  ; Source X = 8

MAP_WIDTH: EQU 128
SCREEN_TILES_X: EQU 32

; Playfield Map Data (128 tiles wide x 3 rows tall)
playfield_map:
  ; Row 1 (Y=192) - 128 tiles (0s)
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

  ; Row 2 (Y=200) - 128 tiles (1s)
  db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
  db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
  db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
  db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

  ; Row 3 (Y=208) - 128 tiles (1s)
  db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
  db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
  db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
  db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

; ==============================================================================
; Routine: drawPlayfield
; Description: Draws the initial 32x3 visible window from the 128-wide map
; ==============================================================================
drawPlayfield:
  ld hl, playfield_map    ; Pointer to the top-left of our map array
  ld c, 192               ; Starting Dest Y (192)
  ld d, 3                 ; We have 3 rows to draw

drawPF_row_loop:
  ld b, 0                 ; Starting Dest X (0) for each new row
  ld e, SCREEN_TILES_X    ; Draw 32 tiles per row to fill the screen

  push hl                 ; Save the pointer to the start of this row in the map

drawPF_col_loop:
  ld a, (hl)              ; Read the Tile ID

  ; --- Save our loop state before calling VDP routines ---
  push hl                 ; Save map pointer
  push bc                 ; Save current Dest X (B) and Dest Y (C)
  push de                 ; Save our Row (D) and Col (E) counters

  ; --- 1. Calculate Source X (Tile ID * 8) ---
  ld l, a
  ld h, 0
  add hl, hl              ; * 2
  add hl, hl              ; * 4
  add hl, hl              ; * 8
  ld (source_x), hl       ; Set Source X for VDP

  ld hl, 512
  ld (source_y), hl       ; Source Y is always 512 for your tilesheet

  ; --- 2. Setup Destination for execute_tile_copy ---
  ld l, b
  ld h, 0
  push hl
  pop ix                  ; Move current X (B) into IX

  ld l, c
  ld h, 0                 ; Move current Y (C) into HL

  ; --- 3. Blast the tile to Page 0 and Page 1 ---
  call execute_tile_copy

  ; --- Restore our loop state ---
  pop de                  ; Restore Row and Col counters
  pop bc                  ; Restore Dest X and Dest Y
  pop hl                  ; Restore map pointer

  ; --- 4. Move to the next column ---
  ld a, b
  add a, 8                ; Move Dest X right by 8 pixels
  ld b, a

  inc hl                  ; Advance map pointer by 1 to get the next tile
  dec e                   ; Decrement column counter
  jr nz, drawPF_col_loop  ; Repeat until 32 columns are drawn

  ; --- 5. Move to the next row ---
  ld a, c
  add a, 8                ; Move Dest Y down by 8 pixels
  ld c, a

  ; Advance the map pointer to the start of the NEXT row
  pop hl                  ; Restore pointer to the start of the CURRENT row
  push de                 ; Temporarily save counters so we can use DE
  ld de, MAP_WIDTH        ; Load the stride length (128 bytes)
  add hl, de              ; Jump to the start of the next row
  pop de                  ; Restore counters

  dec d                   ; Decrement row counter
  jr nz, drawPF_row_loop  ; Repeat until 3 rows are drawn
  
  ret


execute_tile_copy:
  push hl                ; Save the base Dest Y (e.g., 192 for Page 0)
  push ix
  pop de
  ld (dest_x), de        ; Set Destination X based on the loop counter (IX)

  pop hl                 ; Restore the base Dest Y
  ld (dest_y), hl        ; Set Destination Y (e.g., 192 for Page 0)
    
  ld hl, 8
  ld (width), hl         ; Set copy width to 8 pixels
  ld (height), hl        ; Set copy height to 8 pixels
    
  ld a, $D0              ; Load $D0 (The MSX2 VDP command for HMMM)
  ld (command), a
    
  ; --- FIRST COPY: PAGE 0 ---
  call execute_hmmm      ; Send the 15-byte table to VDP. It copies from Y=512 to Y=192
  call wait_vdp_ready    ; Halt Z80 until VDP is done

  ; --- SECOND COPY: PAGE 1 ---
  ld hl, (dest_y)        ; Load the current Destination Y (192)
  ld de, 256             ; Load 256 (the height of one VRAM page)
  add hl, de             ; Add them together (192 + 256 = 448)
  ld (dest_y), hl        ; Save the new Destination Y (448 is inside Page 1)
    
  call execute_hmmm      ; Send the table to VDP again. It copies from Y=512 to Y=448
  call wait_vdp_ready    ; Halt Z80 until VDP is done
  ret
