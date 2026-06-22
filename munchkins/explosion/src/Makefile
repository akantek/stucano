all: explosion.rom

../out:
	mkdir -p ../../../out

explosion.rom: main.asm rom.asm | ../../../out
	pasmo ${INCLUDES} rom.asm ../../../out/explosion.rom

.PHONY: clean
clean:
	rm -f ../out/*.rom ../out/*.bin

