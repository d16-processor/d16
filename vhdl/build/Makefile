tests: reg_tb decoder_tb alu_tb
tests-list:
	@echo "tests:"
	@echo "	reg_tb"
	@echo "	decoder_tb"
	@echo " alu_tb"



reg_tb: register_unit.o register_unit_tb.o
	ghdl -e reg_tb
	./reg_tb --stop-time=500ns --vcd=dump.vcd
	gtkwave dump.vcd
decoder_tb: cpu_constants.o decoder.o decoder_tb.o 
	ghdl -e decoder_tb
	./decoder_tb --stop-time=200ns --vcd=dump.vcd
	gtkwave dump.vcd
alu_tb: cpu_constants.o alu.o alu_tb.o
	ghdl -e alu_tb
	./alu_tb --stop-time=150ns --vcd=dump.vcd
	gtkwave dump.vcd
control_tb: cpu_constants.o control.o control_tb.o
	ghdl -e control_tb
	./control_tb --stop-time=300ns --vcd=dump.vcd
	gtkwave dump.vcd	
pc_tb: cpu_constants.o pc_unit.o pc_tb.o
	ghdl -e pc_tb
	./pc_tb --stop-time=150ns --vcd=dump.vcd
	gtkwave dump.vcd
alu_tb.o: ../tests/alu_tb.vhd ../src/alu.vhd
	ghdl -a $<
%.o: ../tests/%.vhd
	ghdl -a $< 
	
%.o: ../src/%.vhd
	ghdl -a $< 

