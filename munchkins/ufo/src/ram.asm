; --- RAM VARIABLES ---
OLD_HTIMI:       equ $C000  ; 5 Bytes ($C000-$C004)
vsync_flag:      equ $C00A  ; 1 Byte
frame_count:     equ $C00B  ; 1 Byte
active_page:     equ $C00C  ; 0 = Page 0 is visible, 1 = Page 1 is visible
page_ready_flip: equ $C00D  ; NEW: 0 = Not Ready, 1 = Ready to flip

; UFO related vars
ufo_angle:       equ $C00E  ; 1 Byte, Tracks position in the sine table
ufo_base_y:      equ $C00F  ; 1 Byte, Tracks the UFO's center Y line

; ---------------------------------------------------------
; Shadow Sprite Attribute Table (SAT) in RAM
; 1 Sprite = 4 Bytes
; (The padding from $C01A to $C01F was consumed by the shift. 
;  shadow_sat safely remains at $C020)
; ---------------------------------------------------------
shadow_sat:     equ $C020

; MSX UFO
msx_ufo_y:       equ $C020   ; Byte 0: Y Coordinate
msx_ufo_x:       equ $C021   ; Byte 1: X Coordinate
msx_ufo_pat:     equ $C022   ; Byte 2: Pattern Number
msx_ufo_ignored: equ $C023   ; Byte 3: ignored

shadow_sat_end: equ $C023    ; End of the 4-byte block

; ---------------------------------------------------------
; HMMM Data Template (15 bytes)
; This maps exactly to VDP Registers 32 through 46
; ---------------------------------------------------------
hmmm_command_table: equ $C100
source_x:           equ $C100  ; 2 bytes (R#32, 33)
source_y:           equ $C102  ; 2 bytes (R#34, 35)
dest_x:             equ $C104  ; 2 bytes (R#36, 37)
dest_y:             equ $C106  ; 2 bytes (R#38, 39)
width:              equ $C108  ; 2 bytes (R#40, 41)
height:             equ $C10A  ; 2 bytes (R#42, 43)
color:              equ $C10C  ; 1 byte  (R#44)
argument:           equ $C10D  ; 1 byte  (R#45)
command:            equ $C10E  ; 1 byte  (R#46)

