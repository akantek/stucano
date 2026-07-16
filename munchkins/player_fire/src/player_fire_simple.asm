INIT_NUM_SPRITES:    equ 5
PLAYER_Y_MIN:   equ 24

player_fire_demo:
  di
  call loadSpritePatterns
  call loadSpriteColors
  call initSpriteAttributes

  ; Initialize starting coordinates to match your init data
  ld a, 120
  ld (player_x), a
  ld (player_y), a

  ld a, INIT_NUM_SPRITES
  ld (active_sprites), a   ; Start with the default 5 sprites
  xor a
  ld (fire0_active), a      ; Bullet starts inactive
  ei

 .main_loop:
  call wait_vsync
.vblank_trace_start:
  ld a, (active_sprites)
  call loadSpriteAttributes
.vblank_trace_end:

  call scan_keypad
  ld c, a

  ; --- X AXIS (Horizontal) ---
.check_left:
  bit 4, c              ; Check bit 4 (Left)
  jr nz, .check_right   ; If 1 (not pressed), skip to checking Right

  ; Move Left
  ld a, (player_x)
  dec a
  ld (player_x), a
  jr .check_y_axis      ; Skip right check (can't go left and right simultaneously)

.check_right:
  bit 7, c              ; Check bit 7 (Right)
  jr nz, .check_y_axis  ; If 1 (not pressed), skip to Y axis

  ; Move Right
  ld a, (player_x)
  inc a
  ld (player_x), a

.check_y_axis:

.check_up:
  bit 5, c              ; Check bit 5 (Up)
  jr nz, .check_down    ; If 1 (not pressed), skip to checking Down

  ; Move Up
  ld a, (player_y)
  dec a
  ld (player_y), a
  jr .check_space

.check_down:
  bit 6, c
  jr nz, .check_space

  ; Move Down
  ld a, (player_y)
  inc a
  ld (player_y), a

.check_space:
  bit 0, c                   ; Check bit 0 (Space bar)
  jr nz, .space_released     ; If 1 (not pressed), jump to reset fla

  ; Space IS pressed. Check debounce flag.
  ld a, (space_was_pressed)
  or a                       
  jr nz, .update_fire_logic  ; Already pressed, skip spawning

  ; Check if a bullet is already on screen (max 1 bullet at a time)
  ld  a, (fire0_active)
  or a
  jr nz, .update_fire_logic

  ; FIRE NEW BULLET
ld a, 1
  ld (space_was_pressed), a  ; Set debounce flag
  ld (fire0_active), a        ; Set bullet active flag

ld a, 6
  ld (active_sprites), a     ; Increase sprite count to 6

; Set starting position relative to player
  ld a, (player_x)
  add a, 25                  ; Spawn at the nose of the helicopter
  ld (fire0_x), a
  ld a, (player_y)
  add a, 8                   ; Center it vertically
  ld (fire0_y), a

  ; Configure Sprite 4 (The Bullet)
  ld a, 48                   ; Pattern 48 (helicopter_fire)
  ld (sprite4_pat), a
  ld a, 10                   ; Color 10 = Dark Yellow
  ld (sprite4_timer), a      

  ; Configure Sprite 5 (The New Terminator)
  ld a, $D8
  ld (sprite5_y), a          ; Tell VDP to stop rendering here
  jr .update_fire_logic



.space_released:
  xor a                      ; A = 0
  ld (space_was_pressed), a  ; Clear the flag

.update_fire_logic:
  ; --- MOVE BULLET ---
  ld a, (fire0_active)
  or a
  jr z, .end_keypad          ; If bullet is not active, skip movement

  ; Move the bullet right
  ld a, (fire0_x)
  add a, 6                   ; Speed: 6 pixels per frame
  ld (fire0_x), a

  ; Check if it went off the right edge of the screen
  cp 240
  jr nc, .despawn_bullet

  ; Still on screen - Update Sprite RAM
  ld (sprite4_x), a
  ld a, (fire0_y)
  ld (sprite4_y), a
  jr .end_keypad

.despawn_bullet:
  xor a
  ld (fire0_active), a        ; Turn off bullet
  ld a, 5
  ld (active_sprites), a     ; Reduce sprite count back to 5
  ld a, $D8
  ld (sprite4_y), a          ; Put the terminator back into Sprite 4


.end_keypad:
  call update_player_sprites
  jp .main_loop


update_player_sprites:
  ; --- Update Y Coordinates ---
  ld a, (player_y)
  ld (sprite0_y), a   ; Layer 1 (Left)
  ld (sprite1_y), a   ; Layer 2 (Left overlay)
  ld (sprite2_y), a   ; Layer 1 (Right)
  ld (sprite3_y), a   ; Layer 2 (Right overlay)

  ; --- Update X Coordinates ---
  ld a, (player_x)
  ld (sprite0_x), a   ; Layer 1 (Left)
  ld (sprite1_x), a   ; Layer 2 (Left overlay)

  add a, 16           ; Shift 16 pixels right for the second half
  ld (sprite2_x), a   ; Layer 1 (Right)
  ld (sprite3_x), a   ; Layer 2 (Right overlay)
  ret

loadSpritePatterns:
  ld HL, sprite_patterns_start
  ld DE, VRAM_SPR_PATTERNS
  ld A, SPRITE_VRAM_BANK
  ld BC, sprite_patterns_end - sprite_patterns_start
  call write_vram_large
  ret

loadSpriteColors:
  ; --- Load colors for Sprites 0 & 1 ---
  ld hl, player_helicopter_colors_start   ; Source RAM
  ld de, VRAM_SPR_COLORS                  ; Dest VRAM ($7400)
  ld a, SPRITE_VRAM_BANK                  ; Bank 1
  ld c, player_helicopter_colors_end - player_helicopter_colors_start
  call write_vram_fast

  ; --- Load colors for Sprites 2 & 3 ---
  ld hl, player_helicopter_colors_start   ; Source RAM
  ld de, VRAM_SPR_COLORS + 32             ; Dest VRAM ($7400)
  ld a, SPRITE_VRAM_BANK                  ; Bank 1
  ld c, player_helicopter_colors_end - player_helicopter_colors_start
  call write_vram_fast
  ret

initSpriteAttributes:
  ; 1. Copy the initial data into the RAM Shadow Buffer
  ld hl, init_sprite_attributes
  ld de, shadow_sat
  ld bc, INIT_NUM_SPRITES * 4
  ldir

  ; 2. Send it to VDP
  ld hl, shadow_sat
  ld a, SPRITE_VRAM_BANK
  ld de, VRAM_SPR_ATTRIBS
  ld bc, INIT_NUM_SPRITES * 4
  call write_vram_fast
  ret

sprite_color_data_start:
player_helicopter_colors_start:
; Sprite 0
db 12,12,12,12, 8,8,8,8, 8,8,8,8, 8,8,8,8
; Sprite 1
db $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44
; Sprite 2
db 8,8,8,8, 8,8,8,8, 8,8,8,8, 8,8,8,8
; Sprite 3
db $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44, $44,$44,$44,$44
player_helicopter_colors_end:
sprite_color_data_end:

init_sprite_attributes:
  ; Sprite 0: Right Facing - Layer 1 (White)
  ; Y ($60=96), X ($70=112), Pattern 0
  db 10, 10, 0, 0

  ; Sprite 1: Right Facing - Layer 2 (Red)
  ; Same X,Y as above to overlay them
  ;
  ; [!] MSX2 Sprite Mode 2 requires this overlay sprite to have the EXACT 
  ; same Y coordinate as Sprite 0 above it because the CC (Color Combine) 
  ; bit is set in its color table. If Y differs, it will be invisible. 
  db 10, 10, 4, 0 

  ; Sprite 2: Left Facing - Layer 1 (White)
  ; Y ($60=96), X ($90=144), Pattern 8
  db 10, 26, 8, 0

  ; Sprite 3: Left Facing - Layer 2 (Red)
  ; Same X,Y as above to overlay them
  db 10, 26, 12, 0

  ; End sprite
  db $D8, 0, 0, 0
  ret
