all: pfire.rom

../out:
	mkdir -p ../../../out

pfire.rom: main.asm rom.asm | ../../../out
	pasmo ${INCLUDES} rom.asm ../../../out/pfire.rom

.PHONY: clean
clean:
	rm -f ../out/*.rom ../out/*.bin

