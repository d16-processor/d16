hex2mif:= ~/projects/d16/verilog_d16/hextomif.py
mem.hex: test.bin
	bin2hex $< $@
%.bin: %.s
	d16 -b $< -o $@

install: test.bin
	cp test.bin ../../../verilog_d16/mem.bin
.PHONY: install
