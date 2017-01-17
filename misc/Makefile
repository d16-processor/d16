all: bin2hex

bin2hex: bin2hex.c
	$(CC) -Wall -Wextra $< -o $@
install: bin2hex
	instll bin2hex /usr/local/bin/


.PHONY: all install
