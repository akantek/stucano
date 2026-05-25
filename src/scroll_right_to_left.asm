; ==============================================================================
; Routine: update_auto_scroll
; Description: Automatically pans the camera forward (background flows Right-to-Left)
; ==============================================================================
update_auto_scroll:
  ; --- 1. Speed Control ---
  ld hl, scroll_timer
  inc (hl)
  ld a, (hl)
  cp 2               ; Scroll speed: 2 = 30fps (1 pixel every 2 frames)
  ret c              ; If timer < 2, exit and wait for next frame

  ld (hl), 0         ; Reset timer to 0

  ; --- 2. Advance the Camera (Moving Forward) ---
  ld hl, (camera_x)
  inc hl             ; Incrementing moves the camera RIGHT
  ld (camera_x), hl

  ; --- 3. Update VDP Hardware Registers ---
  
  ; 1. Calculate Fine Scroll (R#27)
  ; R#27 natively pushes the image right. To scroll left, we negate 
  ; the lower 3 bits so it counts backwards (7, 6, 5... 0)
  ld a, (camera_x)
  neg                
  and 7
  out (VDP_CONTROL_PORT), a
  ld a, 27 + 128
  out (VDP_CONTROL_PORT), a

  ; 2. Calculate Coarse Scroll (R#26)
  ; Coarse scroll must advance 8 pixels at a time. Because the fine 
  ; scroll acts "backwards", we add 7 to round up the division safely.
  ld a, (camera_x)
  add a, 7           ; Round up to the next 8-pixel chunk
  rrca
  rrca
  rrca
  and 31
  out (VDP_CONTROL_PORT), a
  ld a, 26 + 128
  out (VDP_CONTROL_PORT), a

  ; --- 4. The Seam Check ---
  ; Did the camera just cross an 8-pixel boundary?
  ld a, (camera_x)
  and 7
  ret nz             ; If not exactly 0, we are done for this frame.

  ; Fetch the new tile for the RIGHT edge and hide it in the mask!
  call draw_next_map_column
  
  ret


; ==============================================================================
; Routine: draw_next_map_column
; Description: Fetches the next column from the map (right edge) and draws
;              it into the hidden 8-pixel mask area on both VRAM pages.
; ==============================================================================
draw_next_map_column:
  ; --- 1. Calculate Target Map Column ---
  ; Divide the 16-bit camera_x by 8
  ld hl, (camera_x)
  srl h
  rr l
  srl h
  rr l
  srl h
  rr l               ; HL = camera_x / 8
  
  ; We are moving forward, so we need the tile that is about to appear
  ; on the RIGHT edge. Since the screen shows 32 columns, add 32.
  ld de, 32
  add hl, de         ; HL = (camera_x / 8) + 32
  
  ; Mask to 127 to loop infinitely around our 128-tile map
  ld a, l
  and 127
  ld l, a
  ld h, 0
  
  ; Add the base address of our map array
  ld de, playfield_map
  add hl, de         ; HL now points to Row 1 of the new rightmost map column

  ; --- 2. Calculate VRAM Dest X ---
  ; Because we are scrolling right-to-left, the hardware wrap is perfectly 
  ; linear. We are always writing to the column that just moved under the mask.
  ; Since this routine only runs when (camera_x & 7 == 0), the X destination 
  ; is exactly the lower 8 bits of camera_x, constrained to 8-pixel blocks.
  ld a, (camera_x)
  and 248            ; Mask out the bottom 3 bits (0, 8, 16... 248)
  ld b, a            ; B = VRAM Dest X

  ; --- 3. Blast the 3 Tiles to VRAM ---
  
  ; Draw Row 1 (Y=192)
  ld a, (hl)        
  ld c, 192         
  call blast_map_tile
  
  ; Draw Row 2 (Y=200)
  ld de, 128        
  add hl, de
  ld a, (hl)
  ld c, 200
  call blast_map_tile
  
  ; Draw Row 3 (Y=208)
  ld de, 128        
  add hl, de
  ld a, (hl)
  ld c, 208
  call blast_map_tile
  
  ret


; ==============================================================================
; Helper Routine: blast_map_tile
; Inputs: A = Tile ID, B = Dest X, C = Dest Y (for Page 0)
; ==============================================================================
blast_map_tile:
  push hl
  push bc
  push de           ; <--- THE CRITICAL FIX: Protect DE!

  ; 1. Set Source X (Tile ID * 8)
  ld l, a
  ld h, 0
  add hl, hl        ; *2
  add hl, hl        ; *4
  add hl, hl        ; *8
  ld (source_x), hl
  
  ; 2. Set Source Y (Always 512 for your tilesheet on Page 2)
  ld hl, 512
  ld (source_y), hl

  ; 3. Set Destination X
  ld l, b
  ld h, 0
  ld (dest_x), hl

  ; 4. Set Destination Y (Page 0)
  ld l, c
  ld h, 0
  ld (dest_y), hl

  ; 5. Set Dimensions (8x8 tile)
  ld hl, 8
  ld (width), hl
  ld (height), hl

  ; 6. Set Command ($D0 = HMMM)
  ld a, $D0
  ld (command), a

  ; 7. Execute on Page 0
  call execute_hmmm
  call wait_vdp_ready

  ; 8. Modify Y coordinate and Execute on Page 1
  ld hl, (dest_y)
  ld de, 256        ; (This was destroying your DE loop counter!)
  add hl, de
  ld (dest_y), hl
  
  call execute_hmmm
  call wait_vdp_ready

  pop de            ; <--- THE CRITICAL FIX: Restore DE!
  pop bc
  pop hl
  ret

; The Single-Page Wrap (Register #25)
; The MSX2+ horizontal scroll doesn't have to span 512 pixels.
; By configuring VDP Register #25, you can tell the hardware to wrap the 
; horizontal scroll around a single 256-pixel page.

; The 8-Pixel Mask Trick
; Register 25 also has a "Mask" bit (MSK). When enabled, it forces the leftmost
; 8 pixels of the screen (X=0 to 7) to display the border color, creating a permanent
; 8-pixel "blind spot."

; Here is the update cycle:

; You scroll the camera by incrementing Register 26 (H-Scroll Offset).

; Whenever the camera moves 8 pixels, you figure out which VRAM X-coordinate is currently hidden behind the mask.

; You copy (using HMMM) the new vertical column of tiles from Page 2 into that hidden X-coordinate on BOTH Page 0 and Page 1

; With this, you just write your scroll offset to R#26, and you can freely flip between Page 0 and Page 1 for your software sprites without touching Page 2 or worrying about your hardware sprite tables.

setUpHorizontalScroll:
  call _hideLeft8Pixels

  ld a, $0c  ; 4 pixels to the left
  call shiftDisplay

  call init_scroll

  ret

_hideLeft8Pixels:
  ; Enable 1-Page Wrap and Mask Left 8 Pixels
  ld a, 2
  out (VDP_CONTROL_PORT), a
  ld a, 25 + 128            ; Write to Register 25
  out (VDP_CONTROL_PORT), a
  ret


; ==============================================================================
; Routine: init_scroll
; Description: Configures VDP Register 25 for 1-page wrap and 8-pixel left mask
; ==============================================================================
init_scroll:
  ld a, 2                    ; Bit 1 (MSK) = 1, Bit 0 (SP2) = 0
  out (VDP_CONTROL_PORT), a
  ld a, 25 + 128             ; Write to Register 25
  out (VDP_CONTROL_PORT), a

  ; Initialize R#26 to 0 just to be safe
  xor a
  out (VDP_CONTROL_PORT), a
  ld a, 26 + 128
  out (VDP_CONTROL_PORT), a
  ret



