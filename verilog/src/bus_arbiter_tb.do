vlog ../../../d16/verilog/src/bus_arbiter.v
vlog ../../../d16/verilog/src/bus_arbiter_tb.v
vsim bus_arbiter_tb
add wave -position insertpoint  \
sim:/bus_arbiter_tb/addr1 \
sim:/bus_arbiter_tb/addr2 \
sim:/bus_arbiter_tb/clk \
sim:/bus_arbiter_tb/data1 \
sim:/bus_arbiter_tb/data_in2 \
sim:/bus_arbiter_tb/data_out2 \
sim:/bus_arbiter_tb/data_valid1 \
sim:/bus_arbiter_tb/data_valid2 \
sim:/bus_arbiter_tb/dram_addr \
sim:/bus_arbiter_tb/dram_data_in \
sim:/bus_arbiter_tb/dram_data_out \
sim:/bus_arbiter_tb/dram_data_out_valid \
sim:/bus_arbiter_tb/dram_req_read \
sim:/bus_arbiter_tb/dram_req_write \
sim:/bus_arbiter_tb/dram_write_complete \
sim:/bus_arbiter_tb/req_read1 \
sim:/bus_arbiter_tb/req_read2 \
sim:/bus_arbiter_tb/req_write2 \
sim:/bus_arbiter_tb/write_complete2

run 1000ns
