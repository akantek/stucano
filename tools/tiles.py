import sys

# Define the constant at the module level
TILE_MAP_FLOOR = {
    2: "9",
    1: "A",
    0: "0"
}

TILE_MAP_TANK = {
    3: "F",
    2: "9",
    1: "3",
    0: "0"
}

TILE_MAP_FUEL = {
    4: "4",
    3: "8",
    2: "E",
    1: "5",
    0: "0"
}

TILE_MAP_MISSILE = {
    3: "2",
    2: "5",
    1: "9",
    0: "0"
}

TILE_MAP_SKULL = {
    0: "0",
    1: "9"
}

def generate_z80_hex_array(input_data, mapping):
    """
    Converts a string of numbers into a Z80 assembly byte definition 
    by mapping values to hex digits and pairing them.
    """
    # Split line into tokens
    tokens = input_data.strip().split()
    
    if not tokens:
        return ""

    mapped_digits = []
    
    for token in tokens:
        try:
            key = int(token)
        except ValueError:
            continue

        if key in mapping:
            val = mapping[key]
            if isinstance(val, int):
                mapped_digits.append(f"{val:X}")
            else:
                mapped_digits.append(str(val).upper())
        else:
            mapped_digits.append("0")

    hex_bytes = []
    # Step by 2 to pack nibbles into bytes
    for i in range(0, len(mapped_digits), 2):
        high_nibble = mapped_digits[i]
        
        # Handle odd number of digits by padding with 0
        if i + 1 < len(mapped_digits):
            low_nibble = mapped_digits[i+1]
        else:
            low_nibble = "0"
            
        hex_bytes.append(f"${high_nibble}{low_nibble}")
        
    return "db " + ", ".join(hex_bytes)


def main():
    # Now checking for 2 arguments: filename and map_type
    if len(sys.argv) < 3:
        print("Usage: python script.py <filename> <floor|tank|fuel>")
        return

    filename = sys.argv[1]
    map_choice = sys.argv[2].lower()

    # Dictionary to select the map based on user input
    options = {
        "floor": TILE_MAP_FLOOR,
        "tank": TILE_MAP_TANK,
        "fuel": TILE_MAP_FUEL,
        "missile": TILE_MAP_MISSILE,
        "skull": TILE_MAP_SKULL
    }

    if map_choice not in options:
        print(f"Unknown map type: {map_choice}. Choose from floor, tank, or fuel.")
        return

    selected_map = options[map_choice]

    try:
        with open(filename, 'r') as f:
            for line in f:
                if line.strip():
                    # Use the map selected above
                    result = generate_z80_hex_array(line, selected_map)
                    print(result)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")


if __name__ == "__main__":
    main()

