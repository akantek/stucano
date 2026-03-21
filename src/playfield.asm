drawPlayfield:
  ; Draw tile 8 array
  ld hl, draw_tile_playfield
  call draw_tile_generic_array

  ; Draw tile E_1 array
  ld hl, draw_tile_playfield2
  call draw_tile_generic_array

  ; Draw tile E_2 array
  ld hl, draw_tile_playfield3
  call draw_tile_generic_array
  ret

; Expects: HL = Address of the specific tile drawing routine
draw_tile_generic_array:
  ld b, 32
  ld ix, 0
.draw_tile_generic_array_loop:
  push bc
  push ix
  push hl                ; Save the routine address for the next iteration

  ; The "Trampoline" call
  call call_hl_routine   ; This calls the address currently in HL

  pop hl                 ; Restore the routine address
  pop ix
  pop bc

  ld de, 8
  add ix, de
  djnz .draw_tile_generic_array_loop
  ret

; --- The Trampoline ---
call_hl_routine:
  jp (hl)

draw_tile_playfield:
  ld hl, 0
  ld (source_x), hl      ; Tile 8 Source X
  ld hl, 512
  ld (source_y), hl    ; Source Y
  ld hl, 0 + (8 * 24)               ; Dest Y Offset
  jr execute_tile_copy

draw_tile_playfield2:
  ld hl, 8
  ld (source_x), hl      ; Tile E1 Source X
  ld hl, 512
  ld (source_y), hl
  ld hl, 0 + (8 * 24) + 8           ; Dest Y Offset
  jr execute_tile_copy

draw_tile_playfield3:
  ld hl, 8
  ld (source_x), hl      ; Tile E2 Source X
  ld hl, 512
  ld (source_y), hl
  ld hl, 0 + (8 * 24) + 16          ; Dest Y Offset
  jr execute_tile_copy

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

