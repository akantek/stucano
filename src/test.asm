; $1F (Page 0) starts at VRAM $0000 (Y=0)
; $3F (Page 1) starts at VRAM $8000 (Y=256)
; $5F (Page 2) starts at VRAM $10000 (Y=512)
; $7F (Page 3) starts at VRAM $18000 (Y=768)
testTilesheet:
  ; 1. Point VDP Register 2 to Page 2 ($5F = VRAM $10000)
  ld a, $5F
  di
  out (VDP_CONTROL_PORT), a
  ld a, 2 + 128
  out (VDP_CONTROL_PORT), a
  ei

  ; 2. Turn the screen on so we can see it
  call ENASCR

  ; 3. Wait 300 frames (approx 10 seconds at 60Hz) showing Page 2
  ld bc, 300
  call WaitFrames

  ; 4. Turn the screen back off
  call DISSCR

  ; 5. Restore VDP Register 2 back to Page 0 ($1F = VRAM $0000)
  ld a, $1F
  di
  out (VDP_CONTROL_PORT), a
  ld a, 2 + 128
  out (VDP_CONTROL_PORT), a
  ei

  ret

; -----------------------------------------------------------------------------
; Subroutine: WaitFrames
; Purpose: Waits for a specified number of VSYNCs.
; Inputs: BC = number of frames to wait
; Destroys: A, BC
; -----------------------------------------------------------------------------
WaitFrames:
  ld a, b                ; Check if BC is already 0 before starting
  or c
  ret z                  ; If BC is 0, return immediately to avoid underflow

.loop:
  push bc                ; Save our 16-bit counter
  call wait_vsync        ; Wait for 1 frame 
  pop bc                 ; Restore counter
  dec bc                 ; Subtract 1
  ld a, b                ; Check if BC is 0
  or c
  jr nz, .loop           ; If not 0, loop again
  
  ret


