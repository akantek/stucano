all: player_vs_ufo.rom

../out:
	mkdir -p ../../../out

player_vs_ufo.rom: main.asm rom.asm | ../../../out
	pasmo ${INCLUDES} rom.asm ../../../out/player_vs_ufo.rom

.PHONY: clean
clean:
	rm -f ../out/*.rom ../out/*.bin

