; ==============================================================================
; Routine: check_player_enemy_collision
; Inputs:  HL = Address of Enemy X, DE = Address of Enemy Y
; Outputs: Carry Flag SET if colliding, CLEAR if safe
; ==============================================================================
check_player_enemy_collision:
    ; --- 1. Check Horizontal (X) ---
    
    ; Is Enemy_Left >= Player_Right?
    ld a, (player_x)
    add a, PLAYER_HITBOX_W      
    ld c, a
    ld a, (hl)                  ; Read Enemy X
    cp c
    jr nc, .no_collision

    ; Is Player_Left >= Enemy_Right?
    ld a, (hl)                  ; Read Enemy X
    add a, ENEMY_HITBOX_W       
    ld c, a
    ld a, (player_x)
    cp c
    jr nc, .no_collision

    ; --- 2. Check Vertical (Y) ---
    
    ; Is Enemy_Top >= Player_Bottom?
    ld a, (player_y)
    add a, PLAYER_HITBOX_H      
    ld c, a
    ld a, (de)                  ; Read Enemy Y
    cp c
    jr nc, .no_collision

    ; Is Player_Top >= Enemy_Bottom?
    ld a, (de)                  ; Read Enemy Y
    add a, ENEMY_HITBOX_H       
    ld c, a
    ld a, (player_y)
    cp c
    jr nc, .no_collision

.collision:
    scf                         ; SET Carry Flag
    ret

.no_collision:
    or a                        ; CLEAR Carry Flag
    ret

