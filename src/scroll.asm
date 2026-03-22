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
  ret

_hideLeft8Pixels:
  ; Enable 1-Page Wrap and Mask Left 8 Pixels
  ld a, 2
  out (VDP_CONTROL_PORT), a
  ld a, 25 + 128            ; Write to Register 25
  out (VDP_CONTROL_PORT), a
  ret


