import sys
import os

def chars_to_byte(char_string):
    """Converts an 8-char string of digits into a byte."""
    byte_val = 0
    for index, char in enumerate(char_string):
        # We only check for '1' now
        if char == '1':
            byte_val |= (1 << (7 - index))
    return byte_val

def preview_sprite(label, cleaned_rows):
    """Prints an ASCII representation of the sprite as assembly comments."""
    print(f"; --- Preview: {label} ---")
    print("; Legend: 0=Empty, 1=Filled")
    print("; +" + "--" * 16 + "+")
    
    for row in cleaned_rows:
        line_str = "; |"
        for char in row:
            if char == '1': 
                line_str += "##" # Filled block representation
            else: 
                line_str += "  " # Empty space representation
        line_str += "|"
        print(line_str)

    print("; +" + "--" * 16 + "+")
    print(";")

def parse_sprite_block(rows, label_name):
    """Parses a list of 16 strings into one 32-byte array."""
    if len(rows) != 16:
        raise ValueError(f"Error in '{label_name}': Expected 16 rows, found {len(rows)}.")

    # Show preview (now formats as assembly comments)
    preview_sprite(label_name, rows)

    s_left = []
    s_right = []

    for row in rows:
        # Pad or trim to exactly 16 chars
        row = row.ljust(16, '0')[:16]
        
        left_chars = row[0:8]
        right_chars = row[8:16]

        # Convert to bytes
        s_left.append(chars_to_byte(left_chars))
        s_right.append(chars_to_byte(right_chars))

    # Return concatenated list (Left 16 bytes + Right 16 bytes)
    # This matches standard MSX 16x16 sprite pattern layout
    return s_left + s_right

def print_assembly(label_base, bytes_data):
    print(f"{label_base}:")
    for i in range(0, 32, 8):
        chunk = bytes_data[i:i+8]
        hex_str = ", ".join([f"${b:02X}" for b in chunk])
        print(f"\tdb {hex_str}")
    print("")

def process_file_content(content):
    lines = content.strip().split('\n')
    
    current_label = None
    current_rows = []
    
    # Store results to print them cleanly at the end
    parsed_sprites = []

    for line in lines:
        line = line.strip()
        
        # Skip empty lines
        if not line:
            continue
            
        # Check if line is a label (ends with :)
        if line.endswith(':'):
            # If we were already building a sprite, process it now
            if current_label and len(current_rows) > 0:
                sprite_data = parse_sprite_block(current_rows, current_label)
                parsed_sprites.append((current_label, sprite_data))
                current_rows = []
            
            # Start new section
            current_label = line[:-1] # Remove the ':'
        else:
            # It's data
            # Clean spaces inside the line (e.g., "0000 0000" -> "00000000")
            clean_digits = line.replace(' ', '')
            current_rows.append(clean_digits)

    # Process the final block if it exists
    if current_label and len(current_rows) > 0:
        sprite_data = parse_sprite_block(current_rows, current_label)
        parsed_sprites.append((current_label, sprite_data))
    elif not current_label and len(current_rows) == 16:
        # Handle case where file has no labels, just raw matrix
        sprite_data = parse_sprite_block(current_rows, "sprite")
        parsed_sprites.append(("sprite", sprite_data))

    return parsed_sprites

def main():
    if len(sys.argv) < 2:
        print("; Usage: python simple_sprite_converter.py <path_to_text_file>")
        sys.exit(1)

    file_path = sys.argv[1]
    if not os.path.exists(file_path):
        print(f"; Error: File '{file_path}' not found.")
        sys.exit(1)

    try:
        with open(file_path, 'r') as f:
            raw_data = f.read()
        
        file_basename = os.path.splitext(os.path.basename(file_path))[0]
        
        print(f"; Source: {file_path}")
        print(f"sprite_patterns_{file_basename}_start:")
        
        results = process_file_content(raw_data)
        
        for section_label, sprite_data in results:
            # Construct assembly label: filename_section
            full_label = f"{file_basename}_{section_label}"
            print_assembly(full_label, sprite_data)
            
        print(f"sprite_patterns_{file_basename}_end:")

    except Exception as e:
        print(f"; Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

