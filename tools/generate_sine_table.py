import math

def generate_offset_sine_table(amplitude, table_size):
    """Generates a zero-centered Z80 assembly sine offset table using Two's Complement."""
    print(f"; Generated Sine Offset Table (Amplitude: +/-{amplitude}, Size: {table_size})")
    print("sine_offset_table:")
    
    for i in range(table_size):
        # Calculate angle in radians
        angle = (i / table_size) * 2 * math.pi
        
        # Calculate Y offset (centered at 0)
        y_offset = int(amplitude * math.sin(angle))
        
        # Convert to 8-bit Two's Complement (e.g., -1 becomes 255 / $FF)
        twos_comp = y_offset & 0xFF
        
        # Format nicely for Z80
        if i % 8 == 0:
            if i != 0:
                print("") # Newline for the end of the previous row
            print("  db ", end="")
        else:
            print(", ", end="")
            
        print(f"${twos_comp:02X}", end="")
        
    print("\n") # Final newline

def main():
    # Amplitude: +/- 30 pixels
    # Table size: 256 bytes for fast 8-bit overflow indexing
    generate_offset_sine_table(amplitude=30, table_size=256)

if __name__ == "__main__":
    main()

