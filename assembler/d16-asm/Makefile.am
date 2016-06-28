AUTOMAKE_OPTIONS = foreign
CFLAGS = -O2 -Wall
LDFLAGS = -lglib-2.0
bin_PROGRAMS = d16
YFLAGS=-d -o y.tab.c
LFLAGS= -o lex.c
d16_SOURCES = parser.y main.c lex.l instruction.c instruction.h
d16_CFLAGS = $(GLIB_CFLAGS)
d16_LIBS = $(GLIB LIBS)

TESTS = d16_tests ../d16-tests/regression/tests.py
check_PROGRAMS = d16_tests

d16_tests_SOURCES = main.c instruction.c main.h instruction.h ../d16-tests/test_instruction.c ../d16-tests/test_main.c ../d16-tests/unity.c ../d16-tests/testing_main.c
d16_tests_CFLAGS = $(GLIB_CFLAGS) -DTESTING
d16_tests_LIBS = $(GLIB LIBS)
clean-local:
	rm -f parser.h parser.c
	rm -f lex.yy.h lex.c
	rm -f y.tab.*
