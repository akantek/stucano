OUT_DIR = ../../../out
TARGET = $(OUT_DIR)/pfire.rom

.PHONY: all clean

all: $(TARGET)

# Create the output directory
$(OUT_DIR):
	mkdir -p $(OUT_DIR)

# The target path must perfectly match the Pasmo output path
$(TARGET): main.asm rom.asm | $(OUT_DIR)
	pasmo $(INCLUDES) rom.asm $(TARGET)

clean:
	rm -f $(OUT_DIR)/*.rom $(OUT_DIR)/*.bin

