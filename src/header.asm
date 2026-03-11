; ==============================================================================
; MSX HARDWARE & BIOS DEFINITIONS
; ==============================================================================

; --- MSX BIOS Entry Points ---
DISSCR:  equ $0041  ; Disable screen display
ENASCR:  equ $0044  ; Enable screen display
CHGMOD:  equ $005f  ; Change VDP Screen Mode (Input: A)
CHGCLR:  equ $0062  ; Apply Foreground/Background/Border colors

