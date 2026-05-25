; ==============================================================================
; Minimal MSX2 Screen 5 Sprite Demo
; ==============================================================================

; --- MSX BIOS Calls & Variables ---
CHGMOD  equ $005F       ; BIOS: Change Screen Mode
WRTVDP  equ $0047       ; BIOS: Write to VDP Register
RG1SAV  equ $F3E0       ; BIOS: VDP Register 1 Mirror
VDP_DATA equ $98        ; Hardware: VDP Data Port
VDP_CTRL equ $99        ; Hardware: VDP Control Port

; ==============================================================================
; MAIN INITIALIZATION
; ==============================================================================
main:
    ; 1. Set Screen Mode to 5
    ld a, 5
    call CHGMOD

    ; 2. Configure VDP for 16x16 Sprites
    ld a, (RG1SAV)      ; Read current VDP Register 1 state from BIOS RAM
    or 2                ; Set Bit 1 (Sprite Size: 1 = 16x16, 0 = 8x8)
    ld (RG1SAV), a      ; Save it back to BIOS RAM
    ld c, 1             ; Target VDP Register 1
    call WRTVDP         ; Send to VDP

    ; 3. Safely hide the screen while writing to VRAM (Good practice)
    ld a, (RG1SAV)
    and $BF             ; Clear Bit 6 (Display Enable)
    ld (RG1SAV), a
    ld c, 1
    call WRTVDP

    ; 4. Upload Sprite Patterns ($7800 default for Screen 5)
    ld hl, sprite_pattern
    ld de, $7800
    ld bc, 32           ; 16x16 pixels = 32 bytes
    call write_vram

    ; 5. Upload Sprite Colors ($7400 default for Screen 5)
    ld hl, sprite_color
    ld de, $7400
    ld bc, 16           ; Mode 2 uses 16 bytes per sprite (1 byte per row)
    call write_vram

    ; 6. Upload Sprite Attributes ($7600 default for Screen 5)
    ld hl, sprite_attrib
    ld de, $7600
    ld bc, 4            ; 4 bytes per sprite (Y, X, Pattern, Reserved)
    call write_vram

    ; 7. Turn the screen back on
    ld a, (RG1SAV)
    or $40              ; Set Bit 6 (Display Enable)
    ld (RG1SAV), a
    ld c, 1
    call WRTVDP

; ==============================================================================
; GAME LOOP
; ==============================================================================
main_loop:
    halt                ; Put CPU to sleep until next interrupt (saves power/cycles)
    jr main_loop        ; Loop forever. The sprite is now drawn by hardware!


; ==============================================================================
; ROUTINE: write_vram
; Safely copies BC bytes from RAM (HL) to 17-bit VRAM Address (DE)
; ==============================================================================
write_vram:
    di                  ; CRITICAL: Shield VDP port from interrupts

    ; Step A: Set VDP Bank (Register 14) to 0
    ; Addresses $0000-$FFFF exist in Bank 0
    xor a
    out (VDP_CTRL), a
    ld a, 14 or $80
    out (VDP_CTRL), a

    ; Step B: Set VDP Read/Write Address (14-bit)
    ld a, e
    out (VDP_CTRL), a   ; Send Low Byte
    ld a, d
    and $3F             ; Mask off top two bits
    or $40              ; Set Bit 6 for "Write" mode
    out (VDP_CTRL), a   ; Send High Byte

.loop:
    ld a, (hl)
    out (VDP_DATA), a   ; Write byte to VDP
    inc hl
    dec bc
    ld a, b
    or c
    jr nz, .loop        ; Continue until BC hits 0

    ei                  ; Safe to resume interrupts
    ret


; ==============================================================================
; SPRITE DATA
; ==============================================================================

; 1. Pattern (16x16 Yellow Smiley) - 32 Bytes
sprite_pattern:
    ; Left Half             ; Right Half
    db %00011111,           %11111000 ; Row 0
    db %00110000,           %00001100 ; Row 1
    db %01100000,           %00000110 ; Row 2
    db %11000000,           %00000011 ; Row 3
    db %11001100,           %00110011 ; Row 4 (Eyes)
    db %11001100,           %00110011 ; Row 5
    db %11000000,           %00000011 ; Row 6
    db %11000000,           %00000011 ; Row 7
    db %11001000,           %00010011 ; Row 8 (Smile begins)
    db %11000100,           %00100011 ; Row 9
    db %01100011,           %11000110 ; Row 10 (Smile bottom)
    db %00110000,           %00001100 ; Row 11
    db %00011111,           %11111000 ; Row 12
    db %00000000,           %00000000 ; Row 13
    db %00000000,           %00000000 ; Row 14
    db %00000000,           %00000000 ; Row 15

; 2. Colors (Sprite Mode 2) - 16 Bytes
sprite_color:
    ; 1 byte per row. Color 10 is Light Yellow.
    db 10, 10, 10, 10, 10, 10, 10, 10
    db 10, 10, 10, 10, 10, 10, 10, 10

; 3. Attributes (SAT) - 4 Bytes
sprite_attrib:
    db 96               ; Y Coordinate
    db 120              ; X Coordinate
    db 0                ; Pattern Index (0)
    db 0                ; Color/Early Clock (Unused here)

