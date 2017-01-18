mem.hex: test.bin
	bin2hex $< $@
%.bin: %.s
	d16 -b $< -o $@

install: mem.hex
	cp mem.hex ../../../verilog_d16/
.PHONY: install
