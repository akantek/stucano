; ==============================================================================
; play_tooom_sfx
; Plays a deep resonant impact (Toooooommmmmmm) using the PSG hardware envelope.
; Destroys: AF, BC, DE
; ==============================================================================
play_tooom_sfx:
  ; --- 1. Initial Setup (The "-mmmmmm" envelope parameters) ---
  
  ld a, 7               ; Reg 7: Mixer
  ld e, 254             ; Tone A ON, Noise OFF (11111110)
  call write_psg

  ld a, 11              ; Reg 11: Envelope Fine Period
  ld e, 150
  call write_psg

  ld a, 12              ; Reg 12: Envelope Coarse Period
  ld e, 30              ; Very slow envelope speed
  call write_psg

  ld a, 8               ; Reg 8: Channel A Volume
  ld e, 16              ; 16 = Use Hardware Envelope
  call write_psg

  ld a, 13              ; Reg 13: Envelope Shape
  ld e, 0               ; 0 = Fade out once
  call write_psg

  ; --- 2. The "T" Attack (Quick Pitch Drop) ---
  ; FOR P = 30 TO 200 STEP 15
  ld d, 30              ; D is our 'P' variable (Start at 30)

.sweep_loop:
  ; SOUND 0, P
  ld a, 0               ; Reg 0: Tone A Fine Pitch
  ld e, d
  call write_psg
  
  ; SOUND 1, 0
  ld a, 1               ; Reg 1: Tone A Coarse Pitch
  ld e, 0
  call write_psg
  
  ; --> Artificial Delay (Because Z80 is way faster than BASIC!)
  ld bc, 1500           ; Tweak this number to change the "strike" speed
.delay:
  dec bc
  ld a, b
  or c
  jr nz, .delay         ; Loop until BC = 0

  ; P = P + 15
  ld a, d
  add a, 15
  ld d, a               ; Store back in D
  
  ; Check if P <= 200
  cp 201                ; Compare A with 201
  jr c, .sweep_loop     ; If A < 201 (Carry flag set), keep looping

  ; --- 3. The "Oooommmmm" (Deep Holding Pitch) ---
  ; SOUND 0, 100
  ld a, 0               ; Reg 0: Tone A Fine Pitch
  ld e, 100
  call write_psg
  
  ; SOUND 1, 5
  ld a, 1               ; Reg 1: Tone A Coarse Pitch
  ld e, 5
  call write_psg
  
  ret

; ==============================================================================
; Helper Routine: write_psg
; Inputs: A = PSG Register Number, E = Data Value to Write
; ==============================================================================
write_psg:
  out (PSG_REG_PORT), a   ; Tell PSG which register we want
  ld a, e                 ; Move our data into A
  out (PSG_DATA_PORT), a  ; Send data to the PSG
  ret

start_helicopter_fx:
  ; -----------------------------------------------------
  ; 10 SOUND 6, 31  (Set Noise Frequency to Rumble)
  ; -----------------------------------------------------
  ld  a, 6        ; Select Register 6
  out (PSG_REG_PORT), a
  ld  a, 31       ; Value 31 (Low pitch noise)
  out (PSG_DATA_PORT), a

  ; -----------------------------------------------------
  ; 20 SOUND 7, 55  (Mixer: Enable Noise A, Disable Tone A)
  ; -----------------------------------------------------
  ld  a, 7        ; Select Register 7
  out (PSG_REG_PORT), a
  ld  a, 55       ; Value 55 (Binary 00110111)
  out (PSG_DATA_PORT), a

  ; -----------------------------------------------------
  ; 30 SOUND 11, 0 : SOUND 12, 10 (Set Speed/Envelope Period)
  ; -----------------------------------------------------
  ; Fine Tune (Reg 11)
  ld  a, 11
  out (PSG_REG_PORT), a
  ld  a, 0
  out (PSG_DATA_PORT), a

  ; Coarse Tune (Reg 12) - THE SPEED!
  ld  a, 12
  out (PSG_REG_PORT), a
  ld  a, 2       ; Value 2 (Fast Speed)
  out (PSG_DATA_PORT), a

  ; -----------------------------------------------------
  ; 40 SOUND 13, 8  (Envelope Shape: Sawtooth)
  ; -----------------------------------------------------
  ld  a, 13
  out (PSG_REG_PORT), a
  ld  a, 8        ; Value 8 (Sawtooth shape)
  out (PSG_DATA_PORT), a

  ; -----------------------------------------------------
  ; 50 SOUND 8, 16  (Set Volume A to Hardware Envelope)
  ; -----------------------------------------------------
  ld  a, 8
  out (PSG_REG_PORT), a
  ld  a, 16       ; Value 16 (Bit 4 set = Use Envelope)
  out (PSG_DATA_PORT), a

  ; -----------------------------------------------------
  ; 60 GOTO 60 (In assembly, we just Return to main loop)
  ; -----------------------------------------------------
  ret


; ==============================================================================
; Routine: play_missile fire
; Description: Direct port of the MSX BASIC prototype. 
; NOTE: This routine blocks the CPU while playing (just like BASIC does).
; ==============================================================================
play_missile_fire:
    ; ------------------------------------------------
    ; Lines 20: Clear PSG Registers (0 to 13)
    ; ------------------------------------------------
    ld b, 14                   ; We want to clear 14 registers
    ld c, 0                    ; Start at Register 0
.missile_clear_loop:
    ld a, c
    out ($A0), a               ; Select Register
    xor a                      ; A = 0
    out ($A1), a               ; Write 0 to Register
    inc c                      ; Next register
    djnz .missile_clear_loop           ; Loop until B = 0

    ; ------------------------------------------------
    ; Lines 40-130: Setup Noise, Mixer, and Volume
    ; ------------------------------------------------
    ; SOUND 6, 15 (Noise Period)
    ld a, 6
    out ($A0), a
    ld a, 15
    out ($A1), a

    ; SOUND 7, 246 (Mixer: Tone A + Noise A)
    ld a, 7
    out ($A0), a
    ld a, 246
    out ($A1), a

    ; SOUND 8, 15 (Volume A to Max)
    ld a, 8
    out ($A0), a
    ld a, 15
    out ($A1), a

    ; ------------------------------------------------
    ; Lines 150-190: The Pitch Sweep (40 to 800, Step 60)
    ; ------------------------------------------------
    ld hl, 40                  ; HL = P (Start at 40)

.missile_sweep_loop:
    ; SOUND 0, P AND 255 (Tone A Low Byte)
    ld a, 0
    out ($A0), a
    ld a, l                    ; The L register holds the low byte of HL
    out ($A1), a

    ; SOUND 1, P \ 256 (Tone A High Byte)
    ld a, 1
    out ($A0), a
    ld a, h                    ; The H register holds the high byte of HL
    out ($A1), a

    ; --- ARTIFICIAL DELAY TO MATCH BASIC SPEED ---
    ; Adjust the 3000 up or down to change the speed of the sound!
    ld de, 3000                
.missile_delay:
    dec de
    ld a, d
    or e
    jr nz, .missile_delay              ; Loop until DE == 0
    ; ---------------------------------------------

    ; P = P + 60
    ld de, 60
    add hl, de

    ; Check if P < 800
    ld de, 800
    or a                       ; Clear the carry flag before subtracting
    push hl                    ; Save current pitch
    sbc hl, de                 ; HL - 800
    pop hl                     ; Restore current pitch
    jr c, .missile_sweep_loop          ; If Carry is set (HL was less than 800), loop again!

    ; ------------------------------------------------
    ; Lines 210-220: Mute the channel
    ; ------------------------------------------------
    ld a, 8
    out ($A0), a
    xor a                      ; A = 0
    out ($A1), a
    ret

