; ==============================================================================
; THE VRAM "GHOSTING" PROBLEM & THE $D8 TERMINATOR
;
; The MSX2 VDP does not automatically clear VRAM between frames. If you 
; update your active sprites but leave the rest of the 32-sprite table 
; unmanaged, the hardware will continue reading leftover memory and 
; render unwanted "ghost" sprites on the screen.
;
; THE SOLUTION:
; You must use the hardware's built-in Sprite Terminator. If the VDP reads 
; a Y-coordinate of $D8 (216) in SCREEN 5, it instantly stops drawing that 
; sprite and aborts rendering for all subsequent lower-priority sprites 
; for the remainder of the frame.
;
; HOW TO SET IT UP:
; 1. Allocate an extra sprite immediately after your active ones.
; 2. Initialize this terminator sprite's first byte (Y) to $D8:
;    db $D8, 0, 0, 0  ; Terminator Sprite
; 3. When transferring to VRAM, ensure your sprite count parameter 
;    includes this terminator (e.g., to draw 1 sprite, transfer 2).
; ==============================================================================

