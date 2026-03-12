; ==============================================================================
; MSX HARDWARE & BIOS DEFINITIONS
; ==============================================================================

; --- MSX BIOS Entry Points ---
DISSCR:  equ $0041  ; Disable screen display
ENASCR:  equ $0044  ; Enable screen display
CHGMOD:  equ $005F  ; Change VDP Screen Mode (Input: A)
CHGCLR:  equ $0062  ; Apply Foreground/Background/Border colors

; --- MSX System Variables ---
CLIKSW:  equ $F3DB  ; Key Click Switch (0=Off, 1=On)
FORCLR:  equ $F3E9  ; Foreground Color Storage
BAKCLR:  equ $F3EA  ; Background Color Storage
BDRCLR:  equ $F3EB  ; Border Color Storage

; --- MSX Colors ---
TRANSPARENT:  equ 0
BLACK:        equ 1
DARK_GREEN:   equ 2
LIGHT_GREEN:  equ 3
DARK_BLUE:    equ 4
CYAN:         equ 5
RED:          equ 6
LIGHT_BLUE:   equ 7
DARK_RED:     equ 8
LIGHT_RED:    equ 9
YELLOW:       equ 10
LIGHT_YELLOW: equ 11
GREEN:        equ 12
MAGENTA:      equ 13
GRAY:         equ 14
WHITE:        equ 15

