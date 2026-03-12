main:
  di
  ld sp, $f380  ; ROM standard SP initialization (move to top-of-RAM)

  call boot
  jr demo

demo:
  ; Init
  call ENASCR
  ei

.game_loop:
  call wait_vsync        ; Spin until vblank is fired
.vblank_trace_start:
  ; Update VRAM here
.vblank_trace_end:

  ; frame_count++
  ld hl, frame_count
  inc (hl)
  
  ; if (frame_count == 60) {beep! && frame_count = 0}
  ld a, (hl)
  cp 60
  jr nz, .game_loop

  ld (hl), 0
  call BEEP
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
  
  ; Clean VRAM page 1 for double buffering
  ld a, 1
  call clear_vram_page
  call wait_vdp_ready

  ret

; --- RAM VARIABLES ---
OLD_HTIMI:      equ $C000  ; 5 Bytes ($C000-$C004)
vsync_flag:     equ $C005  ; 1 Byte
frame_count:    equ $C006  ; 1 Byte

; ---------------------------------------------------------
; HMMM Data Template (15 bytes)
; This maps exactly to VDP Registers 32 through 46
; ---------------------------------------------------------
hmmm_command_table: equ $C100
source_x:           equ $C100  ; 2 bytes (R#32, 33)
source_y:           equ $C102  ; 2 bytes (R#34, 35)
dest_x:             equ $C104  ; 2 bytes (R#36, 37)
dest_y:             equ $C106  ; 2 bytes (R#38, 39)
width:              equ $C118  ; 2 bytes (R#40, 41)
height:             equ $C120  ; 2 bytes (R#42, 43)
color:              equ $C121  ; 1 byte  (R#44)
argument:           equ $C122  ; 1 byte  (R#45)
command:            equ $C123  ; 1 byte  (R#46)


