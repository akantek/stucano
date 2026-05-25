all: vblank.rom

../out:
	mkdir -p ../../../out

vblank.rom: main.asm rom.asm | ../../../out
	pasmo ${INCLUDES} rom.asm ../../../out/vblank.rom

.PHONY: clean
clean:
	rm -f ../out/*.rom ../out/*.bin

