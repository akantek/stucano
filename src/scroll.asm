; ==============================================================================
; Routine: check_and_draw_new_column
; Description: Checks if the camera has moved far enough to require a new 
;              column. If so, calculates the VRAM X and draws to both pages.
; ==============================================================================
check_and_draw_new_column:
  ld hl, (camera_x)
  
  ; 1. Get the current grid column (Camera X / 8)
  ld a, l
  rrca
  rrca
  rrca
  and 31                ; A = current column index (0 to 31)
  
  ; 2. Have we already drawn this column?
  ld b, a               ; Save current column index in B
  ld a, (last_column_x)
  cp b
  ret z                 ; If it's the same as last frame, do nothing!
  
  ; 3. Save the new column index so we don't draw it again next frame
  ld a, b
  ld (last_column_x), a

  ; 4. Calculate the VRAM Destination X (Snap Camera X to 8px grid)
  ld a, l
  and 248               ; %11111000 - Snaps to 0, 8, 16... 240, 248
  ld (dest_x), a        ; Set the destination X for your drawing routine

  ; 5. Draw the vertical strip to PAGE 0
  ld hl, 0              ; Y offset for Page 0
  ld (dest_y), hl
  call draw_map_column  ; -> the routine to blast 1 column of tiles

  ; 6. Draw the EXACT SAME vertical strip to PAGE 1
  ld hl, 256            ; Y offset for Page 1
  ld (dest_y), hl
  call draw_map_column  ; -> the routine to blast 1 column of tiles

  ret


