; --- RAM VARIABLES ---
OLD_HTIMI:       equ $C000  ; 5 Bytes ($C000-$C004)
vsync_flag:      equ $C005  ; 1 Byte
frame_count:     equ $C006  ; 1 Byte
active_page:     equ $C007  ; 0 = Page 0 is visible, 1 = Page 1 is visible
page_ready_flip: equ $C008  ; NEW: 0 = Not Ready, 1 = Ready to flip
stars_flag:      equ $C009  ; 2 Bytes indicating which array of stars to draw
camera_x:        equ $C00A  ; 2 bytes to track scroll position

; Player variables
player_x:                   equ $C00C
player_y:                   equ $C00D
player_anim_frame_counter:  equ $C00E
player_anim_state:          equ $C00F

; Missile
missile_x:       equ $C010
missile_y:       equ $C011
missile_state:   equ $C012
missile_old_x_0: equ $C013  ; Old X position on Page 0
missile_old_y_0: equ $C014  ; Old Y position on Page 0
missile_old_x_1: equ $C015  ; Old X position on Page 1
missile_old_y_1: equ $C016  ; Old Y position on Page 1

; MSX Helicopter variables
msx_heli_frame_counter: equ $C017  ; 1 Byte - MSX helicopter frame counter
msx_heli_pattern:       equ $C018  ; 1 Byte - MSX helicopter sprite pattern

; ---------------------------------------------------------
; Shadow Sprite Attribute Table (SAT) in RAM
; 1 Sprite = 4 Bytes
; ---------------------------------------------------------
shadow_sat:     equ $C020

; Player sprite A
playerA_y:       equ $C020   ; Byte 0: Y Coordinate
playerA_x:       equ $C021   ; Byte 1: X Coordinate
playerA_pat:     equ $C022   ; Byte 2: Pattern Number
playerA_ignored: equ $C023   ; Byte 3: ignored
; Player sprite B
playerB_y:       equ $C024   ; Byte 0: Y Coordinate
playerB_x:       equ $C025   ; Byte 1: X Coordinate
playerB_pat:     equ $C026   ; Byte 2: Pattern Number
playerB_ignored: equ $C027   ; Byte 3: ignored
; Player sprite C
playerC_y:       equ $C028   ; Byte 0: Y Coordinate
playerC_x:       equ $C029   ; Byte 1: X Coordinate
playerC_pat:     equ $C02A   ; Byte 2: Pattern Number
playerC_ignored: equ $C02B   ; Byte 3: ignored
; Player sprite D
playerD_y:       equ $C02C   ; Byte 0: Y Coordinate
playerD_x:       equ $C02D   ; Byte 1: X Coordinate
playerD_pat:     equ $C02E   ; Byte 2: Pattern Number
playerD_ignored: equ $C02F   ; Byte 3: ignored

; MSX helicopter 1 A
msx_heli1A_y:   equ $C030   ; Byte 4: Y Coordinate
msx_heli1A_x:   equ $C031   ; Byte 5: X Coordinate
msx_heli1A_pat: equ $C032   ; Byte 6: Pattern Number
msx_heli1A_ign: equ $C033   ; Byte 7: ignored
; MSX helicopter 1 B
msx_heli1B_y:   equ $C034   ; Byte 8: Y Coordinate
msx_heli1B_x:   equ $C035   ; Byte 9: X Coordinate
msx_heli1B_pat: equ $C036   ; Byte 10: Pattern Number
msx_heli1B_ign: equ $C037   ; Byte 11: ignored
; MSX helicopter 2 A
msx_heli2A_y:   equ $C038   ; Byte 4: Y Coordinate
msx_heli2A_x:   equ $C039   ; Byte 5: X Coordinate
msx_heli2A_pat: equ $C03A   ; Byte 6: Pattern Number
msx_heli2A_ign: equ $C03B   ; Byte 7: ignored
; MSX helicopter 2 B
msx_heli2B_y:   equ $C03C   ; Byte 8: Y Coordinate
msx_heli2B_x:   equ $C03D   ; Byte 9: X Coordinate
msx_heli2B_pat: equ $C03E   ; Byte 10: Pattern Number
msx_heli2B_ign: equ $C03F   ; Byte 11: ignored
; MSX helicopter 3 A
msx_heli3A_y:   equ $C040   ; Byte 4: Y Coordinate
msx_heli3A_x:   equ $C041   ; Byte 5: X Coordinate
msx_heli3A_pat: equ $C042   ; Byte 6: Pattern Number
msx_heli3A_ign: equ $C043   ; Byte 7: ignored
; MSX helicopter 3 B
msx_heli3B_y:   equ $C044   ; Byte 8: Y Coordinate
msx_heli3B_x:   equ $C045   ; Byte 9: X Coordinate
msx_heli3B_pat: equ $C046   ; Byte 10: Pattern Number
msx_heli3B_ign: equ $C047   ; Byte 11: ignored

shadow_sat_end: equ $C047   ; End of the 4-byte block

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

; Intro variables
prev_space_key:        equ $C10F
intro_flash_state:     equ $C110  ; 1 byte - Tracks if text is currently drawn (0) or blank (1)
intro_flash_delay:     equ $C111  ; 1 byte - Number of frames to wait before blinking push_space_key
intro_frame_countdown: equ $C112  ; 1 byte - Number of frames to wait after pressing space key

scroll_timer:    equ $C113  ; 1 byte - Controls automatic scroll speed

