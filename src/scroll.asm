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


; ==============================================================================
; Routine: handle_scroll_input
; Description: Increments camera_x by 1 pixel every time spacebar is pressed,
;              and writes the offset to VDP Registers 26 and 27.
; ==============================================================================
handle_scroll_input:
  call scan_keypad
  ld e, a                    ; Save current key state in E

  ; --- Debounce Logic ---
  ld a, (prev_space_key)
  bit KEY_SPACE_BIT, a
  jr z, .save_and_exit       ; If it was already pressed, skip the update

  bit KEY_SPACE_BIT, e
  jr nz, .save_and_exit      ; If it is not pressed now, skip the update

  ; --- Perform the Scroll ---
  ld hl, (camera_x)
  inc hl
  ld (camera_x), hl

  ; 1. Calculate and write R#26 (8-pixel block offset)
  ld a, l
  rrca                       ; Shift right 3 times to divide by 8
  rrca
  rrca
  and 31                     ; Mask to 0-31 (since 1 page is 32 blocks wide)
  
  out (VDP_CONTROL_PORT), a
  ld a, 26 + 128             ; Select Register 26 + Write Flag
  out (VDP_CONTROL_PORT), a

  ; 2. Calculate and write R#27 (1-pixel fine scroll offset)
  ld a, l
  and 7                      ; Keep only the lowest 3 bits (camera_x MOD 8)
  
  out (VDP_CONTROL_PORT), a
  ld a, 27 + 128             ; Select Register 27 + Write Flag
  out (VDP_CONTROL_PORT), a

.save_and_exit:
  ld a, e
  ld (prev_space_key), a
  ret



