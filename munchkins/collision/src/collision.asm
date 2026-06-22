; --- Hitbox Struct Offsets ---
HB_Y:       equ 0    ; Offset 0: Y-coordinate (Top edge)
HB_X:       equ 1    ; Offset 1: X-coordinate (Left edge)
HB_H:       equ 2    ; Offset 2: Height in pixels
HB_W:       equ 3    ; Offset 3: Width in pixels
HB_SIZE:    equ 4    ; Total bytes per hitbox struct

; ==============================================================================
; Routine:      check_collision_generic
; Description:  Compares two bounding boxes using Axis-Aligned Bounding Box math.
; Input:        IX points to Box 1
;               IY points to Box 2
; Output:       Carry Flag (C) is SET if overlapping, NC if missed.
; Destroys:     A
; ==============================================================================
check_collision_generic:
    ; 1. Check Y overlap: Is Box 2 entirely above Box 1? (Bottom 2 < Top 1)
    ; Exit early if the bottom of Box 2 is completely above the top of Box 1
    ld a, (iy + HB_Y)    ; Load Box 2 Y
    add a, (iy + HB_H)   ; Add Box 2 Height (A = Bottom 2)
    cp (ix + HB_Y)       ; Compare to Box 1 Y (Top 1) - compare bottom iy against top ix
    
    ; If A < Value, it needs a borrow → Carry Flag = 1
    ; If A >= Value, no borrow needed → Carry Flag = 0
    jr c, .no_hit        ; If Bottom 2 < Top 1, they don't overlap
    
    jr z, .no_hit        ; If edges are exactly touching, we forgive it (miss)

    ; 2. Check Y overlap: Is Box 1 entirely above Box 2? (Bottom 1 < Top 2)
    ld a, (ix + HB_Y)    
    add a, (ix + HB_H)   
    cp (iy + HB_Y)       
    jr c, .no_hit
    jr z, .no_hit

    ; 3. Check X overlap: Is Box 2 entirely left of Box 1? (Right 2 < Left 1)
    ; Exit early if the right edge of Box 2 is completely left of the left edge of Box 1
    ld a, (iy + HB_X)    
    add a, (iy + HB_W)   
    cp (ix + HB_X)       
    jr c, .no_hit
    jr z, .no_hit

    ; 4. Check X overlap: Is Box 1 entirely left of Box 2? (Right 1 < Left 2)
    ; Exit early if the right edge of Box 1 is completely left (less than) of the left edge of Box 2
    ld a, (ix + HB_X)    
    add a, (ix + HB_W)   
    cp (iy + HB_X)       
    jr c, .no_hit
    jr z, .no_hit

    scf                  ; Survived all checks! Boxes overlap, setting carry flag to 1
    ret

.no_hit:
    or a                 ; Clear Carry Flag
    ret


