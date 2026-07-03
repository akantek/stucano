all: gauntlet.rom

../out:
	mkdir -p ../../../out

gauntlet.rom: main.asm rom.asm | ../../../out
	pasmo ${INCLUDES} rom.asm ../../../out/gauntlet.rom

.PHONY: clean
clean:
	rm -f ../out/*.rom ../out/*.bin

