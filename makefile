#program32: graph_io32.o findPattern32.o
#	gcc -o program graph_io32.o findPattern32.o -m32
program64: graph_io64.o findPattern64.o
	gcc -o program64 graph_io64.o findPattern64.o
graph_io32.o: graph_io.c
	gcc -c -m32 -fpack-struct graph_io.c -o graph_io32.o
findPattern32.o: findPattern.asm
	nasm -f elf32 -o findPattern32.o findPattern.asm
graph_io64.o: graph_io.c
	gcc -c -m64 -fpack-struct -mno-ms-bitfields graph_io.c -o graph_io64.o -g3
findPattern64.o: findPattern64.asm
	nasm -f elf64 -o findPattern64.o findPattern64.asm
