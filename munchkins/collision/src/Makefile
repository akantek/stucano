all: collision.rom

../out:
	mkdir -p ../../../out

collision.rom: main.asm rom.asm | ../../../out
	pasmo ${INCLUDES} rom.asm ../../../out/collision.rom

.PHONY: clean
clean:
	rm -f ../out/*.rom ../out/*.bin

