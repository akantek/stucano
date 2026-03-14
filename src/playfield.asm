; ==============================================================================
; Routine: draw_playfield
; Input:   A = Target Page (0 or 1)
; ==============================================================================
draw_playfield:
  ld c, a
  call draw_stars
  ret


; ==============================================================================
; Routine: draw_stars
; Input:   C = Target Page (0 or 1)
; ==============================================================================
draw_stars:
  ; ix = hl (ix now contains the address of the stars array)
  push hl
  pop ix

.draw_stars_loop:
  ; --- Check for Terminator ---
  ld a, (ix+0)           ; Read the X coordinate
  cp 255                 ; Is it -1 ($FF)?
  ret z                  ; If yes, exit!

  ; --- Load Coordinates and Color ---
  ld l, a
  ld h, 0                ; HL = X coordinate

  ld e, (ix+1)           ; Read the Y coordinate (low byte)
  ld d, c                ; DE = Y coordinate. D gets the Page Number (0 or 1)!

  ld a, (ix+2)           ; Read the Color

  ; --- Draw to the Targeted Page ---
  push bc                ; Save the page parameter (C)
  push ix                ; Save the array pointer
  
  call draw_point        ; Plot the pixel

  ; --- Move to Next Star ---
  pop ix                 ; Restore our array pointer
  pop bc                 ; Restore our page parameter
  
  inc ix                 ; Move to next X
  inc ix                 ; Move to next Y
  inc ix                 ; Move to next Color
  jr .draw_stars_loop    ; Jump back to the top of the loop


; ==============================================================================
; Routine: erase_stars
; Input:   C = Target Page (0 or 1)
;          HL = Pointer to the star array data
; ==============================================================================
erase_stars:
  push hl
  pop ix                 

.erase_stars_loop:
  ld a, (ix+0)           ; Read X
  cp 255                 ; Terminator?
  ret z                  

  ld l, a
  ld h, 0                ; HL = X

  ld e, (ix+1)           ; Read Y
  ld d, c                ; D = Page (0 or 1)

  ; FORCE COLOR TO BLACK (0) TO ERASE
  xor a                  

  push bc                
  push ix                
  call draw_point        ; Draw a black pixel over the old star
  pop ix                 
  pop bc                 
  
  inc ix                 
  inc ix                 
  inc ix                 
  jr .erase_stars_loop


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

