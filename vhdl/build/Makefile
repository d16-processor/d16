
tests: reg_tb decoder_tb alu_tb control_tb pc_tb mem_tb
tests-list:
	@echo "tests:"
	@echo "	reg_tb"
	@echo "	decoder_tb"
	@echo " alu_tb"



reg_tb: register_unit.o register_unit_tb.o
	ghdl -e reg_tb
	./reg_tb --stop-time=500ns --vcd=dump.vcd
ifdef WAVE
	gtkwave dump.vcd
endif
mem_tb: mem.o mem_tb.o mem.bin
	ghdl -e mem_tb
	./mem_tb --stop-time=500ns --vcd=dump.vcd
ifdef WAVE
	gtkwave dump.vcd
endif


decoder_tb: cpu_constants.o decoder.o decoder_tb.o 
	ghdl -e decoder_tb
	./decoder_tb --stop-time=200ns --vcd=dump.vcd
ifdef WAVE
	gtkwave dump.vcd
endif
alu_tb: cpu_constants.o alu.o alu_tb.o
	ghdl -e alu_tb
	./alu_tb --stop-time=200ns --vcd=dump.vcd
	
ifdef WAVE
	gtkwave dump.vcd
endif
control_tb: cpu_constants.o control.o control_tb.o
	ghdl -e control_tb
	./control_tb --stop-time=300ns --vcd=dump.vcd
ifdef WAVE
	gtkwave dump.vcd
endif	
pc_tb: cpu_constants.o pc_unit.o pc_tb.o
	ghdl -e pc_tb
	./pc_tb --stop-time=150ns --vcd=dump.vcd
ifdef WAVE
	gtkwave dump.vcd
endif
core_tb: cpu_constants.o core_tb.o pc_unit.o alu.o control.o decoder.o mem.o register_unit.o mem.bin
	ghdl -e core_tb
	./core_tb --stop-time=700ns --vcd=dump.vcd
ifdef WAVE
	gtkwave dump.vcd
endif

cpu_tb: cpu_constants.o cpu_tb.o core.o pc_unit.o alu.o control.o decoder.o mem.o register_unit.o mem.bin
	ghdl -e cpu_tb
	./cpu_tb --stop-time=700ns --vcd=dump.vcd
ifdef WAVE
	gtkwave dump.vcd
endif

%_tb: cpu_constants.o %.o %_tb.o
	ghdl -e $@
	./$@ --stop-time=150ns --vcd=dump.vcd
ifdef WAVE
	gtkwave dump.vcd
endif
alu_tb.o: ../tests/alu_tb.vhd ../src/alu.vhd
	ghdl -a $<
%.o: ../tests/%.vhd
	ghdl -a $< 
	
%.o: ../src/%.vhd
	ghdl -a $< 
mem.bin: test.s
	d16 test.s mem.bin

clean:
	-rm -f *.o
	-rm -f *_tb
	
