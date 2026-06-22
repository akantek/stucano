Hitboxes
========

Each hitbox takes up exactly 4 consecutive bytes in RAM, which perfectly matches the offset constants you defined at the top of your code:

Byte 0 (+ HB_Y): The Y coordinate.

Byte 1 (+ HB_X): The X coordinate.

Byte 2 (+ HB_H): The Height of the bounding box.

Byte 3 (+ HB_W): The Width of the bounding box.

Because each struct is exactly 4 bytes (HB_SIZE: equ 4), that's why you can safely place them right next to each other in memory: player_hitbox at $C00C and enemy_hitbox 4 bytes later at $C010.

The HB_ constants
=================

Defining those HB_ constants is how we recreate the concept of a "struct" in assembly language.

Because assembly doesn't have high-level data structures like C or Python, the CPU just sees a continuous ocean of bytes. If we want to group related data together—like a hitbox's Y, X, Height, and Width—we have to define a starting address in RAM and then manually calculate the "offset" to find each specific piece of data.

Here is why defining those equ constants is a standard and highly recommended practice:

1. Eliminating "Magic Numbers"
When you use index registers like IX or IY, you have to tell the CPU how many bytes to look ahead from the base address.

Without constants, your collision math would look like this:

```asm
ld a, (iy + 0)     ; Load Box 2 Y
  add a, (iy + 2)    ; Add Box 2 Height
  cp (ix + 0)        ; Compare to Box 1 Y
```

Looking at (iy + 2) next week, you might completely forget what "2" represents. Is it X? Is it Width?

By defining HB_H: equ 2, the code becomes self-documenting:

```asm
ld a, (iy + HB_Y)  ; Load Box 2 Y
  add a, (iy + HB_H) ; Add Box 2 Height
  cp (ix + HB_Y)     ; Compare to Box 1 Y
```

2. Massive Maintainability
Imagine you get deeper into development and decide you want to add an "Active/Inactive" flag to your hitboxes so you can turn them off when an enemy explodes.

If you want to put that flag at the very beginning of the struct, every other piece of data gets pushed down by 1 byte.

Y becomes offset 1.

X becomes offset 2.

Height becomes offset 3.

If you hardcoded numbers like (ix + 3) everywhere in your collision routines, animation logic, and game loop, you would have to manually hunt down and change every single one. That is a nightmare for bugs.

By using constants, you only have to change the definitions at the top of your file once:

```asm
; --- Hitbox Struct Offsets ---
HB_ACTIVE:  equ 0   ; <-- New variable added!
HB_Y:       equ 1   ; Everything else shifts down
HB_X:       equ 2
HB_H:       equ 3
HB_W:       equ 4
HB_SIZE:    equ 5   ; Update the total size
```

The moment you recompile, every (ix + HB_H) instruction in your entire game automatically adjusts to point to the correct new memory location.

3. Array Stepping
Defining HB_SIZE: equ 4 is crucial if you ever want to loop through multiple hitboxes. If you have an array of 5 enemy hitboxes in RAM, and IX is pointing to Enemy 1, you can instantly point IX to Enemy 2 by adding HB_SIZE to it, ensuring you always jump the exact right number of bytes to reach the next struct.

Explaining check_collision_generic
==================================

This routine is a beautiful example of how to write optimized assembly. It uses a concept often called the "Early Exit" or the "Separating Axis Theorem" (in its simplest 2D form).

Instead of trying to calculate the complex area of an overlap, the CPU takes the lazy route: it tries to prove that a hit is impossible. It asks four questions. If the answer to any of them is yes, it immediately aborts the check and declares a miss.

Only if it fails to prove a miss on all four sides does it conclude: "Well, if you aren't above, below, left, or right... you must be overlapping."

Radial x AABB
=============

AABB: The Lightweight Champion
==============================

Your AABB routine is a masterpiece of performance because it relies on the Z80's greatest strengths: simple addition and early exits.

The Math: It only uses ld (7-8 T-states), add (4 T-states), and cp (7 T-states). These are some of the fastest instructions the CPU has.

The "Early Exit" Magic: Because of the jr c and jr z jumps, the CPU rarely has to run the whole routine. If the enemy is far away, the very first check triggers an early exit.

Estimated Cost: * A complete miss (exits on Check 1): ~35 T-states

A confirmed hit (runs all 4 checks): ~100 T-states

Radial Collision:
=================

The HeavyweightReal Radial collision requires finding the actual distance using the Pythagorean theorem: $(X_2 - X_1)^2 + (Y_2 - Y_1)^2$. This is where the Z80 hits a massive brick wall.The Missing Hardware: The Z80 does not have a multiply instruction. To square a number (e.g., $X \times X$), you have to write a custom software loop that shifts bits and adds them together over and over.The Math: A highly optimized software multiplication routine on the Z80 takes about 150 to 250 T-states to run just once. You have to run it twice (once for X, once for Y).No Early Exit: You cannot exit early. You have to calculate the full distance every single time before you can compare it to the radius.Estimated Cost:Every single check (hit or miss): 500 to 800+ T-states


Why this proves AABB is the ChampionLooking at this code, you can immediately see the massive performance difference compared to your AABB routine:No Early Exits: Notice how the early jr c, .no_hit checks from your AABB routine are entirely gone. The CPU is forced to execute almost the entire block of code even if the sprites are on opposite sides of the screen.The 16-bit Bottleneck: Because multiplying two 8-bit numbers (like $16 \times 16$) creates a result that is too big for a single register (256), the CPU is forced to use HL and DE to do slower, heavier 16-bit additions and subtractions.The Loop: That multiply_8x8 routine runs a loop 8 times. Since you call it 3 times per collision check, your CPU has to execute that loop block 24 times just to check if one enemy hit the player.


Collision TypeCost for 1 EnemyCost for 10 EnemiesImpact on 60fps Game LoopAABB (Box)~50 T-states~500 T-statesBarely noticeable (1% of frame budget). You can add dozens of bullets.Radial (Circle)~600 T-states~6,000 T-statesHeavy (10%+ of frame budget just for collision). Game will lag and slow down.


