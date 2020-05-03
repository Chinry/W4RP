all: synth.ihex
	cd build; hex2bin -l 8000 synth.ihex

synth.ihex: synth.elf
	avr-objcopy --output-target=ihex build/synth.elf build/synth.ihex

synth.elf: synth.o info.o
	avr-ld -o build/synth.elf build/synth.o build/info.o

synth.o:
	avr-as -mmcu=atmega328 -g -o build/synth.o main.s
info.o:
	avr-gcc -mmcu=atmega328 -g -c -o build/info.o info.c

run:
	simavr -v -m atmega328 -f 16000000 -g build/synth.elf

burn:
	sudo minipro -p "ATMEGA328P" -w build/synth.bin || sudo minipro -e -p "ATMEGA328P" -w build/synth.bin
	sudo minipro -e -c config -p "ATMEGA328P" -w fuse.txt

clean:
	rm build/synth.o
	rm build/synth.ihex
	rm build/synth.elf
	rm build/synth.bin
	rm build/synth.s
	rm build/synth.out
