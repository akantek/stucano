; ==============================================================================
; Routine: clear_vram_page
; Input:   A = Page Number (0, 1, 2, or 3)
; ==============================================================================
clear_vram_page:
  ; Initialize HMMV parameters
  ld hl, 0
  ld (dest_x), hl      ; Start at X=0

  ld h, a
  ld l, 0
  ld (dest_y), hl

  ld hl, 256
  ld (width), hl       ; 256 pixels wide
  ld hl, 212
  ld (height), hl      ; 212 pixels tall

  xor a
  ld (color), a 
  ld (argument), a

  ld a, $C0            ; $C0 => Command HMMV
  ld (command), a

  call execute_hmmm    ; This routine sends the table to VDP
  ret

; ==============================================================================
; Routine:      execute_hmmm
; Description:  Sends the 15-byte RAM table to VDP to execute a hardware copy.
; ==============================================================================
execute_hmmm:
  call wait_vdp_ready

  ; 1. Tell the VDP we want to start writing at Register #32
  ;    We write this to VDP Register 17 (Indirect Register Pointer)
  ld a, 32
  out (VDP_CONTROL_PORT), a     ; Send data (32) to Port $99
  ld a, 128 + 17                ; 128 (Write Flag) + 17 (Register #17)
  out (VDP_CONTROL_PORT), a     ; Send to Port $99

  ; 2. Blast the 15 bytes from RAM to the VDP incredibly fast!
  ld hl, hmmm_command_table     ; Point Z80 to our RAM table
  ld c, VDP_INDIRECT_PORT       ; Use Port $9B for indirect writing
  ld b, 15                      ; We want to send 15 bytes
  otir                          ; Hardware Loop: OUT (C), (HL) / INC HL / DEC B

  ret

; ==============================================================================
; Routine: wait_vdp_ready
; Purpose: Halts the Z80 until the VDP finishes drawing
; ==============================================================================
wait_vdp_ready:
  ; 1. Tell VDP we want to read status register 2
  ld a, 2
  di
  out (VDP_CONTROL_PORT), a
  ld a, 15 + 128                ; Register #15 + Write Flag
  out (VDP_CONTROL_PORT), a

  ; 2. Spin lock
.wait_vdp_ready
  in a, (VDP_CONTROL_PORT)      ; Read status register 2
  rrca                          ; bit 0 is the CE (command executing) flag
                                ; rrca is faster than `and 1`
  jr c, .wait_vdp_ready         ; if Carry is 1 (VDP is busy), keep spinning

  ; 3. Cleanup: set status register back to 0
  ;    Required so VBlank interrupt can read the screen refresh flag later
  xor a
  out (VDP_CONTROL_PORT), a
  ld a, 15 + 128
  out (VDP_CONTROL_PORT), a
  ei
  ret

; ==============================================================================
; Routine: flip_page
; Description: Toggles the display between Page 0 and Page 1.
;              Updates Register #2 and flips the 'active_page' variable.
; ==============================================================================
flip_page:
  ld a, (active_page)
  or a
  jr nz, .show_page_0

.show_page_1:
  ld a, 1
  ld (active_page), a      ; Mark Page 1 as the visible one
  ld a, $3F                ; Value for Reg #2 to point to VRAM $8000
  jr .update_vdp

.show_page_0:
  xor a
  ld (active_page), a      ; Mark Page 0 as the visible one
  ld a, $1F                ; Value for Reg #2 to point to VRAM $0000

.update_vdp:
  out (VDP_CONTROL_PORT), a  ; Send value to VDP
  ld a, 2 + 128              ; Write to Register #2
  out (VDP_CONTROL_PORT), a
  ret

