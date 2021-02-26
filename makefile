CC=gcc
ASMBIN=nasm

all: assembler main link clean_object_files

assembler:
	$(ASMBIN) -o find_markers.o -f elf32 find_markers.asm

main:
	$(CC) -m32 -o main.o -c -O0 main.c
link:
	$(CC) -m32 -o find_markers_test main.o find_markers.o

clean_object_files:
	rm *.o

clean:
	rm *.o
	rm find_markers
#	rm func.lst


