; ==========================================================
; 1. HANDLE MISSILE SPAWN
; ==========================================================
handleMissleSpawn:
  call scan_keypad
  bit KEY_SHIFT_BIT, a       ; Check if SHIFT is pressed
  jr nz, .skip_missile_spawn ; 1 = not pressed. Skip spawning.

  ; Check if a missile is ALREADY flying
  ld a, (missile_state)
  or a
  jr nz, .skip_missile_spawn

  ; Spawn the missile!
  ld a, 1
  ld (missile_state), a

  ; Play sound
  ; call play_missile_fire   ; bad, too slow

  ; Set starting X and initialize old positions to match
  ld a, (playerA_x)
  add a, 10
  ld (missile_x), a
  ld (missile_old_x_0), a
  ld (missile_old_x_1), a

  ; Set starting Y and initialize old positions to match
  ld a, (playerA_y)
  add a, 10
  ld (missile_y), a
  ld (missile_old_y_0), a
  ld (missile_old_y_1), a

.skip_missile_spawn:

  ; ==========================================================
  ; 2. UPDATE AND DRAW ACTIVE MISSILE
  ; ==========================================================
  ld a, (missile_state)
  or a
  jp z, .missile_done        ; If state is 0, skip entirely

  ; Determine which page is currently HIDDEN (0 or 1)
  ld a, (active_page)
  xor 1                      ; Flip bit to get hidden page
  ld b, a                    ; B = target hidden page

  ; --- ERASE OLD MISSILE ON HIDDEN PAGE ---
  call erase_hidden_missile

  ; --- UPDATE MISSILE POSITION ---
  ld a, (missile_x)
  add a, 4                   ; Missile speed (4 pixels per frame)
  ld (missile_x), a

  cp 240                     ; Check max X limit (Screen is 256, missile is 16)
  jr c, .draw_missile

  ; Missile reached edge - deactivate
  xor a
  ld (missile_state), a

; Ghost fix: Since the missile died this frame, we immediately force an 
  ; erase on the OTHER page right now so it doesn't leave a ghost next frame.
  ld a, b
  xor 1
  ld b, a
  call erase_hidden_missile
  jr .missile_done

.draw_missile:
  ; --- DRAW NEW MISSILE ON HIDDEN PAGE ---
  call draw_hidden_missile

.missile_done:
  ret


; ==============================================================================
; Routine: erase_hidden_missile
; Inputs: B = Target Hidden Page (0 or 1)
; Description: Uses LMMV to fill the old position with Black (Color 0)
; ==============================================================================
erase_hidden_missile:
  ; 1. Fetch the correct old coordinates based on Page
  ld a, b
  or a
  jr z, .erase_page0

.erase_page1:
  ld a, (missile_old_x_1)
  ld l, a
  ld a, (missile_old_y_1)
  ld e, a
  jr .do_erase

.erase_page0:
  ld a, (missile_old_x_0)
  ld l, a
  ld a, (missile_old_y_0)
  ld e, a
  
.do_erase:
  ; 2. Set Destination X
  ld h, 0
  ld (dest_x), hl

  ; 3. Set Destination Y (E = Low Byte, B = High Byte)
  ld d, b
  ld (dest_y), de
  
  ; 4. Set Width/Height
  ld hl, 16
  ld (width), hl
  ld hl, 8
  ld (height), hl
  
  ; 5. Set Fill Color (Black = 0) and clear logical operation (0)
  xor a
  ld (color), a
  ld (argument), a
  
  ; 6. Execute LMMV Command ($80) - Pixel Perfect Fill
  ld a, $80
  ld (command), a
  
  push bc             ; <--- CRITICAL FIX: Save B (Target Page)
  call execute_hmmm
  pop bc              ; <--- CRITICAL FIX: Restore B
  
  call wait_vdp_ready
  ret

; ==============================================================================
; Routine: draw_hidden_missile
; Inputs: B = Target Hidden Page (0 or 1)
; Description: Copies missile from Page 2 and updates the "old" coord trackers
; ==============================================================================
draw_hidden_missile:
  ; 1. Save current coords as the "old" coords for this specific page
  ld a, b
  or a
  jr z, .save_page0

.save_page1:
  ld a, (missile_x)
  ld (missile_old_x_1), a
  ld a, (missile_y)
  ld (missile_old_y_1), a
  jr .do_draw

.save_page0:
  ld a, (missile_x)
  ld (missile_old_x_0), a
  ld a, (missile_y)
  ld (missile_old_y_0), a

.do_draw:
  ; 2. Set Source X, Y (Page 2, X=0, Y=520)
  ld hl, 0
  ld (source_x), hl
  ld hl, 520
  ld (source_y), hl

  ; 3. Set Destination X
  ld a, (missile_x)
  ld l, a
  ld h, 0
  ld (dest_x), hl

  ; 4. Set Destination Y (Low=missile_y, High=B)
  ld a, (missile_y)
  ld e, a
  ld d, b
  ld (dest_y), de

  ; 5. Set Width/Height
  ld hl, 16
  ld (width), hl
  ld hl, 8
  ld (height), hl

  ; 6. Execute LMMM Command ($90) - Pixel Perfect Copy
  ld a, $90
  ld (command), a
  
  push bc             ; <--- CRITICAL FIX: Save B
  call execute_hmmm
  pop bc              ; <--- CRITICAL FIX: Restore B
  
  call wait_vdp_ready
  ret


