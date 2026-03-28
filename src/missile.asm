; ==============================================================================
; Routine: draw_centered_missile
; Description: Uses HMMM to draw missile_A_left and missile_A_right
; ==============================================================================
draw_centered_missile_old:
  ; Spawn missile_A_left
  ld hl, 0       ; Source X = 0
  ld de, 520     ; Source Y = 520 (Page 2 base 512 + 8 pixels down)
  ld b, 124      ; Dest X = 124 (Center screen minus 4 pixels)
  ld c, 180      ; Dest Y = 102 (Center screen minus 4 pixels)
  call draw_tile_to_both_pages

  ; Spawn missile_A_right  
  ld hl, 8       ; Source X = 0
  ld de, 520     ; Source Y = 520 (Page 2 base 512 + 8 pixels down)
  ld b, 132      ; Dest X = 132 (Center screen minus 4 pixels)
  ld c, 180      ; Dest Y = 102 (Center screen minus 4 pixels)
  call draw_tile_to_both_pages  
  ret


draw_centered_missile:
  ; Spawn the complete 16x8 missile in one pass
  ld hl, 0       ; Source X = 0 (Starts at the left tile)
  ld de, 520     ; Source Y = 520 (Page 2 base 512 + 8 pixels down)
  ld b, 124      ; Dest X = 124 
  ld c, 180      ; Dest Y = 180
  
  call draw_16x8_to_both_pages
  ret


; ==============================================================================
; Routine: draw_16x8_to_both_pages
; Description: Uses HMMM to copy a 16x8 block (two adjacent tiles) 
;              to the same X/Y on Pages 0 and 1.
; Inputs:
;   HL = Source X (0-255)
;   DE = Source Y (512+)
;   B  = Destination X (0-255)
;   C  = Destination Y (0-211)
; ==============================================================================
draw_16x8_to_both_pages:
  ; --- 1. Set Source Coordinates ---
  ld (source_x), hl
  ld (source_y), de

  ; --- 2. Set Destination X ---
  ld l, b
  ld h, 0
  ld (dest_x), hl

  ; --- 3. Set Destination Y (Page 0) ---
  ld l, c
  ld h, 0
  ld (dest_y), hl

  ; --- 4. Set Dimensions & Command ---
  ld hl, 16                ; <--- CHANGED: 16 pixels wide!
  ld (width), hl           
  ld hl, 8                 
  ld (height), hl          ; 8 pixels tall
  
  ld a, $D0                ; $D0 = HMMM Command
  ld (command), a

  ; --- 5. Draw to Page 0 ---
  call execute_hmmm
  call wait_vdp_ready

  ; --- 6. Draw to Page 1 ---
  ld hl, (dest_y)          
  ld de, 256
  add hl, de               ; Add 256 to Y coordinate for Page 1
  ld (dest_y), hl

  call execute_hmmm
  call wait_vdp_ready
  ret

