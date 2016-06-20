tests: reg_tb decoder_tb
tests-list:
	@echo "tests:"
	@echo "	reg_tb"
	@echo "	decoder_tb"



reg_tb: register_unit.o register_unit_tb.o
	ghdl -e reg_tb
	./reg_tb --stop-time=500ns --vcd=dump.vcd
	gtkwave dump.vcd
decoder_tb: cpu_constants.o decoder.o decoder_tb.o 
	ghdl -e decoder_tb
	./decoder_tb --stop-time=200ns --vcd=dump.vcd
	gtkwave dump.vcd
	
%.o: ../tests/%.vhd
	ghdl -a $< 
	
%.o: ../src/%.vhd
	ghdl -a $< 

