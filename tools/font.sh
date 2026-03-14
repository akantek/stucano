#!/bin/bash

OUTPUT_FILE="../src/font.asm"

# Write the header and all the EQU definitions using a Here Document
cat << 'EOF' > "$OUTPUT_FILE"
; Auto-generated - don't edit

FONT_CHAR_COUNT:      EQU (font_data_end - font_data_start) / 32

; --- Digits ---
DIGIT_0:              EQU 0
DIGIT_1:              EQU 1
DIGIT_2:              EQU 2
DIGIT_3:              EQU 3
DIGIT_4:              EQU 4
DIGIT_5:              EQU 5
DIGIT_6:              EQU 6
DIGIT_7:              EQU 7
DIGIT_8:              EQU 8
DIGIT_9:              EQU 9

; --- Letters ---
LETTER_A:             EQU 10
LETTER_B:             EQU 11
LETTER_C:             EQU 12
LETTER_D:             EQU 13
LETTER_E:             EQU 14
LETTER_F:             EQU 15
LETTER_G:             EQU 16
LETTER_H:             EQU 17
LETTER_I:             EQU 18
LETTER_J:             EQU 19
LETTER_K:             EQU 20
LETTER_L:             EQU 21
LETTER_M:             EQU 22
LETTER_N:             EQU 23
LETTER_O:             EQU 24
LETTER_P:             EQU 25
LETTER_Q:             EQU 26
LETTER_R:             EQU 27
LETTER_S:             EQU 28
LETTER_T:             EQU 29
LETTER_U:             EQU 30
LETTER_V:             EQU 31
LETTER_W:             EQU 32
LETTER_X:             EQU 33
LETTER_Y:             EQU 34
LETTER_Z:             EQU 35

; --- Symbols ---
LETTER_INTERROGATION: EQU 36
LETTER_SEMI:          EQU 37
LETTER_SPACE:         EQU 38

font_data_start:
EOF

# Run the Python tool and append its hex output
python3 ./font.py ../assets/fonts/font.txt >> "$OUTPUT_FILE"

# Append the closing label so FONT_CHAR_COUNT can be calculated
echo "font_data_end:" >> "$OUTPUT_FILE"

echo "Success: Font data written to $OUTPUT_FILE"

