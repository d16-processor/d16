all: reg_tb


reg_tb: register_unit.o register_file_tb.o
	ghdl -e reg_tb
	./reg_tb --stop-time=500ns --vcd=dump.vcd
	gtkwave dump.vcd
	
	
%.o: ../tests/%.vhd
	ghdl -a $< 
	
%.o: ../src/%.vhd
	ghdl -a $< 

