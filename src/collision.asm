; ==============================================================================
; Routine: check_background_collision
; Description: Checks if the player's ship is touching a solid map tile.
; Outputs:
;   Carry Flag (C) = SET if crashed into ground, RESET if safe.
; ==============================================================================
check_background_collision:
  ; --- 1. Check Y - Are we low enough to hit the ground? ---
  ld a, (player_y)
  add a, 15            ; Hotspot Y: Bottom edge of your 16-pixel tall ship
  cp 192               ; Playfield Row 1 starts at Y=192
  jr c, bg_safe        ; If Y < 192, we are flying in the sky! Safe.

  ; --- 2. Calculate Map Row ---
  ; We know A >= 192. Subtract 192 to get the pixel offset into the ground.
  sub 192
  srl a
  srl a
  srl a                ; Divide by 8 to get the row index
  ld b, a              ; B = Map Row (0, 1, or 2)

  ; --- 3. Calculate Absolute World X ---
  ; World X = camera_x (16-bit) + player_x (8-bit) + hotspot offset
  ld hl, (camera_x)
  ld a, (player_x)
  add a, 15            ; Hotspot X: Center of your 30-pixel wide ship
  ld e, a
  ld d, 0              ; DE = player_x + 15
  add hl, de           ; HL = Absolute World X  

  ; --- 4. Calculate Map Column ---
  ; Divide World X by 8 to get the column index
  srl h
  rr l
  srl h
  rr l
  srl h
  rr l
  ld a, l
  and 127              ; Mask to 127 because your map array wraps at 128!
  ld c, a              ; C = Map Column (0 to 127)

  ; --- 5. Find the Address in playfield_map ---
  ld hl, playfield_map
  ld e, c
  ld d, 0
  add hl, de           ; HL = playfield_map + Column
  
  ld a, b              ; Get Row index back
  or a                 ; Is it row 0?
  jr z, check_tile_id  ; If yes, skip adding row offsets
  
  ld de, 128           ; Row stride length (128 bytes per row)
add_row_loop:
  add hl, de           ; Add 128 for each row we need to drop down
  dec a
  jr nz, add_row_loop

check_tile_id:
  ; --- 6. Read the Tile and Test Solidity ---
  ld a, (hl)           ; Read the Tile ID from the map array!
  
  cp 8                 ; Is it tile _8 (Ground Top Edge)?
  jr z, bg_hit
  cp 14                ; Is it tile _E (Solid Ground)?
  jr z, bg_hit

bg_safe:
  or a                 ; Clear carry flag (Safe)
  ret

bg_hit:
  scf                  ; Set carry flag (Crashed!)
  ret

