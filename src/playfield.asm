; --- Tile IDs ---
TILE_8: EQU 0  ; Source X = 0
TILE_E: EQU 1  ; Source X = 8

; --- Playfield Map Data ---
; Draws 3 rows of tiles (32 tiles per row = 256 pixels wide)
; Terminated by 255.
playfield_map:
  ; Row 1 (Y=192) - 32 tiles of TILE_8
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  ; Row 2 (Y=200) - 32 tiles of TILE_E
  db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
  ; Row 3 (Y=208) - 32 tiles of TILE_E
  db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
  db 255 ; End of map terminator

drawPlayfield:
  ld hl, playfield_map    ; Pointer to our map array
  ld b, 0                 ; Starting Dest X (0)
  ld c, 192               ; Starting Dest Y (192)
  call draw_tilemap
  ret

; ==============================================================================
; Routine: draw_tilemap
; Inputs:  HL = Address of tilemap array (terminated by 255)
;          B  = Starting Destination X
;          C  = Starting Destination Y
; ==============================================================================
draw_tilemap:
.tile_loop:
  ld a, (hl)              ; Read the next Tile ID from the array
  cp 255                  ; Is it the terminator?
  ret z                   ; If yes, we are done!

  ; Save our loop state before calling the VDP routines
  push hl                 ; Save map pointer
  push bc                 ; Save current X (B) and Y (C) coordinates

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
  ; Your execute_tile_copy routine expects Dest X in IX, and Dest Y in HL.
  
  ld l, b
  ld h, 0
  push hl
  pop ix                  ; Move current X (B) into IX

  ld l, c
  ld h, 0                 ; Move current Y (C) into HL

  ; --- 3. Blast the tile to Page 0 and Page 1 ---
  call execute_tile_copy

  ; Restore our loop state
  pop bc                  ; Restore X and Y coordinates
  pop hl                  ; Restore map pointer

  ; --- 4. Move to the next tile position ---
  ld a, b
  add a, 8                ; Move X right by 8 pixels
  ld b, a
  jr nc, .next_tile       ; If X didn't overflow 255, we are still on the same row

  ; If X overflowed (248 + 8 = 256, which is 0 in an 8-bit register), wrap to next line!
  ld a, c
  add a, 8                ; Move Y down by 8 pixels
  ld c, a                 ; Save new Y

.next_tile:
  inc hl                  ; Advance to the next byte in the map array
  jr .tile_loop           ; Repeat until we hit 255


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


