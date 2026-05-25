all: ufo.rom

../out:
	mkdir -p ../../../out

ufo.rom: main.asm rom.asm | ../../../out
	pasmo ${INCLUDES} rom.asm ../../../out/ufo.rom

.PHONY: clean
clean:
	rm -f ../out/*.rom ../out/*.bin

