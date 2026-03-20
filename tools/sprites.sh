#!/bin/bash

# Define your file names here
PYTHON_SCRIPT="simple_sprite_converter.py"
OUTPUT_FILE="../src/spritesheet.asm"
MSX_HELICOPTER_A="../assets/sprites/msx_helicopter_A.txt"
MSX_HELICOPTER_B="../assets/sprites/msx_helicopter_B.txt"

# 1. Create the file and add the header
echo "; Auto-generated - don't edit" > "$OUTPUT_FILE"

# Add an empty line + sprite_patterns_start mark
echo "" >> "$OUTPUT_FILE"
echo "sprite_patterns_start:" >> "$OUTPUT_FILE"

# 2. First run: process the sprite file and append
python3 "$PYTHON_SCRIPT" "$MSX_HELICOPTER_A" >> "$OUTPUT_FILE"

# Add an empty line
echo "" >> "$OUTPUT_FILE"

# 3. Second run: process the sprite file again and append
python3 "$PYTHON_SCRIPT" "$MSX_HELICOPTER_B" >> "$OUTPUT_FILE"

# Add sprite_patterns_end_mark
echo "sprite_patterns_end:" >> "$OUTPUT_FILE"

echo "Success! Output combined into $OUTPUT_FILE"

