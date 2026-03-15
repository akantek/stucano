# SCREEN 5

## VRAM

* MSX2 VRAM is 128KB, mapping from $00000 to $1FFFF

### Pages

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
#### Pixels and Bytes

* 1 Byte represents 2 pixels (1 pixel per nibble).

* SCREEN 5 is a 16-color mode.

  - Upper Nibble (Bits 7-4): The color of the left pixel (even X coordinate).

  - Lower Nibble (Bits 3-0): The color of the right pixel (odd X coordinate). 

  - e.g. $A5 is the same as 1010 0101. The left pixel is color A
    (10 -> light red) and right pixel is color 5 (light blue)

#### VRAM map

+====================+=======+================+======================================+
| VRAM ADDRESS (Hex) | PAGE  | VDP COORDS     | CONTENT DESCRIPTION                  |
+====================+=======+================+======================================+
| 0x1FFFF            |       | X: 0 to 255    | END OF VRAM                          |
|                    |       | Y: 768 to 1023 |                                      |
|                    |       |                | Sprite Pattern Generator (SPG)       |
|                    |       |                | (Actual 16x16 sprite graphics data)  |
| 0x1C000            |       |                +--------------------------------------+
|                    |       |                | Free VRAM / Gap                      |
| 0x1B200            | PAGE  |                +--------------------------------------+
|                    |  3    |                | Sprite Attribute Table (SAT)         |
|                    | (32K) |                | (Y, X, Pattern#, Attributes for 32   |
| 0x1B000            |       |                | sprites)                             |
|                    |       |                +--------------------------------------+
|                    |       |                |                                      |
|                    |       |                | Free VRAM (General Purpose storage)  |
|                    |       |                |                                      |
| 0x18000            |       |                | START OF PAGE 3                      |
+====================+=======+================+======================================+
| 0x17FFF            |       | X: 0 to 255    |                                      |
|                    |       | Y: 512 to 767  |                                      |
|                    | PAGE  |                | Bitmap Data Area                     |
|                    |  2    |                | (Often used for storing tilesets,    |
|                    | (32K) |                | background assets, or UI elements)   |
|                    |       |                |                                      |
| 0x10000            |       |                | START OF PAGE 2                      |
+====================+=======+================+======================================+
| 0x0FFFF            |       | X: 0 to 255    |                                      |
|                    |       | Y: 256 to 511  |                                      |
|                    | PAGE  |                | Bitmap Data Area                     |
|                    |  1    |                | (Commonly used as the "Back Buffer"  |
|                    | (32K) |                | for double buffering invisible       |
|                    |       |                | drawing)                             |
| 0x8000             |       |                | START OF PAGE 1                      |
+====================+=======+================+======================================+
| 0x7FFF             |       | X: 0 to 255    |                                      |
|                    |       | Y: 0 to 255    |                                      |
|                    | PAGE  |                | Bitmap Data Area                     |
|                    |  0    |                | (Default Visible Screen on startup)  |
|                    | (32K) |                |                                      |
|                    |       |                |                                      |
| 0x00000            |       |                | START OF VRAM                        |
+====================+=======+================+======================================+

#### Banks

* The CPU Limit: The Z80 is an 8-bit CPU that natively addresses only 64KB of
      memory, meaning the MSX2's full 128KB of VRAM physically cannot fit into
      its address space.

* The VDP Limit: To maintain backward compatibility with the MSX1, the VDP only
      accepts 14-bit memory addresses, which caps out at exactly 16KB.

* The Bank-Switching Solution: This technique bypasses both bottlenecks by
      using VDP Register 14 to select and load just one 16KB "bank" of VRAM at
      a time.

+==========+==========+=============+=====================+=====================+
| VDP PAGE | CPU BANK | VDP REG #14 | CPU VRAM ADDRESS    | EXACT Y-COORDINATES |
+==========+==========+=============+=====================+=====================+
|          | Bank 0   |      0      | 0x00000 - 0x03FFF   | 0 to 127            |
|  Page 0  +----------+-------------+---------------------+---------------------+
|          | Bank 1   |      1      | 0x04000 - 0x07FFF   | 128 to 255          |
+----------+----------+-------------+---------------------+---------------------+
|          | Bank 2   |      2      | 0x08000 - 0x0BFFF   | 256 to 383          |
|  Page 1  +----------+-------------+---------------------+---------------------+
|          | Bank 3   |      3      | 0x0C000 - 0x0FFFF   | 384 to 511          |
+----------+----------+-------------+---------------------+---------------------+
|          | Bank 4   |      4      | 0x10000 - 0x13FFF   | 512 to 639          |
|  Page 2  +----------+-------------+---------------------+---------------------+
|          | Bank 5   |      5      | 0x14000 - 0x17FFF   | 640 to 767          |
+----------+----------+-------------+---------------------+---------------------+
|          | Bank 6   |      6      | 0x18000 - 0x1BFFF   | 768 to 895          |
|  Page 3  +----------+-------------+---------------------+---------------------+
|          | Bank 7   |      7      | 0x1C000 - 0x1FFFF   | 896 to 1023         |
+==========+==========+=============+=====================+=====================+

* Writing a pixel in page 0, banks 0 and 1

* Example 1: writing to page 0, bank 0 (Y=1)

```asm
; --- SETUP VDP FOR BANK 0 ---
    ld a, 0             ; Load the value 0 (for Bank 0)
    out (0x99), a       ; Send data to VDP port 0x99
    ld a, 14 + 128      ; Tell VDP we want to write to Register 14 
                        ; (+128 is the hardware flag for "Register Write")
    out (0x99), a       

; --- SET 14-BIT ADDRESS (0x0085) ---
    ld a, 0x85          ; Lower 8 bits of the address (0x85)
    out (0x99), a
    ld a, 0x00 + 64     ; Upper 6 bits of the address (0x00) 
                        ; (+64 is the hardware flag for "Write to VRAM")
    out (0x99), a

; --- WRITE THE PIXELS ---
    ld a, 0xFF          ; 0xFF = 1111 1111 in binary (two Color 15 pixels)
    out (0x98), a       ; Send the pixel data to VRAM via port 0x98
```

```asm
; --- SETUP VDP FOR BANK 1 ---
    ld a, 1             ; Load the value 1 (for Bank 1)
    out (0x99), a       ; Send data to VDP port 0x99
    ld a, 14 + 128      ; Tell VDP we want to write to Register 14
    out (0x99), a       

; --- SET 14-BIT ADDRESS (0x0085) ---
    ; Notice this section is EXACTLY identical to the Bank 0 code!
    ; Because the window moved, the local 14-bit address is the same.
    ld a, 0x85          
    out (0x99), a
    ld a, 0x00 + 64     
    out (0x99), a

; --- WRITE THE PIXELS ---
    ld a, 0xFF          
    out (0x98), a
```

### Registers

+==========+======================+============================================================+
| REGISTER | NAME                 | EXPANDED DESCRIPTION                                       |
+==========+======================+============================================================+
| R#0      | Mode Control 0       | Sets the display mode (G1-G7). Also contains the IE1 bit   |
|          |                      | to enable/disable Line Interrupts.                         |
+----------+----------------------+------------------------------------------------------------+
| R#1      | Mode Control 1       | Controls the main display (Blank/Show), enables V-Blank    |
|          |                      | interrupts (IE0), sets sprite size (8x8 or 16x16), and     |
|          |                      | sprite magnification.                                      |
+----------+----------------------+------------------------------------------------------------+
| R#2      | Pattern Name Table   | Sets the base address of the Name Table. In high-res       |
|          | Base Address         | modes, this points to the start of the image data in VRAM. |
+----------+----------------------+------------------------------------------------------------+
| R#3      | Color Table          | Sets the base VRAM address for the Color Table.            |
|          | Base Address         |                                                            |
+----------+----------------------+------------------------------------------------------------+
| R#4      | Pattern Generator    | Sets the base VRAM address for the Pattern Generator Table |
|          | Base Address         | (where tile or character graphics are stored).             |
+----------+----------------------+------------------------------------------------------------+
| R#5      | Sprite Attribute     | Sets the base VRAM address for the SAT (Sprite Attribute   |
|          | Table Base Address   | Table), determining where sprite Y, X, and attributes live.|
+----------+----------------------+------------------------------------------------------------+
| R#6      | Sprite Pattern       | Sets the base VRAM address for the Sprite Pattern          |
|          | Generator Address    | Generator (where the actual sprite pixels are stored).     |
+----------+----------------------+------------------------------------------------------------+
| R#7      | Backdrop / Text      | Defines the screen backdrop color (the overscan border).   |
|          | Color                | In text modes, it also sets the foreground text color.     |
+==========+======================+============================================================+

* Register 0: Set display mode (but using CHGMOD is easier)

```asm
SetScreen5:
    ; Set Register 0 to 0x06
    ld a, 0x06
    out (0x99), a
    ld a, 128 + 0
    out (0x99), a

    ; Set Register 1 to 0x6A
    ld a, 0x6A
    out (0x99), a
    ld a, 128 + 1
    out (0x99), a
    
    ret
```

* This is the same as

```asm
    ld a, 5             ; Load the number 5 (for SCREEN 5) into register A
    call 0x005F         ; Call the MSX BIOS 'CHGMOD' routine
```



