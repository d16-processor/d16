transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/verilog_d16 {/home/mnolan/projects/d16/verilog_d16/pll1.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/fifo.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/lr.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/uart.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/leds.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/mem.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/ntsc_gen.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/verilog_d16/db {/home/mnolan/projects/d16/verilog_d16/db/pll1_altpll.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/verilog_d16 {/home/mnolan/projects/d16/verilog_d16/ram_macro.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/timer.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/sound.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/verilog_d16/db {/home/mnolan/projects/d16/verilog_d16/db/sdram_clk_gen_altpll.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/bus_arbiter.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/uart_controller.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/mmio.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/register_unit.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/pc_unit.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/decoder.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/core.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/control.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/alu.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/dma_controller.v}
vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/d16/verilog/src {/home/mnolan/projects/d16/d16/verilog/src/top.v}
vcom -2008 -work work {/home/mnolan/projects/d16/d16/verilog/src/sdram_controller.vhd}
vcom -2008 -work work {/home/mnolan/projects/d16/verilog_d16/sdram_clk_gen.vhd}

vlog -vlog01compat -work work +incdir+/home/mnolan/projects/d16/verilog_d16/../d16/verilog/src {/home/mnolan/projects/d16/verilog_d16/../d16/verilog/src/core_tb.v}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf_ver -L altera_lnsim -L cycloneive -L rtl_work -L work -voptargs="+acc"  core_tb

add wave -hex *
add wave -hex \
sim:/core_tb/core/dma/remote_addr \
sim:/core_tb/core/dma/dma_in_progress \
sim:/core_tb/core/dma/ram_addr \
sim:/core_tb/core/dma/ram_data_out \
sim:/core_tb/core/dma/ram_data_in \
sim:/core_tb/core/dma/ram_we  \
sim:/core_tb/core/mem/*
view structure
view signals
run 2000 ns
