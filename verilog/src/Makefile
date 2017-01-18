all: mem.hex
	cp mem.hex ../../../verilog_d16/
mem.hex: test.bin
	bin2hex $< $@
%.bin: %.s
	d16 -b $< -o $@

