all: sprites.rom

../out:
	mkdir -p ../../../out

sprites.rom: main.asm rom.asm | ../../../out
	pasmo ${INCLUDES} rom.asm ../../../out/sprites.rom

.PHONY: clean
clean:
	rm -f ../out/*.rom ../out/*.bin

