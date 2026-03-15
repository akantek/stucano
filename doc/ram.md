# MSX Memory Addresses

## Super Tucano ROM Cartdridge

- Super Tucano ROM Cartridge starts at $8000

### MSX RAM for Super Tucano

- 4 Pages of 16Kb

- Page 0: $0000 - $3FFF: Main ROM (BIOS): Where MSX system routines live
      (e.g., CHGMOD, DISSCR).

- Page 1: $4000 - $7FFF: Empty / Cartridge Expansion: Usually holds BASIC.
      In ROM cartridges, this can hold the first half of a 32Kb ROM.

- Page 2: $8000 - $BFFF: Super Tucano ROM (16Kb)

- Page 3: $C000 - $FFFF: System RAM: The 16KB of working memory.

  - $C000 - $F37F: Free RAM, used for game variables (approx 13KB).

  - $F380: The Stack Pointer. Z80 stack grows downwards (towards $C000).

  - $F380 - $FC49 : MSX System Variables.
    - $F3DB: CLIKSW (Key click flag)
    - $F3E9: FORCLR (Foreground)
    - $F3EA: BAKCLR (Background)
    - $F3EB: BDRCLR (Border)

  - $FC4A - $FD99: System Work Area / Math Pak

  - $FD9A - $FFFF: System Hooks.
    - $FD9F: HTIMI (The interrupt hook that fires 60 times a second).

