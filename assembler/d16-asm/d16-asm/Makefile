#for you linux lovers :P
CFLAGS=-I/usr/local/Cellar/glib/2.46.2/include/glib-2.0 -I/usr/local/Cellar/glib/2.46.2/lib/glib-2.0/include
LDFLAGS=-lglib-2.0.0 -L/usr/local/lib/
all:d16-asm

d16-asm: main.o lex.yy.o y.tab.o instruction.o
	gcc $(LDFLAGS) main.o lex.yy.o y.tab.o instruction.o -o d16-asm

%.yy.c: %.l
	flex -o $@ $<
y.tab.c: parser.y
	bison -y -d $<
%.o: %.c 
	gcc $(CFLAGS) -c $< -o $@
main.o: main.c y.tab.c
	gcc $(CFLAGS) -c $< -o $@
clean:
	-rm -f *.o
	-rm -f *.yy.*
	-rm -f *.tab.*
	-rm -f d16-asm
