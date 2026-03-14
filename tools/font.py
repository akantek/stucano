import sys
import argparse
import os

# --- Configuration ---
# MSX Color codes: 0=Transparent, 1=Black, ..., 15=White
DEFAULT_FG_COLOR = 15 
DEFAULT_BG_COLOR = 0
LABEL_PREFIX = "font_"  # Prepended to the name found in the file to make valid labels

def parse_font_file(filepath):
    """
    Reads the file and parses it into a dictionary of {name: [rows]}.
    """
    tiles = []
    current_name = None
    current_rows = []

    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: File '{filepath}' not found.")
        sys.exit(1)

    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        if line.startswith("--"):
            # Save previous tile if it exists
            if current_name is not None and current_rows:
                tiles.append((current_name, current_rows))
            
            # Start new tile: Extract name after "-- "
            # Example: "-- 0" -> name is "0"
            parts = line.split(maxsplit=1)
            if len(parts) > 1:
                current_name = parts[1].strip()
            else:
                current_name = "Unknown"
            current_rows = []
        else:
            # Validate row length (0/1 string)
            if len(line) != 8:
                # specific to the 0/1 font format
                line = line.ljust(8, '0')[:8]
            current_rows.append(line)

    # Save the last tile
    if current_name is not None and current_rows:
        tiles.append((current_name, current_rows))
        
    return tiles

def row_to_sc5_bytes(row_str, fg, bg):
    """
    Converts a single string "00011100" into MSX SC5 packed bytes.
    Returns a list of integer byte values.
    """
    bytes_list = []
    for x in range(0, 8, 2):
        p1_char = row_str[x]
        p2_char = row_str[x+1]
        
        c1 = fg if p1_char == '1' else bg
        c2 = fg if p2_char == '1' else bg
        
        # Pack: High nibble = Left pixel, Low nibble = Right pixel
        packed = (c1 << 4) | (c2 & 0x0F)
        bytes_list.append(packed)
    return bytes_list

def generate_assembly_text(tiles, fg, bg):
    """
    Generates text output in Z80 assembly format (db statements).
    """
    output_lines = []
    output_lines.append(f"; MSX2+ SCREEN 5 Font Data (4bpp)")
    output_lines.append(f"; FG Color: {fg}, BG Color: {bg}")
    output_lines.append("")

    for name, rows in tiles:
        # Create a safe label (e.g., Tile_0)
        safe_label = f"{LABEL_PREFIX}{name}"
        output_lines.append(f"{safe_label}:")
        
        for row in rows:
            # Convert row to 4 bytes
            byte_vals = row_to_sc5_bytes(row, fg, bg)
            # Format as hex strings: 0x0F, $0F, or 0FH. Using standard 0x for generic compatibility.
            hex_strings = [f"0x{b:02X}" for b in byte_vals]
            joined_hex = ", ".join(hex_strings)
            
            output_lines.append(f"    db {joined_hex} \t; {row.replace('0', '.').replace('1', '#')}")
        
        output_lines.append("") # Empty line between tiles
        
    return "\n".join(output_lines)

def main():
    parser = argparse.ArgumentParser(description="Convert 1-bit font text to MSX SCREEN 5 assembly data.")
    parser.add_argument("input_file", help="Path to the input text file containing font data")
    parser.add_argument("--color", type=int, default=DEFAULT_FG_COLOR, help=f"Foreground color code (0-15), default is {DEFAULT_FG_COLOR}")
    parser.add_argument("--out", help="Optional output file path. If omitted, prints to console.")
    
    args = parser.parse_args()

    # Parse
    tiles = parse_font_file(args.input_file)
    
    # Convert
    output_text = generate_assembly_text(tiles, args.color, DEFAULT_BG_COLOR)
    
    # Output
    if args.out:
        with open(args.out, 'w') as f:
            f.write(output_text)
        print(f"Successfully converted {len(tiles)} tiles to '{args.out}'.")
    else:
        print(output_text)

if __name__ == "__main__":
    main()

