; ==============================================================================
; Routine: update_auto_scroll
; Description: Automatically pans the camera backward (background flows Left-to-Right)
;              based on a frame timer.
; ==============================================================================
update_auto_scroll:
  ; --- 1. Speed Control ---
  ld hl, scroll_timer
  inc (hl)
  ld a, (hl)
  cp 2               ; Scroll speed: 2 = 30fps (1 pixel every 2 frames)
  ret c              ; If timer < 2, exit and wait for next frame

  ld (hl), 0         ; Reset timer to 0

  ; --- 2. Advance the Camera (Distance Traveled) ---
  ld hl, (camera_x)
  inc hl
  ld (camera_x), hl

  ; --- 3. Update VDP Hardware Registers (Reverse Direction) ---
  
  ; 1. Calculate Fine Scroll (R#27)
  ; Feeds the lower 3 bits directly. This pushes the image RIGHT.
  ld a, (camera_x)
  and 7
  out (VDP_CONTROL_PORT), a
  ld a, 27 + 128
  out (VDP_CONTROL_PORT), a

  ; 2. Calculate Coarse Scroll (R#26)
  ; Since the fine scroll pushes RIGHT, the coarse scroll must also 
  ; advance in the negative direction to keep the seam smooth!
  ld a, (camera_x)
  rrca
  rrca
  rrca
  and 31
  neg              ; INVERT the coarse scroll!
  and 31           ; Mask again to keep it 0-31
  out (VDP_CONTROL_PORT), a
  ld a, 26 + 128
  out (VDP_CONTROL_PORT), a

  ; --- 4. The Seam Check ---
  ; Did the camera just cross an 8-pixel boundary?
  ld a, (camera_x)
  and 7
  ret nz             ; If not exactly 0, we are done for this frame.

  ; If we reach this line, the camera has shifted exactly 1 full tile (8 pixels).
  ; Fetch the new tile for the LEFT edge and hide it in the mask!
  call draw_next_map_column
  
  ret


; ==============================================================================
; Routine: draw_next_map_column
; Description: Fetches the previous column from the map (left edge) and draws
;              it into the hidden 8-pixel mask area on both VRAM pages.
; ==============================================================================
draw_next_map_column:
  ; --- 1. Calculate Target Map Column ---
  ; We need to safely divide the 16-bit camera_x by 8
  ld hl, (camera_x)
  srl h
  rr l
  srl h
  rr l
  srl h
  rr l            ; HL = camera_x / 8
  
  ; We are moving backwards, so we negate the column!
  ; Fast 16-bit negate: 0 - HL
  ld de, 0
  ex de, hl       ; DE = camera_x / 8, HL = 0
  or a            ; Clear carry flag
  sbc hl, de      ; HL = 0 - (camera_x / 8)
  
  ; Mask to 127 to loop infinitely around our 128-tile map
  ld a, l
  and 127
  ld l, a
  ld h, 0
  
  ; Add the base address of our map array
  ld de, playfield_map
  add hl, de      ; HL now safely points to Row 1 of the map!

  ; --- 2. Calculate VRAM Dest X ---
  ; The hidden column on the left side is exactly R#26 * 8
  ld a, (camera_x)
  rrca
  rrca
  rrca
  and 31
  neg
  and 31
  rlca
  rlca
  rlca            ; Multiply back by 8 to get the pixel coordinate
  ld b, a         ; B = VRAM Dest X

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
  ld de, 128        ; <--- THE CRITICAL FIX: Reload 128 into DE!
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


