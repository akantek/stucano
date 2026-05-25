# MSX UFO Sine Wave Movement Engine

A highly optimized Z80 assembly demonstration for the MSX (Screen 5) showcasing how to move a sprite (a UFO) along a smooth sine wave path without performing any real-time trigonometric calculations. 

**Author:** Antonio Kantek

## 🚀 Overview

Calculating `sin()` in real-time on a 3.58 MHz Z80 processor is computationally prohibitive. This project solves that by utilizing a **Zero-Centered Precalculated Lookup Table (LUT)** generated via Python. 

By separating the UFO's "anchor" (Base Y) from its "offset" (the sine wave curve), the engine allows infinite flexibility. You can spawn the UFO at any vertical position on the screen, and the exact same 256-byte table will handle its bobbing animation.

### Key Features
* **Zero-Math Runtime:** Uses precalculated Two's Complement 8-bit hex values.
* **Microscopic CPU Cost:** The core Y-calculation requires a single `add a, b` instruction (4 T-states).
* **Infinite Looping:** Leverages the Z80's natural 8-bit overflow (0-255) to loop the sine wave automatically without boundary checks.
* **Flexible Positioning:** Spawning a UFO at a new height only requires updating the `ufo_base_y` RAM variable.

---

## 📂 Project Components

### 1. The Z80 Assembly Engine (`main.asm`)
The main loop handles the VDP initialization, sprite multiplexing via Shadow RAM, and the core movement logic. 

**Key Variables:**
* `ufo_angle`: Acts as the "clock". An 8-bit index (0-255) that determines the current position along the sine wave. Increments every frame.
* `ufo_base_y`: Acts as the "anchor". The fixed center-line that the UFO oscillates around.

**The Movement Routine:**
On every VBlank, the engine updates the X coordinate linearly, steps the `ufo_angle` forward, fetches the signed offset from the LUT, and adds it to `ufo_base_y`.

### 2. The Table Generator (`generate_sine_table.py`)
A Python utility included in the repository that generates the Z80

