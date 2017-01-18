// File ../../vhdl/src/control.vhd translated with vhd2vl v2.5 `VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 2001

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002, 2005, 2008-2010, 2015 Larry Doolittle - LBNL
//     http://doolittle.icarus.com/~larry/vhd2vl/
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

// no timescale needed
`include "cpu_constants.vh"
`timescale 1ns/1ps
module control(
input wire clk,
input wire en,
input wire rst,
input wire en_mem,
input wire mem_wait,
input wire should_branch,
output wire [`CONTROL_BIT_MAX:0] control_o
);




reg [`CONTROL_BIT_MAX:0] s_control = `STATE_FETCH;

  assign control_o = s_control;
  always @(posedge clk) begin
    if(rst == 1'b 1) begin
      s_control <= `STATE_FETCH;
    end
    else begin
      if(en == 1'b 1) begin
        //basically a FSM
        case(s_control)
        `STATE_FETCH : begin
          if(mem_wait == 1'b 1) begin
            s_control <= `STATE_FETCH;
          end
          else begin
            s_control <= `STATE_DECODE;
          end
        end
        `STATE_DECODE : begin
          s_control <= `STATE_REG_READ;
        end
        `STATE_REG_READ : begin
          s_control <= `STATE_ALU;
        end
        `STATE_ALU : begin
          if(en_mem == 1'b 1) begin
            s_control <= `STATE_MEM;
          end
          else begin
            s_control <= `STATE_REG_WR;
          end
        end
        `STATE_MEM : begin
          if(mem_wait == 1'b 1) begin
            s_control <= `STATE_MEM;
          end
          else begin
            s_control <= `STATE_REG_WR;
          end
        end
        `STATE_REG_WR : begin
          if(should_branch == 1'b 1) begin
            s_control <= `STATE_PC_DELAY;
          end
          else begin
            s_control <= `STATE_FETCH;
          end
        end
        `STATE_PC_DELAY : begin
          s_control <= `STATE_BRANCH_DELAY;
        end
        `STATE_BRANCH_DELAY : begin
          s_control <= `STATE_FETCH;
        end
        default : begin
          s_control <= `STATE_FETCH;
        end
        endcase
      end
    end
  end
`ifdef FORMAL
    reg [`CONTROL_BIT_MAX:0] control_prev = 0;
    reg en_mem_prev = 0;
    reg mem_wait_prev = 0;
    reg should_branch_prev = 0;
    always @(posedge clk) begin
        if(rst == 1) begin
            control_prev <= 0;
        end
        else begin
            if(en == 1) begin
            control_prev <= s_control;
            en_mem_prev <= en_mem;
            mem_wait_prev <= mem_wait;
            should_branch_prev <= should_branch;
        end
        end
    end
    initial begin
        assume(s_control == 0);
        assume(control_prev == 0);
    end
    always @(posedge clk) begin
        if(en == 1 && rst == 0) begin
        if(control_prev == `STATE_FETCH && mem_wait_prev == 1)
            assert(s_control == `STATE_FETCH);
        if(control_prev == `STATE_FETCH && mem_wait_prev == 0)
            assert(s_control == `STATE_DECODE);
        if(control_prev == `STATE_DECODE)
            assert(s_control == `STATE_REG_READ);
        if(control_prev == `STATE_REG_READ)
            assert(s_control == `STATE_ALU);
        if(control_prev == `STATE_ALU && en_mem_prev == 1)
            assert(s_control == `STATE_MEM);
        if(control_prev == `STATE_ALU && en_mem_prev == 0)
            assert(s_control == `STATE_REG_WR);
        if(control_prev == `STATE_MEM)
            if(mem_wait_prev == 1)
                assert(s_control == `STATE_MEM);
            else
                assert(s_control == `STATE_REG_WR);
        end
        if(control_prev == `STATE_REG_WR)
            if(should_branch_prev == 0)
                assert(s_control == `STATE_FETCH);
            else
                assert(s_control == `STATE_PC_DELAY);
        if(control_prev == `STATE_PC_DELAY)
            assert(s_control == `STATE_BRANCH_DELAY);
    end
    assert property(s_control != 0);
    //always 1 hot
    assert property((s_control[7] + s_control[6] + s_control[5] + s_control[4] +
                     s_control[3] + s_control[2] + s_control[1] + s_control[0]) == 1);
    assume property(rst == 0);
    assume property(en == 1);
    
`endif


endmodule
