; ==============================================================================
; enable_16x16_sprites
; One-time VDP initialization to set Sprite Size to 16x16 pixels.
;
; NOTES:
;   - Modifies VDP Register 1.
;   - Updates the RG1SAV BIOS mirror.
;   - Should be called during startup (boot) sequence.
;   - Assumes interrupts are disabled (DI) or no VDP activity is occurring.
; ==============================================================================
enable_16x16_sprites:
  ld a, (RG1SAV)             ; Get current Register 1 value from BIOS mirror
  or $02                     ; Set Bit 1 to Enable 16x16 sprites (0=8x8,1=16x16)
  ld (RG1SAV), a             ; Update mirror so BIOS remembers the change

  out (VDP_CONTROL_PORT), a  ; Step 1: Send the DATA (latches it in VDP)
  ld a, 1 + 128              ; Prep Command: Register Index (1) + Write Flag ($80)
  out (VDP_CONTROL_PORT), a  ; Step 2: Send COMMAND to move latched data into Reg 1
  ret


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


; ==============================================================================
; write_vram_large
; Transfers a block of data from RAM to VRAM using a 16-bit counter.
;
; INPUTS:
;   HL = Source Address (RAM)
;   DE = Destination Address (VRAM)
;   BC = Length (Bytes)
;   A  = VRAM Bank Number
;
; [!] CRITICAL WARNING:
;   You MUST execute DI (Disable Interrupts) before calling this function.
;   If an interrupt fires during the VDP address setup, the VDP latch 
;   will be corrupted, writing data to the wrong address.
; ==============================================================================
write_vram_large:
  push AF                    ; Preserve Bank # (in A) for the first OUT

  ; --- 1. Set VRAM Bank (Reg 14) ---
  out (VDP_CONTROL_PORT), A  ; Data: Send Bank Number
  ld  A, 14 or $80           ; CMD:  Register 14 + Write Flag ($80)
  out (VDP_CONTROL_PORT), A  ; Latch data into Reg 14

  ; --- 2. Set VRAM Address ---
  pop AF                     ; Clean up stack (value in A is no longer needed)
  ld  A, E
  out (VDP_CONTROL_PORT), a  ; Send Low Byte (A0-A7)

  ld  a, d
  and $3F                    ; Safety: Mask to valid address range
  or  $40                    ; Set Bit 6: Enable "Write" Mode
  out (VDP_CONTROL_PORT), a  ; Send High Byte (A8-A13) + Setup VDP for writing

  ; --- 3. Transfer Data ---
  ; Fixed: Removed 'ld c, port' to preserve BC counter

  ld  a, b
  or  c
  ret z                      ; Return immediately if BC (Size) is 0

.write_vram_large_loop:
  ld  a, (hl)                ; Read byte from RAM
  out (VDP_DATA_PORT), a     ; Write byte to VDP
  inc hl                     ; Next RAM address
  dec bc                     ; Decrement 16-bit counter
  ld  a, b
  or  c                      ; Check if BC == 0
  jr  nz, .write_vram_large_loop
  ret


; ==============================================================================
; write_vram_fast
; High-speed VRAM transfer using the Z80 OTIR instruction.
;
; INPUTS:
;   HL = Source Address (RAM)
;   DE = Destination Address (VRAM)
;   C  = Length (Low Byte of BC). Max 256 bytes.
;   A  = VRAM Bank Number
;
; NOTES:
;   - [!] LIMITATION: The counter uses Register B (8-bit). 
;         Maximum transfer size is 256 bytes. 
;         If you pass BC > 256, only the lower byte (C) is used.
;   - SAFETY: This routine handles its own DI/EI internally. 
;         It is safe to call from anywhere, even if interrupts are enabled.
; ==============================================================================
write_vram_fast:
  push af                    ; Preserve Bank # (in A)

  ; --- 1. Set VRAM Bank (Reg 14) ---
  di                         ; Disable Interrupts: Critical for VDP latch atomicity
  out (VDP_CONTROL_PORT), a  ; Data: Send Bank Number
  ld  a, 14 or $80           ; CMD:  Register 14 + Write Flag
  out (VDP_CONTROL_PORT), a  ; Latch data into Reg 14

  ; --- 2. Set VRAM Address ---
  pop af                     ; Clean stack (A not needed)
  ld  a, e
  out (VDP_CONTROL_PORT), a  ; Send Low Byte (A0-A7)

  ld  a, d
  and $3F                    ; Safety: Mask to 14-bit address range
  or  $40                    ; Set Bit 6: Enable "Write" Mode
  out (VDP_CONTROL_PORT), a  ; Send High Byte + Setup VDP for writing
  ei                         ; Enable Interrupts: Safe to resume now

  ; --- 3. Transfer Data (OTIR) ---
  ; Limitation: OTIR uses 8-bit 'B' counter. Max transfer = 256 bytes.
  ld  b, c                   ; Move count to B (OTIR requirement)
  ld  c, VDP_DATA_PORT       ; Set Port to VDP Data ($98)

  otir                       ; Fast Block Output: (HL)->Port(C), HL++, B--
  ret

