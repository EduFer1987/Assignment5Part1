CROSS_COMPILE ?=aarch64-none-linux-gnu-


all: writer.c
	$(CROSS_COMPILE)gcc writer.c -o writer

clean:
	rm -f writer
	rm -f *.o
	rm -f *.elf
	rm -f *.list
	rm -f *.bc
	rm -f *.s

