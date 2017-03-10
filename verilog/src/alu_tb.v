//deps: alu.v
`timescale 1ns/1ps
`undef assert
`include "cpu_constants.vh"
`define assert(signal, value) \
        if (signal !== value) \
            $display("ASSERTION FAILED in %m: signal != value"); \
        
module alu_tb;
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [15:0]		SP_out;			// From alu of alu.v
wire [3:0]		flags_out;		// From alu of alu.v
wire			lr_wr_en;		// From alu of alu.v
wire [15:0]		mem_data;		// From alu of alu.v
wire [15:0]		out;			// From alu of alu.v
wire			should_branch;		// From alu of alu.v
wire			write;			// From alu of alu.v
// End of automatics
/*AUTOREGINPUT*/
// Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
reg [7:0]		alu_control;		// To alu of alu.v
reg			clk;			// To alu of alu.v
reg [3:0]		condition;		// To alu of alu.v
reg			en;			// To alu of alu.v
reg			en_imm;			// To alu of alu.v
reg [3:0]		flags_in;		// To alu of alu.v
reg [15:0]		immediate;		// To alu of alu.v
reg			mem_displacement;	// To alu of alu.v
reg [15:0]		rD_data;		// To alu of alu.v
reg [15:0]		rS_data;		// To alu of alu.v
// End of automatics
alu alu(/*AUTOINST*/
	// Outputs
	.should_branch			(should_branch),
	.out				(out[15:0]),
	.mem_data			(mem_data[15:0]),
	.write				(write),
	.flags_out			(flags_out[3:0]),
	.SP_out				(SP_out[15:0]),
	.lr_wr_en			(lr_wr_en),
	// Inputs
	.clk				(clk),
	.en				(en),
	.alu_control			(alu_control[7:0]),
	.en_imm				(en_imm),
	.rD_data			(rD_data[15:0]),
	.rS_data			(rS_data[15:0]),
	.immediate			(immediate[15:0]),
	.condition			(condition[3:0]),
	.flags_in			(flags_in[3:0]),
	.mem_displacement		(mem_displacement));
    initial begin
        alu_control <= 0;
        clk <= 0;
        condition <= 0;
        en <= 0;
        en_imm <= 0;
        flags_in <= 0;
        immediate <= 0;
        mem_displacement <= 0;
        rD_data <= 0;
        rS_data <= 0;
        
        $dumpfile("dump.vcd");
        $dumpvars;
    end
    always #5 clk <= ~clk;
    initial begin
        #20 en <= 1;
            rD_data <= 5;
            rS_data <= 2;
            alu_control <= `OPC_ADD;
            en_imm <= 0;

        #10 `assert(out, 7)
            alu_control <= `OPC_SUB;
        #10 `assert(out, 3)
            alu_control <= `OPC_MOV;
            en_imm <= 1;
            immediate <= 16'h001d;
        #10 `assert(out,16'h1d)
            rD_data <= 16'h7fff;
            immediate <= 16'h0001;
            alu_control <= `OPC_ADD;
        #10 `assert(out, 16'h8000)
            rD_data <= 16'h0fa5;
            rS_data <= 16'h1d3c;
            en_imm <= 0;
            alu_control <= `OPC_AND;
        #10 `assert(out, 16'h0d24)
            alu_control <= `OPC_OR;
        #10 `assert(out,16'h1fbd)
            alu_control <= `OPC_XOR;
        #10 `assert(out,16'h1299)
            alu_control <= `OPC_NOT;
        #10 `assert(out,'hf05a)
            alu_control <= `OPC_SHL;
            immediate <= 'h0003;
            en_imm <= 1;
        #10 `assert(out,'h7d28)
            alu_control <= `OPC_SHR;
        #10 `assert(out,'h01f4)
            alu_control <= `OPC_ROL;
            immediate <= 'h0006;
        #10 $display("ROL not implemented yet!");
            alu_control <= `OPC_ADC;
            flags_in[`FLAG_BIT_CARRY] <= 1;
            rD_data <= 'h0001;
        #10 `assert(out,'h0008)
            alu_control <= `OPC_PUSH;
            rD_data <= 'h0567;
            rS_data <= 'h0100;
            en_imm <= 0;
        #10 `assert(out, 'h00fe)
            `assert(SP_out, 'h00fe)
            `assert(mem_data, 'h0567)
        #10 en <= 0;
        #20 $finish;
    end
endmodule // alu_tb
/*AUTOUNDEF*/
