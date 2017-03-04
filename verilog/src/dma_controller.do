vlog ../../../d16/verilog/src/dma_controller.v
vlog ../../../d16/verilog/src/dma_controller_tb.v
vsim dma_controller_tb
add wave -position insertpoint  \
sim:/dma_controller_tb/addr \
sim:/dma_controller_tb/clk \
sim:/dma_controller_tb/data_in \
sim:/dma_controller_tb/dram_addr \
sim:/dma_controller_tb/dram_data_in \
sim:/dma_controller_tb/dram_data_out \
sim:/dma_controller_tb/dram_data_valid \
sim:/dma_controller_tb/dram_req_read \
sim:/dma_controller_tb/dram_req_write \
sim:/dma_controller_tb/dram_write_complete \
sim:/dma_controller_tb/en \
sim:/dma_controller_tb/ram_addr \
sim:/dma_controller_tb/ram_data_in \
sim:/dma_controller_tb/ram_data_out \
sim:/dma_controller_tb/ram_we \
sim:/dma_controller_tb/rst \
sim:/dma_controller_tb/write_enable
add wave -position insertpoint  \
sim:/dma_controller_tb/dma/state
add wave -position insertpoint  \
sim:/dma_controller_tb/dma/local_addr \
sim:/dma_controller_tb/dma/ram_data \
sim:/dma_controller_tb/dma/remote_addr \
sim:/dma_controller_tb/dma/dma_in_progress \
sim:/dma_controller_tb/dma/count 
run 1000ns
