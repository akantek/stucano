import sys
import os

# ANSI Colors for Terminal Preview
class Colors:
    RESET = "\033[0m"
    C0 = "\033[48;5;232m  "  # Transparent
    C1 = "\033[48;5;45m  "   # Layer 1 (Cyan)
    C2 = "\033[48;5;231m  "  # Both (White)
    C3 = "\033[48;5;201m  "  # Layer 2 (Magenta)

def chars_to_byte(char_string, target_digits):
    """Converts an 8-char string of digits into a byte based on target list."""
    byte_val = 0
    for index, char in enumerate(char_string):
        if char in target_digits:
            byte_val |= (1 << (7 - index))
    return byte_val

def preview_sprite(label, cleaned_rows):
    """Prints a colored ASCII representation to stderr, and a commented plain text version to stdout."""
    title = f"--- Preview: {label} ---"
    sys.stderr.write(f"\n{title}\n")
    print(f"; {title}")

    legend = "Legend: 0=Empty, 1=Layer1 (Cyan), 2=Both (White), 3=Layer2 (Magenta)"
    sys.stderr.write(f"{legend}\n")
    print(f"; {legend}")

    border = "+" + "--" * 16 + "+"
    sys.stderr.write(f"{border}\n")
    print(f"; {border}")
    
    for row in cleaned_rows:
        line_str = "|"
        comment_str = "|"
        for char in row:
            if char == '0': 
                line_str += Colors.C0
                comment_str += ". "  # Using a dot for empty space makes the asm comment more readable
            elif char == '1': 
                line_str += Colors.C1
                comment_str += "1 "
            elif char == '2': 
                line_str += Colors.C2
                comment_str += "2 "
            elif char == '3': 
                line_str += Colors.C3
                comment_str += "3 "
            else: 
                line_str += "  "
                comment_str += "  "
        
        line_str += Colors.RESET + "|"
        comment_str += "|"
        
        # Write colors to terminal (stderr)
        sys.stderr.write(line_str + "\n")
        # Write clean plain-text comment to assembly file (stdout)
        print(f"; {comment_str}")

    sys.stderr.write(f"{border}\n")
    print(f"; {border}")
    
    sys.stderr.write(Colors.RESET + "\n")

def parse_sprite_block(rows, label_name):
    """Parses a list of 16 strings into two 32-byte arrays."""
    if len(rows) != 16:
        raise ValueError(f"Error in '{label_name}': Expected 16 rows, found {len(rows)}.")

    # Show preview
    preview_sprite(label_name, rows)

    s1_left, s1_right = [], []
    s2_left, s2_right = [], []

    for row in rows:
        # Pad or trim to exactly 16 chars
        row = row.ljust(16, '0')[:16]
        
        left_chars = row[0:8]
        right_chars = row[8:16]

        # --- PROCESS SPRITE 1 (Colors 1 & 2) ---
        # Logic: 1 and 2 -> Bit 1. (3 -> 0)
        s1_left.append(chars_to_byte(left_chars, target_digits=['1', '2']))
        s1_right.append(chars_to_byte(right_chars, target_digits=['1', '2']))

        # --- PROCESS SPRITE 2 (Colors 2 & 3) ---
        # Logic: 2 and 3 -> Bit 1. (1 -> 0)
        s2_left.append(chars_to_byte(left_chars, target_digits=['2', '3']))
        s2_right.append(chars_to_byte(right_chars, target_digits=['2', '3']))

    return (s1_left + s1_right), (s2_left + s2_right)

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
                s1, s2 = parse_sprite_block(current_rows, current_label)
                parsed_sprites.append((current_label, s1, s2))
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
        s1, s2 = parse_sprite_block(current_rows, current_label)
        parsed_sprites.append((current_label, s1, s2))
    elif not current_label and len(current_rows) == 16:
        # Handle case where file has no labels, just raw matrix
        s1, s2 = parse_sprite_block(current_rows, "sprite")
        parsed_sprites.append(("sprite", s1, s2))

    return parsed_sprites

def main():
    if len(sys.argv) < 2:
        print("Usage: python multi_sprite_converter.py <path_to_text_file>")
        sys.exit(1)

    file_path = sys.argv[1]
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found.")
        sys.exit(1)

    try:
        with open(file_path, 'r') as f:
            raw_data = f.read()
        
        file_basename = os.path.splitext(os.path.basename(file_path))[0]
        
        print(f"; Source: {file_path}")
        print(f"sprite_patterns_{file_basename}_start:")
        
        results = process_file_content(raw_data)
        
        for section_label, sprite1, sprite2 in results:
            # Construct assembly label: filename_section_LayerX
            # e.g., helicopter_right_Layer1
            full_label = f"{file_basename}_{section_label}"
            
            print_assembly(f"{full_label}_Layer1", sprite1)
            print_assembly(f"{full_label}_Layer2", sprite2)
            
        print(f"sprite_patterns_{file_basename}_end:")

    except Exception as e:
        sys.stderr.write(f"Error: {e}\n")
        print(f"; Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
