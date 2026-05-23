# MSX Assembly Tutorial: Understanding and Hooking VBlank

This repository contains a minimal MSX assembly example demonstrating how to hook into the MSX vertical blanking interval (VBlank) interrupt. It sets up a basic "game loop" that safely waits for the screen to finish drawing before processing logic, triggering a system beep roughly once every second.

## What is VBlank?

In CRT (Cathode Ray Tube) displays, the image is drawn by an electron beam sweeping horizontally from left to right, line by line, moving from top to bottom. 

When the beam reaches the bottom-right corner of the screen, it must turn off and travel back to the top-left corner to begin drawing the next frame. This return journey is called the **Vertical Blanking Interval (VBlank)**. 

### Why do we care?
The VDP (Video Display Processor) RAM is heavily utilized while the screen is being actively drawn. If your CPU tries to write to VRAM during this active period, you risk:
1. **Screen Tearing:** The user sees half of the old frame and half of the new frame.
2. **Visual Corruption ("Snow"):** The VDP struggles to serve both the CPU and the screen simultaneously, causing visual artifacts.
3. **Missed Writes:** The CPU writes faster than the VDP can process them during active display.

By halting your main game loop and waiting for the VBlank interval, you guarantee a safe window to push new graphics, update sprite attributes, and change the palette without glitching the display.

---

## How VBlank Works on the MSX

At the start of every VBlank (50 or 60 times a second, depending on your machine's region), the VDP triggers a hardware interrupt. 

The MSX BIOS handles this hardware interrupt. During its routine, the BIOS does housekeeping: it scans the keyboard, updates timers, and manages the cassette motor. Crucially, in the middle of this process, the BIOS calls a specific RAM hook called **`HTIMI`** (located at `$FD9F`).

By replacing the instructions at `HTIMI` with a jump to our own code, we can execute custom logic exactly at the start of every frame.

---

## Code Breakdown

### 1. Hooking the Interrupt (`install_vblank_hook`)
Hooks in the MSX system are 5 bytes long. To play nice with the system, we shouldn't just overwrite `HTIMI` permanently.
1. **Backup:** We use `LDIR` to copy the original 5 bytes from `$FD9F` to our own RAM variable `OLD_HTIMI`.
2. **Inject:** We write the Z80 opcode `$C3` (Unconditional Jump `JP`) to `$FD9F`, followed by the 16-bit address of our custom handler (`vblank_hook`).

### 2. The Interrupt Service Routine (`vblank_hook`)
When the BIOS calls our hook, the CPU executes this code:
```z80
vblank_hook:
  push af
  ld a, 1
  ld (vsync_flag), a
  pop af
  jp OLD_HTIMI

