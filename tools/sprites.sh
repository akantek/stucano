#!/bin/bash

# Define your file names and scripts here
SPRITE_SCRIPT="simple_sprite_converter.py"

OUTPUT_FILE="../src/spritesheet.asm"

# Helicopter fire input file
HELICOPTER_FIRE="../assets/sprites/helicopter_fire.txt"

# 1. Create the file and add the header
echo "; Auto-generated - don't edit" > "$OUTPUT_FILE"

# Add an empty line + sprite_patterns_start mark
echo "" >> "$OUTPUT_FILE"
echo "sprite_patterns_start:" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 2. Process the helicopter fire sprite and append
python3 "$SPRITE_SCRIPT" "$HELICOPTER_FIRE" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 3. Add sprite_patterns_end mark
echo "sprite_patterns_end:" >> "$OUTPUT_FILE"

echo "Success! Helicopter fire sprite combined into $OUTPUT_FILE"

