; ==============================================================================
; Routine:      check_collision_radial
; Description:  Compares two circles using (X2-X1)^2 + (Y2-Y1)^2 < (R1+R2)^2
; Input:        IX points to Circle 1 struct (C_X, C_Y, C_R)
;               IY points to Circle 2 struct (C_X, C_Y, C_R)
; Output:       Carry Flag (C) is SET if overlapping, NC if missed.
; ==============================================================================
check_collision_radial:
    ; --- 1. Get Delta X (Absolute difference between X2 and X1) ---
    ld a, (iy + C_X)     ; Load Sprite 2 X (Center)
    sub (ix + C_X)       ; Subtract Sprite 1 X
    jr nc, .x_positive   ; If no carry, the result is already positive
    neg                  ; Z80 Trick: Negate the negative number to make it positive!
.x_positive:
    ; Square Delta X
    ld c, a              
    ld e, a              ; Set up for C * E
    call multiply_8x8    ; Returns HL = (Delta X)^2
    push hl              ; Save X squared on the stack

    ; --- 2. Get Delta Y (Absolute difference between Y2 and Y1) ---
    ld a, (iy + C_Y)     ; Load Sprite 2 Y (Center)
    sub (ix + C_Y)       ; Subtract Sprite 1 Y
    jr nc, .y_positive
    neg                  ; Absolute value
.y_positive:
    ; Square Delta Y
    ld c, a
    ld e, a              ; Set up for C * E
    call multiply_8x8    ; Returns HL = (Delta Y)^2

    ; --- 3. Add them together to get Total Squared Distance ---
    pop de               ; Retrieve X squared from the stack into DE
    add hl, de           ; HL = (Delta X)^2 + (Delta Y)^2
    push hl              ; Save Total Distance on the stack

    ; --- 4. Get the Target Threshold (R1 + R2)^2 ---
    ld a, (iy + C_R)     ; Load Sprite 2 Radius
    add a, (ix + C_R)    ; Add Sprite 1 Radius
    ld c, a
    ld e, a
    call multiply_8x8    ; Returns HL = (R1 + R2)^2

    ; --- 5. The Final 16-bit Comparison ---
    pop de               ; DE = Total Distance Squared
    ; We are comparing HL (Target) against DE (Distance). 
    ; We want to know if Distance is LARGER than Target.
    or a                 ; Clear Carry flag before subtraction
    sbc hl, de           ; Math: Target - Distance
    jr c, .no_hit        ; If Carry is set, Distance was larger. They missed!
    jr z, .no_hit        ; If Zero is set, they are exactly touching edges. Miss!

    scf                  ; Distance was smaller! Boxes overlap.
    ret

.no_hit:
    or a                 ; Clear Carry Flag
    ret

; ==============================================================================
; Subroutine:   multiply_8x8
; Description:  Software multiplication because the Z80 lacks a MUL instruction.
; Input:        C (Multiplier), E (Multiplicand)
; Output:       HL (16-bit result)
; ==============================================================================
multiply_8x8:
    ld hl, 0             ; Clear the result register
    ld d, 0              ; Make DE a clean 16-bit number
    ld b, 8              ; Loop 8 times (once for each bit)
.mul_loop:
    srl c                ; Shift multiplier right. Does a '1' fall into the Carry flag?
    jr nc, .skip_add     ; If not, skip the addition
    add hl, de           ; If yes, add the multiplicand to our result
.skip_add:
    sla e                ; Shift the multiplicand left
    rl d                 ; Carry the bit into D
    djnz .mul_loop       ; Decrement B, loop if not zero
    ret


