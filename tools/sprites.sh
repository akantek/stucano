#!/bin/bash

# Define your file names and scripts here
SPRITE_SCRIPT="simple_sprite_converter.py"
MULTI_COLOR_SPRITE_SCRIPT="multi_color_sprites_converter.py"

OUTPUT_FILE="../src/spritesheet.asm"

# Input files for multi-color sprites
HELICOPTER_A="../assets/sprites/helicopter_A.txt"
HELICOPTER_B="../assets/sprites/helicopter_B.txt"
HELICOPTER_C="../assets/sprites/helicopter_C.txt"

# Input files for simple sprites
MSX_HELICOPTER_A="../assets/sprites/msx_helicopter_A.txt"
MSX_HELICOPTER_B="../assets/sprites/msx_helicopter_B.txt"

# 1. Create the file and add the header
echo "; Auto-generated - don't edit" > "$OUTPUT_FILE"

# Add an empty line + sprite_patterns_start mark
echo "" >> "$OUTPUT_FILE"
echo "sprite_patterns_start:" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 2. Process multi-color sprites first and append
python3 "$MULTI_COLOR_SPRITE_SCRIPT" "$HELICOPTER_A" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

python3 "$MULTI_COLOR_SPRITE_SCRIPT" "$HELICOPTER_B" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

python3 "$MULTI_COLOR_SPRITE_SCRIPT" "$HELICOPTER_C" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 3. Process simple sprites and append
python3 "$SPRITE_SCRIPT" "$MSX_HELICOPTER_A" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

python3 "$SPRITE_SCRIPT" "$MSX_HELICOPTER_B" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 4. Add sprite_patterns_end mark
echo "sprite_patterns_end:" >> "$OUTPUT_FILE"

echo "Success! Output combined into $OUTPUT_FILE"
