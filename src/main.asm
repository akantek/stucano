PLAYER_Y_MIN:   equ 24

main:
  di
  ld sp, $f380  ; ROM standard SP initialization (move to top-of-RAM)

  call boot
  jr demo


demo:
  ; Init
  di

  ; Draw stars
  ld c, 0                 ; Target Page 0
  ld hl, stars_array0
  call draw_stars

  ld c, 1                 ; Target Page 1
  ld hl, stars_array0
  call draw_stars    

  ; Print strings
  ; Print the game title at Column 5, Row 2, on Page 0 and Page 1
  PRINT_AT 10, 10, 0, stucano_title_str
  PRINT_AT 10, 10, 1, stucano_title_str

  ; Print Kanteko
  PRINT_AT 10, 12, 0, kanteko_str
  PRINT_AT 10, 12, 1, kanteko_str

  ; Init sprites
  call initSpriteAttributes

  call ENASCR
  ei

  ; Start page flipping
  ld hl, page_ready_flip
  ld (hl), 1

.game_loop:
  call wait_vsync        ; Spin until vblank is fired
.vblank_trace_start:
  call loadSpriteAttributes
  call flip_page
.vblank_trace_end:

  ; Move MSX helicopters
  call moveMsxHelicopters
  call updateMsxHeliSpritePattern

  ; --- Two-Frame Star Twinkle Sync ---
  ld a, (frame_count)     
  inc a                   
  ld (frame_count), a     
  
  cp 59                   ; Is it Frame 60?
  jr z, .sync_frame_1
  
  cp 60                   ; Is it Frame 61?
  jr z, .sync_frame_2
  
  jr .skip_stars          ; Otherwise, do nothing

.sync_frame_1:
  ; Step 1: Flip the global state and update the first hidden page
  ld a, (stars_flag)
  xor 1
  ld (stars_flag), a
  call update_hidden_stars
  jr .skip_stars

.sync_frame_2:
  ; Step 2: The pages have swapped! Update the OTHER hidden page.
  call update_hidden_stars

  ; Reset the timer for the next second
  xor a
  ld (frame_count), a

.skip_stars:
  jr .game_loop


boot:
  ; COLOR 15,1,1
  ld a, WHITE
  ld (FORCLR), a  ; Store in Foreground system variable ($F3E9)
  ld a, BLACK
  ld (BAKCLR), a  ; Store in Background system variable ($F3EA)
  ld (BDRCLR), a  ; Store in Border system variable ($F3EB)
  call CHGCLR     ; BIOS Call ($0062): Update VDP registers with new colors

  ; SCREEN 5
  ld a, 5         ; Screen mode 5 (256x212, 16 colors - MSX2)
  call CHGMOD

  ; CLICK OFF
  xor a
  ld (CLIKSW), a  ; Set Click Switch ($F3DB) to 0

  ; SCREEN OFF
  call DISSCR

  ; Install VBlank hook
  call install_vblank_hook
  ei
   
  ; Clean VRAM page 1 for double buffering
  ; Note: the following code (clear vram + wait vdp)
  ;   takes around 64.4 milliseconds.
  ld a, 1
  call clear_vram_page
  call wait_vdp_ready

  ; Set sprite size
  call enable_16x16_sprites

  ; Load sprites patterns and colors
  call loadSpritePatterns
  call loadSpriteColors
  ret


; --- RAM VARIABLES ---
OLD_HTIMI:       equ $C000  ; 5 Bytes ($C000-$C004)
vsync_flag:      equ $C005  ; 1 Byte
frame_count:     equ $C006  ; 1 Byte
active_page:     equ $C007  ; 0 = Page 0 is visible, 1 = Page 1 is visible
page_ready_flip: equ $C008  ; NEW: 0 = Not Ready, 1 = Ready to flip
stars_flag:      equ $C009  ; 2 Bytes indicating which array of stars to draw

; MSX Helicopter variables
msx_heli_frame_counter: equ $C00A  ; 1 Byte - MSX helicopter frame counter
msx_heli_pattern:       equ $C00B  ; 1 Byte - MSX helicopter sprite pattern

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

shadow_sat_end: equ $C03F   ; End of the 4-byte block

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

