#for you linux lovers :P
all:d16-asm

d16-asm: main.o lex.yy.o y.tab.o
	gcc main.o lex.yy.o y.tab.o -o d16-asm

%.yy.c: %.l
	flex -o $@ $<
y.tab.c: parser.y
	bison -y -d $<
%.o: %.c 
	gcc -c $< -o $@
main.o: main.c y.tab.c
	gcc -c $< -o $@
clean:
	-rm -f *.o
	-rm -f *.yy.*
	-rm -f *.tab.*
	-rm -f d16-asm
