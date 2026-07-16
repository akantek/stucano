; --- RAM VARIABLES ---
OLD_HTIMI:       equ $C000  ; 5 Bytes ($C000-$C004)
vsync_flag:      equ $C00A  ; 1 Byte
frame_count:     equ $C00B  ; 1 Byte

player_hitbox:   equ $C00C  ; Y, X, H, W
enemy_hitbox:    equ $C010  ; Y, X, H, W

player_x:        equ $C011
player_y:        equ $C012

space_was_pressed: equ $C013  ; 1 Byte

active_sprites:    equ $C014  ; Dynamically tracks how many sprites to draw
fire1_x:           equ $C015  ; Bullet1 X coordinate
fire1_y:           equ $C016  ; Bullet1 Y coordinate
fire1_active:      equ $C017  ; 1 = Bullet1 is on screen, 0 = Off screen
fire2_x:           equ $C018  ; Bullet2 X coordinate
fire2_y:           equ $C019  ; Bullet2 Y coordinate
fire2_active:      equ $C01A  ; 1 = Bullet2 is on screen, 0 = Off screen
cooldown_timer:    equ $C01B  ; 7-frame cooldown between individual shots

; ---------------------------------------------------------
; Shadow Sprite Attribute Table (SAT) in RAM
; 1 Sprite = 4 Bytes, 32 Sprites Max (128 Bytes Total)
; Start Address: $C020
; End Address:   $C09F
; ---------------------------------------------------------
shadow_sat:      equ $C020

; Sprite 0
sprite0_y:       equ $C020   ; Byte 0: Y Coordinate
sprite0_x:       equ $C021   ; Byte 1: X Coordinate
sprite0_pat:     equ $C022   ; Byte 2: Pattern Number
sprite0_timer:   equ $C023   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 1
sprite1_y:       equ $C024   ; Byte 0: Y Coordinate
sprite1_x:       equ $C025   ; Byte 1: X Coordinate
sprite1_pat:     equ $C026   ; Byte 2: Pattern Number
sprite1_timer:   equ $C027   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 2
sprite2_y:       equ $C028   ; Byte 0: Y Coordinate
sprite2_x:       equ $C029   ; Byte 1: X Coordinate
sprite2_pat:     equ $C02A   ; Byte 2: Pattern Number
sprite2_timer:   equ $C02B   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 3
sprite3_y:       equ $C02C   ; Byte 0: Y Coordinate
sprite3_x:       equ $C02D   ; Byte 1: X Coordinate
sprite3_pat:     equ $C02E   ; Byte 2: Pattern Number
sprite3_timer:   equ $C02F   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 4
sprite4_y:       equ $C030   ; Byte 0: Y Coordinate
sprite4_x:       equ $C031   ; Byte 1: X Coordinate
sprite4_pat:     equ $C032   ; Byte 2: Pattern Number
sprite4_timer:   equ $C033   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 5
sprite5_y:       equ $C034   ; Byte 0: Y Coordinate
sprite5_x:       equ $C035   ; Byte 1: X Coordinate
sprite5_pat:     equ $C036   ; Byte 2: Pattern Number
sprite5_timer:   equ $C037   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 6
sprite6_y:       equ $C038   ; Byte 0: Y Coordinate
sprite6_x:       equ $C039   ; Byte 1: X Coordinate
sprite6_pat:     equ $C03A   ; Byte 2: Pattern Number
sprite6_timer:   equ $C03B   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 7
sprite7_y:       equ $C03C   ; Byte 0: Y Coordinate
sprite7_x:       equ $C03D   ; Byte 1: X Coordinate
sprite7_pat:     equ $C03E   ; Byte 2: Pattern Number
sprite7_timer:   equ $C03F   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 8
sprite8_y:       equ $C040   ; Byte 0: Y Coordinate
sprite8_x:       equ $C041   ; Byte 1: X Coordinate
sprite8_pat:     equ $C042   ; Byte 2: Pattern Number
sprite8_timer:   equ $C043   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 9
sprite9_y:       equ $C044   ; Byte 0: Y Coordinate
sprite9_x:       equ $C045   ; Byte 1: X Coordinate
sprite9_pat:     equ $C046   ; Byte 2: Pattern Number
sprite9_timer:   equ $C047   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 10
sprite10_y:      equ $C048   ; Byte 0: Y Coordinate
sprite10_x:      equ $C049   ; Byte 1: X Coordinate
sprite10_pat:    equ $C04A   ; Byte 2: Pattern Number
sprite10_timer:  equ $C04B   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 11
sprite11_y:      equ $C04C   ; Byte 0: Y Coordinate
sprite11_x:      equ $C04D   ; Byte 1: X Coordinate
sprite11_pat:    equ $C04E   ; Byte 2: Pattern Number
sprite11_timer:  equ $C04F   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 12
sprite12_y:      equ $C050   ; Byte 0: Y Coordinate
sprite12_x:      equ $C051   ; Byte 1: X Coordinate
sprite12_pat:    equ $C052   ; Byte 2: Pattern Number
sprite12_timer:  equ $C053   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 13
sprite13_y:      equ $C054   ; Byte 0: Y Coordinate
sprite13_x:      equ $C055   ; Byte 1: X Coordinate
sprite13_pat:    equ $C056   ; Byte 2: Pattern Number
sprite13_timer:  equ $C057   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 14
sprite14_y:      equ $C058   ; Byte 0: Y Coordinate
sprite14_x:      equ $C059   ; Byte 1: X Coordinate
sprite14_pat:    equ $C05A   ; Byte 2: Pattern Number
sprite14_timer:  equ $C05B   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 15
sprite15_y:      equ $C05C   ; Byte 0: Y Coordinate
sprite15_x:      equ $C05D   ; Byte 1: X Coordinate
sprite15_pat:    equ $C05E   ; Byte 2: Pattern Number
sprite15_timer:  equ $C05F   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 16
sprite16_y:      equ $C060   ; Byte 0: Y Coordinate
sprite16_x:      equ $C061   ; Byte 1: X Coordinate
sprite16_pat:    equ $C062   ; Byte 2: Pattern Number
sprite16_timer:  equ $C063   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 17
sprite17_y:      equ $C064   ; Byte 0: Y Coordinate
sprite17_x:      equ $C065   ; Byte 1: X Coordinate
sprite17_pat:    equ $C066   ; Byte 2: Pattern Number
sprite17_timer:  equ $C067   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 18
sprite18_y:      equ $C068   ; Byte 0: Y Coordinate
sprite18_x:      equ $C069   ; Byte 1: X Coordinate
sprite18_pat:    equ $C06A   ; Byte 2: Pattern Number
sprite18_timer:  equ $C06B   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 19
sprite19_y:      equ $C06C   ; Byte 0: Y Coordinate
sprite19_x:      equ $C06D   ; Byte 1: X Coordinate
sprite19_pat:    equ $C06E   ; Byte 2: Pattern Number
sprite19_timer:  equ $C06F   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 20
sprite20_y:      equ $C070   ; Byte 0: Y Coordinate
sprite20_x:      equ $C071   ; Byte 1: X Coordinate
sprite20_pat:    equ $C072   ; Byte 2: Pattern Number
sprite20_timer:  equ $C073   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 21
sprite21_y:      equ $C074   ; Byte 0: Y Coordinate
sprite21_x:      equ $C075   ; Byte 1: X Coordinate
sprite21_pat:    equ $C076   ; Byte 2: Pattern Number
sprite21_timer:  equ $C077   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 22
sprite22_y:      equ $C078   ; Byte 0: Y Coordinate
sprite22_x:      equ $C079   ; Byte 1: X Coordinate
sprite22_pat:    equ $C07A   ; Byte 2: Pattern Number
sprite22_timer:  equ $C07B   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 23
sprite23_y:      equ $C07C   ; Byte 0: Y Coordinate
sprite23_x:      equ $C07D   ; Byte 1: X Coordinate
sprite23_pat:    equ $C07E   ; Byte 2: Pattern Number
sprite23_timer:  equ $C07F   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 24
sprite24_y:      equ $C080   ; Byte 0: Y Coordinate
sprite24_x:      equ $C081   ; Byte 1: X Coordinate
sprite24_pat:    equ $C082   ; Byte 2: Pattern Number
sprite24_timer:  equ $C083   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 25
sprite25_y:      equ $C084   ; Byte 0: Y Coordinate
sprite25_x:      equ $C085   ; Byte 1: X Coordinate
sprite25_pat:    equ $C086   ; Byte 2: Pattern Number
sprite25_timer:  equ $C087   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 26
sprite26_y:      equ $C088   ; Byte 0: Y Coordinate
sprite26_x:      equ $C089   ; Byte 1: X Coordinate
sprite26_pat:    equ $C08A   ; Byte 2: Pattern Number
sprite26_timer:  equ $C08B   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 27
sprite27_y:      equ $C08C   ; Byte 0: Y Coordinate
sprite27_x:      equ $C08D   ; Byte 1: X Coordinate
sprite27_pat:    equ $C08E   ; Byte 2: Pattern Number
sprite27_timer:  equ $C08F   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 28
sprite28_y:      equ $C090   ; Byte 0: Y Coordinate
sprite28_x:      equ $C091   ; Byte 1: X Coordinate
sprite28_pat:    equ $C092   ; Byte 2: Pattern Number
sprite28_timer:  equ $C093   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 29
sprite29_y:      equ $C094   ; Byte 0: Y Coordinate
sprite29_x:      equ $C095   ; Byte 1: X Coordinate
sprite29_pat:    equ $C096   ; Byte 2: Pattern Number
sprite29_timer:  equ $C097   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 30
sprite30_y:      equ $C098   ; Byte 0: Y Coordinate
sprite30_x:      equ $C099   ; Byte 1: X Coordinate
sprite30_pat:    equ $C09A   ; Byte 2: Pattern Number
sprite30_timer:  equ $C09B   ; Byte 3: Animation Frame Counter (VDP ignored)

; Sprite 31 (Lowest Priority)
sprite31_y:      equ $C09C   ; Byte 0: Y Coordinate
sprite31_x:      equ $C09D   ; Byte 1: X Coordinate
sprite31_pat:    equ $C09E   ; Byte 2: Pattern Number
sprite31_timer:  equ $C09F   ; Byte 3: Animation Frame Counter (VDP ignored)

shadow_sat_end: equ $C09F   ; End of the 4-byte block

