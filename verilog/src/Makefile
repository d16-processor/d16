hex2mif:= ~/projects/d16/verilog_d16/hextomif.py
mem.hex: test.bin
	bin2hex $< $@
%.bin: %.s
	d16 -b $< -o $@

install: mem.hex
	python $(hex2mif) mem.hex ../../../verilog_d16/mem.mif
.PHONY: install
