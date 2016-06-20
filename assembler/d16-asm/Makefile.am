AUTOMAKE_OPTIONS = foreign
CFLAGS = -O2 -Wall
LDFLAGS = -lglib-2.0
bin_PROGRAMS = d16
YFLAGS=-d -o y.tab.c
d16_SOURCES = parser.y main.c lex.l instruction.c instruction.h
d16_CFLAGS = $(GLIB_CFLAGS)
d16_LIBS = $(GLIB LIBS)
clean-local:
	rm -f parser.h parser.c
	rm -f lex.yy.h lex.c
	rm -f y.tab.*
