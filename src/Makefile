all: helicopter.rom

../out:
	mkdir -p ../out

helicopter.rom: main.asm rom.asm | ../out
	pasmo ${INCLUDES} rom.asm ../out/stucano.rom

.PHONY: clean
clean:
	rm -f ../out/*.rom ../out/*.bin

