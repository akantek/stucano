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

  call ENASCR
  ei

  ; Start page flipping
  ld hl, page_ready_flip
  ld (hl), 1

.game_loop:
  call wait_vsync        ; Spin until vblank is fired
.vblank_trace_start:
  ; frame_count++
  ld hl, frame_count
  inc (hl)

  call flip_page
.vblank_trace_end:

  ; if (frame_count == 60) {beep! && frame_count = 0}
  ld hl, frame_count
  ld a, (hl)
  cp 60
  jr nz, .game_loop

  ld (hl), 0
  call BEEP
  
  ; Update Stars (Parameterized)
  ld a, (stars_flag)
  or a                    ; Check if stars_flag == 0
  jr nz, .use_array1

.use_array0:
  ld hl, stars_array0     ; HL = Array to erase
  ld de, stars_array1     ; DE = Array to draw
  ld a, 1                 ; Next state will be 1
  jr .apply_stars

.use_array1:
  ld hl, stars_array1     ; HL = Array to erase
  ld de, stars_array0     ; DE = Array to draw
  xor a                   ; Next state will be 0 (A = 0)

.apply_stars:
  ld (stars_flag), a      ; Toggle the flag for the next cycle

  ; Save the 'draw' and 'erase' pointers to the stack
  push de                 ; Save array to draw (bottom of stack)
  push hl                 ; Save array to erase (top of stack)

  ; --- Erase Old Stars ---
  ld c, 0                 ; Target Page 0
  call erase_stars

  pop hl                  ; Retrieve array to erase again (clears it from stack)
  ld c, 1                 ; Target Page 1
  call erase_stars

  ; --- Draw New Stars ---
  pop hl                  ; Retrieve array to draw (was DE originally)
  push hl                 ; Put it right back for Page 1
  ld c, 0                 ; Target Page 0
  call draw_stars

  pop hl                  ; Retrieve array to draw again (clears it from stack)
  ld c, 1                 ; Target Page 1
  call draw_stars

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
  ld a, 1
  call clear_vram_page
  call wait_vdp_ready

  ret


; --- RAM VARIABLES ---
OLD_HTIMI:       equ $C000  ; 5 Bytes ($C000-$C004)
vsync_flag:      equ $C005  ; 1 Byte
frame_count:     equ $C006  ; 1 Byte
active_page:     equ $C007  ; 0 = Page 0 is visible, 1 = Page 1 is visible
page_ready_flip: equ $C008  ; NEW: 0 = Not Ready, 1 = Ready to flip
stars_flag:      equ $C009  ; 2 Bytes indicating which array of stars to draw

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

