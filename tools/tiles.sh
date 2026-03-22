#!/bin/bash

# Define your paths and script name here
PYTHON_SCRIPT="tiles.py" # Change this to the actual name of your Python script
ASSETS_DIR="../assets/tiles"
OUTPUT_FILE="../src/tilesheet.asm"

# 1. Initialize the output file (overwrites if it already exists)
echo "; Auto-generated tilesheet - don't edit" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 2. Helper function to process each file and append it
process_tile() {
    local filename=$1
    local map_type=$2
    
    # Extract just the base name without the .txt extension for the label
    local label_name=$(basename "$filename" .txt)

    # Write the label (e.g., tile8:)
    echo "${label_name}:" >> "$OUTPUT_FILE"
    
    # Run the python script and append the 'db' lines
    python3 "$PYTHON_SCRIPT" "${ASSETS_DIR}/${filename}" "$map_type" >> "$OUTPUT_FILE"
    
    # Add an empty line for readability
    echo "" >> "$OUTPUT_FILE"
}

# 3. Process files using pattern matching to automatically catch all files

echo "Processing floor tiles..."
for file in "$ASSETS_DIR"/tile*.txt; do
    # Check if file exists to prevent errors if the directory is empty
    [ -e "$file" ] || continue 
    process_tile "$(basename "$file")" "floor"
done

echo "Processing tank tiles..."
for file in "$ASSETS_DIR"/tank*.txt; do
    [ -e "$file" ] || continue
    process_tile "$(basename "$file")" "tank"
done

echo "Processing fuel tiles..."
for file in "$ASSETS_DIR"/fuel*.txt; do
    [ -e "$file" ] || continue
    process_tile "$(basename "$file")" "fuel" # Change "fuel" if your python script expects a different map_type
done

echo "Success! Tilesheet generated at $OUTPUT_FILE"
