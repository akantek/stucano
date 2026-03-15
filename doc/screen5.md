# SCREEN 5

## VRAM

* MSX2 VRAM is 128KB, mapping from $00000 to $1FFFF

* Memory segments

  - Page 0: $00000 - $07FFF (32KB)

  - Page 1: $08000 - $0FFFF (32KB)

  - Page 2: $10000 - $17FFF (32KB)

  - Page 3: $18000 - $1FFFF  (32KB)

    - $18000 - $1AFFF: 12KB of free VRAM at the start of the page.
          This space ends exactly one byte before the Color Table begins.

    - $1B000 - $1B1FF (512 bytes): Sprite Color Table in Sprite Mode 2 (16x16).
          512 (0x200) bytes before the Sprite Attribute Table base address.

    - $1B200 - $1B27F: Sprite Attribute Table (SAT), 128 bytes =
          32 sprites x 4 bytes.

    - $1B280 - $1BFFF: block of about 3.3KB of completely free VRAM
          right after the SAT.

    - $1C000 - $1DFFF: Sprite Pattern Generator (SPG), A full pattern table
        for 256 sprites only requires 8KB (1C000h - 1DFFFh)

    - $1E000 - $1FFFF: Free final 8Kb

* Constants for SCREEN5 VRAM

```asm
; --- VRAM Page Map ---
VRAM_PAGE0      EQU $00000
VRAM_PAGE1      EQU $08000
VRAM_PAGE2      EQU $10000
VRAM_PAGE3      EQU $18000

; --- Page 3 Sprite Data Layout ---
SPR_COLOR_TAB   EQU $1B000  ; 512 bytes (Ends at $1B1FF)
SPR_ATTR_TAB    EQU $1B200  ; 128 bytes (Ends at $1B27F)
SPR_PATT_GEN    EQU $1C000  ; 8KB       (Ends at $1DFFF)
```

