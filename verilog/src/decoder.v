// File ../../vhdl/src/decoder.vhd translated with vhd2vl v2.5 VHDL to Verilog RTL translator
// vhd2vl settings:
//    * Verilog Module Declaration Style: 2001

// vhd2vl is Free (libre) Software:
//     Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//         http://www.ocean-logic.com
//     Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//     Modifications (C) 2010 Shankar Giri
//     Modifications Copyright (C) 2002, 2005, 2008-2010, 2015 Larry Doolittle - LBNL
//         http://doolittle.icarus.com/~larry/vhd2vl/
//
//     vhd2vl comes with ABSOLUTELY NO WARRANTY.    Always check the resulting
//     Verilog for correctness, ideally with a formal verification tool.
//
//     You are welcome to redistribute vhd2vl under certain conditions.
//     See the license (GPLv2) file included with the source for details.

// The result of translation follows.    Its copyright status should be
// considered unchanged from the original VHDL.

// no timescale needed
`include "cpu_constants.vh"
`timescale 1ns/1ps
module decoder(
input wire clk,
input wire en,
input wire [15:0] instruction,
output wire [7:0] alu_control,
output wire [2:0] rD_sel,
output wire [2:0] rS_sel,
output wire [15:0] immediate,
output wire en_immediate,
output wire next_word,
output reg en_mem,
output reg mem_displacement,
output reg mem_byte,
output reg lr_is_input,
output reg [3:0] condition
);




reg [7:0] s_alu_control;
reg [2:0] s_rD_sel;
reg [2:0] s_rS_sel;
reg [15:0] s_immediate;
reg s_en_imm;
reg s_next_word;
wire [7:0] opcode;
assign opcode = instruction[15:8];
assign alu_control = s_alu_control;
assign rD_sel = s_rD_sel;
assign rS_sel = s_rS_sel;
assign immediate = s_immediate;
assign en_immediate = s_en_imm;
assign next_word = s_next_word;
always @(posedge clk) begin : P1

    if(en == 1'b 1) begin
        if((((opcode)) <= ((`OPC_MOVB_R7)) && ((opcode)) >= ((`OPC_MOVB_R0)))) begin
            s_en_imm <= 1'b 1;
            s_alu_control <= `OPC_MOV;
            s_next_word <= 1'b 0;
            s_immediate <= {8'h 00,instruction[7:0]};
            case(opcode)
            `OPC_MOVB_R0 : begin
                s_rD_sel <= 3'b 000;
            end
            `OPC_MOVB_R1 : begin
                s_rD_sel <= 3'b 001;
            end
            `OPC_MOVB_R2 : begin
                s_rD_sel <= 3'b 010;
            end
            `OPC_MOVB_R3 : begin
                s_rD_sel <= 3'b 011;
            end
            `OPC_MOVB_R4 : begin
                s_rD_sel <= 3'b 100;
            end
            `OPC_MOVB_R5 : begin
                s_rD_sel <= 3'b 101;
            end
            `OPC_MOVB_R6 : begin
                s_rD_sel <= 3'b 110;
            end
            `OPC_MOVB_R7 : begin
                s_rD_sel <= 3'b 111;
            end
            default : begin
            end
            endcase
        end
        else begin
            s_alu_control <= {1'b 0,opcode[6:0]};
            s_en_imm <= instruction[15];
            s_next_word <= instruction[15];
            s_rD_sel <= instruction[2:0];
            s_immediate <= 16'h 0000;
            if(opcode == `OPC_PUSH || opcode == `OPC_POP ||
               opcode == `OPC_PUSHI || opcode == `OPC_PUSHLR) begin
                s_rS_sel <= ~instruction[5:3];
                //Stack pointer
            end
            else begin
                s_rS_sel <= instruction[5:3];
            end
        end
        if(opcode == `OPC_ST || opcode == `OPC_LD || opcode == `OPC_LDI ||
           opcode == `OPC_STI || opcode == `OPC_PUSH || opcode == `OPC_PUSHI ||
           opcode == `OPC_POP || opcode == `OPC_PUSHLR) begin
            en_mem <= 1'b 1;
            if(opcode == `OPC_ST || opcode == `OPC_LD ||
               opcode == `OPC_LDI || opcode == `OPC_STI) 
                mem_byte <= instruction[7];
            else
                mem_byte <= 0;
        end
        else begin
            mem_byte <= 1'b 0;
            en_mem <= 1'b 0;
        end
        if(opcode == `OPC_LDI || opcode == `OPC_STI) begin
            mem_displacement <= instruction[6];
        end
        else begin
            mem_displacement <= 1'b 0;
        end
        if(opcode == `OPC_SPEC || opcode == `OPC_PUSHLR)
            lr_is_input <= 1;
        else
            lr_is_input <= 0;
        if(opcode == `OPC_JMP || opcode == `OPC_JMPI ||
           opcode == `OPC_SET || opcode == `OPC_CALL ||
           opcode == `OPC_CALLI ) begin
            condition <= instruction[6:3];
        end
        else begin
            condition <= 4'b 0000;
        end
    end
end
`ifdef FORMAL
assume property(en == 1);
reg [15:0] instr_prev = 0;
reg [7:0] opcode_prev = 0;
initial begin
    assume(s_alu_control == 0);
    assume(s_en_imm == 0);
    assume(s_immediate == 0);
    assume(opcode_prev == 0);
    assume(s_next_word == 0);
end
always @(posedge clk) begin
        instr_prev <= instruction;
        opcode_prev <= opcode;
    if(opcode_prev == `OPC_ADD) begin
        assert(s_en_imm == 0);
        assert(s_alu_control == `OPC_ADD);
    end
    if(opcode_prev[7] == 1) begin
        assert(s_en_imm == 1);
        assert(s_next_word == 1);
    end
    else if(opcode_prev >= `OPC_MOVB_R0 && opcode_prev <= `OPC_MOVB_R7) begin
        assert(s_en_imm == 1);
        assert(s_next_word == 0);
    end
    else if(opcode_prev[7] == 0) begin
        assert(s_en_imm == 0);
        assert(s_next_word == 0);
    end
    
end
`endif
`ifdef FORMAL
    initial begin
        assume(instruction == 0);
        assume(s_rD_sel == 0);
        assume(s_rS_sel == 0);
    end
    always @(posedge clk) begin
        if($initstate) begin
            assume($past(instruction) == 0);
            assume($past(opcode) == 0);
        end
        else begin
        if($past(opcode) & 8'h80)
            assert(s_next_word == 1);
        else
            assert(s_next_word == 0);
        if($past(opcode) >= `OPC_MOVB_R0 && opcode_prev <= `OPC_MOVB_R7) begin
            assert(s_next_word == 0);
            assert(s_en_imm == 1);
            assert(s_rD_sel == ($past(opcode) - `OPC_MOVB_R0 & 3'b111));
            assert(s_immediate == ($past(instruction) & 8'hff));
        end
        else begin
            assert(s_alu_control == ($past(opcode) & 8'h7f));
            assert(s_rD_sel == ($past(instruction) & 3'b111));
            if($past(opcode) != `OPC_PUSH && $past(opcode) != `OPC_POP &&
                $past(opcode) != `OPC_PUSHI && $past(opcode) != `OPC_PUSHLR)
                assert(s_rS_sel == (($past(instruction) & 6'b111000) >> 3));
            else
                assert(s_rS_sel == 3'b111);
        end
        if($past(opcode) == `OPC_SPEC) begin
            assert (lr_is_input == 1);
        end
        end        
    end
`endif


endmodule
