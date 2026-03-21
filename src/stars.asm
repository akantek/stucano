flip_stars:
  ; Update Stars (Parameterized)
  ld a, (stars_flag)
  or a                    ; Check if stars_flag == 0
  jr nz, .use_array1

.use_array0:
  ld hl, stars_array0     ; HL = Array to erase
  ld de, stars_array1     ; DE = Array to draw
  ld a, 1                 ; Next state will be 1
  jr .apply_stars

.use_array1:
  ld hl, stars_array1     ; HL = Array to erase
  ld de, stars_array0     ; DE = Array to draw
  xor a                   ; Next state will be 0 (A = 0)

.apply_stars:
  ld (stars_flag), a      ; Toggle the flag for the next cycle

  ; Save the 'draw' and 'erase' pointers to the stack
  push de                 ; Save array to draw (bottom of stack)
  push hl                 ; Save array to erase (top of stack)

  ; --- Erase Old Stars ---
  ld c, 0                 ; Target Page 0
  call erase_stars

  pop hl                  ; Retrieve array to erase again (clears it from stack)
  ld c, 1                 ; Target Page 1
  call erase_stars

  ; --- Draw New Stars ---
  pop hl                  ; Retrieve array to draw (was DE originally)
  push hl                 ; Put it right back for Page 1
  ld c, 0                 ; Target Page 0
  call draw_stars

  pop hl                  ; Retrieve array to draw again (clears it from stack)
  ld c, 1                 ; Target Page 1
  call draw_stars
  ret


; ==============================================================================
; Routine: erase_stars (Optimized)
; Input:   C = Target Page (0 or 1)
;          HL = Pointer to the star array data
; ==============================================================================
erase_stars:
  push hl
  pop ix                 

.erase_stars_loop:
  ld l, (ix+0)               ; Read X
  ld a, l
  cp 255                     ; Terminator?
  ret z                      

  ld e, (ix+1)               ; Read Y
  ld d, c                    ; D = Page (0 or 1)
  ld b, 0                    ; FORCE COLOR TO BLACK (0) TO ERASE

  call wait_vdp_ready

  ; --- 1. Set DX (R#36 & R#37) ---
  ld a, l
  out (VDP_CONTROL_PORT), a
  ld a, 128 + 36
  out (VDP_CONTROL_PORT), a
  
  xor a
  out (VDP_CONTROL_PORT), a
  ld a, 128 + 37
  out (VDP_CONTROL_PORT), a

  ; --- 2. Set DY (R#38 & R#39) ---
  ld a, e
  out (VDP_CONTROL_PORT), a
  ld a, 128 + 38
  out (VDP_CONTROL_PORT), a
  
  ld a, d
  out (VDP_CONTROL_PORT), a
  ld a, 128 + 39
  out (VDP_CONTROL_PORT), a

  ; --- 3. Set Color (R#44) ---
  ld a, b
  out (VDP_CONTROL_PORT), a
  ld a, 128 + 44
  out (VDP_CONTROL_PORT), a

  ; --- 4. Execute PSET Command (R#46) ---
  ld a, $50
  out (VDP_CONTROL_PORT), a
  ld a, 128 + 46
  out (VDP_CONTROL_PORT), a

  inc ix
  inc ix
  inc ix
  jr .erase_stars_loop


; ==============================================================================
; Routine: draw_stars (Optimized)
; Input:   HL = the array of stars to draw
; Input:   C = Target Page (0 or 1)
; ==============================================================================
draw_stars:
  push hl
  pop ix

.draw_stars_loop:
  ld l, (ix+0)               ; Read X coordinate
  ld a, l
  cp 255                     ; Check for Terminator
  ret z                      ; If yes, exit!

  ld e, (ix+1)               ; Read Y coordinate
  ld d, c                    ; D gets the Page Number (0 or 1)
  ld b, (ix+2)               ; Read Color

  ; Wait for previous VDP command to finish BEFORE sending new ones.
  ; By doing this here, the CPU was able to read the array data in parallel 
  ; while the VDP was finishing the last star!
  call wait_vdp_ready

  ; --- 1. Set DX (Destination X: R#36 & R#37) ---
  ld a, l
  out (VDP_CONTROL_PORT), a
  ld a, 128 + 36
  out (VDP_CONTROL_PORT), a
  
  xor a                      ; X High byte is always 0 (stars are < 256 wide)
  out (VDP_CONTROL_PORT), a
  ld a, 128 + 37
  out (VDP_CONTROL_PORT), a

  ; --- 2. Set DY (Destination Y: R#38 & R#39) ---
  ld a, e
  out (VDP_CONTROL_PORT), a
  ld a, 128 + 38
  out (VDP_CONTROL_PORT), a
  
  ld a, d                    ; Page number acts directly as Y High Byte!
  out (VDP_CONTROL_PORT), a
  ld a, 128 + 39
  out (VDP_CONTROL_PORT), a

  ; --- 3. Set Color (R#44) ---
  ld a, b
  out (VDP_CONTROL_PORT), a
  ld a, 128 + 44
  out (VDP_CONTROL_PORT), a

  ; --- 4. Execute PSET Command (R#46) ---
  ld a, $50                  ; $50 = PSET
  out (VDP_CONTROL_PORT), a
  ld a, 128 + 46
  out (VDP_CONTROL_PORT), a

  ; Move to next star
  inc ix
  inc ix
  inc ix
  jr .draw_stars_loop


stars_array0:
  db 20, 20, YELLOW
  db 34, 40, WHITE
  db 112, 120, GREEN
  db 180, 50, LIGHT_BLUE
  db 200, 160, CYAN
  db 10, 150, GRAY
  db 45, 12, WHITE
  db 60, 80, LIGHT_BLUE
  db 88, 200, YELLOW
  db 130, 45, CYAN
  db 155, 170, GRAY
  db 190, 20, WHITE
  db 220, 110, LIGHT_YELLOW
  db 240, 60, LIGHT_BLUE
  db 5, 95, CYAN
  db 25, 205, WHITE
  db 50, 65, GRAY
  db 75, 140, LIGHT_BLUE
  db 95, 30, YELLOW
  db 115, 195, WHITE
  db 140, 100, CYAN
  db 165, 15, GRAY
  db 185, 135, LIGHT_YELLOW
  db 210, 85, WHITE
  db 235, 160, LIGHT_BLUE
  db 15, 55, GRAY
  db 30, 125, YELLOW
  db 65, 185, CYAN
  db 80, 5, WHITE
  db 105, 165, LIGHT_BLUE
  db 125, 75, GRAY
  db 150, 210, YELLOW
  db 175, 105, WHITE
  db 195, 40, CYAN
  db 225, 150, LIGHT_BLUE
  db 250, 25, GRAY
  db 40, 155, WHITE
  db 70, 90, LIGHT_YELLOW
  db 100, 115, CYAN
  db 160, 60, WHITE
  db 255

stars_array1:
  db 12, 180, CYAN
  db 240, 15, WHITE
  db 85, 99, GREEN
  db 150, 45, LIGHT_BLUE
  db 55, 190, GRAY
  db 199, 110, YELLOW
  db 33, 22, LIGHT_YELLOW
  db 210, 175, WHITE
  db 78, 60, CYAN
  db 105, 130, LIGHT_BLUE
  db 16, 88, GRAY
  db 134, 50, YELLOW
  db 222, 140, WHITE
  db 92, 15, GREEN
  db 170, 195, LIGHT_BLUE
  db 48, 105, CYAN
  db 201, 70, GRAY
  db 115, 200, LIGHT_YELLOW
  db 5, 80, WHITE
  db 250, 160, YELLOW
  db 88, 35, CYAN
  db 145, 120, LIGHT_BLUE
  db 65, 185, GREEN
  db 190, 95, GRAY
  db 25, 150, WHITE
  db 110, 25, LIGHT_YELLOW
  db 230, 65, CYAN
  db 40, 170, LIGHT_BLUE
  db 175, 5, YELLOW
  db 95, 145, WHITE
  db 130, 180, GRAY
  db 10, 115, GREEN
  db 215, 40, CYAN
  db 70, 165, LIGHT_BLUE
  db 155, 85, WHITE
  db 245, 190, YELLOW
  db 50, 55, LIGHT_YELLOW
  db 185, 135, GRAY
  db 120, 10, WHITE
  db 80, 195, CYAN
  db 255

