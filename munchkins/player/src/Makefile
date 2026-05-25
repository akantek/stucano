all: player.rom

../out:
	mkdir -p ../../../out

player.rom: main.asm rom.asm | ../out
	pasmo ${INCLUDES} rom.asm ../../../out/player.rom

.PHONY: clean
clean:
	rm -f ../out/*.rom ../out/*.bin

