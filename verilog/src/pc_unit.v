// File ../../vhdl/src/pc_unit.vhd translated with vhd2vl v2.5 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 1995

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
module pc_unit(
clk,
en,
pc_in,
pc_op,
pc_out
);

input clk;
input en;
input [15:0] pc_in;
input [1:0] pc_op;
output [15:0] pc_out;

wire clk;
wire en;
wire [15:0] pc_in;
wire [1:0] pc_op;
wire [15:0] pc_out;


reg [15:0] pc = 16'h 0000;

  assign pc_out = pc;
  always @(posedge clk) begin
    if(en == 1'b 1) begin
      case(pc_op)
      `PC_NOP : begin
        pc <= pc;
      end
      `PC_INC : begin
        pc <= (((pc)) + 2);
      end
      `PC_SET : begin
        pc <= pc_in;
      end
      `PC_RESET : begin
        pc <= 16'h 0000;
      end
      default : begin
      end
      endcase
    end
  end
  //Formally verified
`ifdef FORMAL
    reg [1:0] op_prev = 0;
    reg [15:0] pc_prev = 0;
    reg [15:0] set_prev = 0;
    always @(posedge clk) begin
        if(en == 1) begin
            pc_prev <= pc;
            op_prev <= pc_op;
            set_prev <= pc_in;
        end
    end
    initial begin 
        assume(pc_op == `PC_NOP);
        assume(op_prev == pc_op);
        assume(pc_in == 0);
        assume(pc == 0);
        assume(pc_prev == pc);
        assume(set_prev == 0);
        assume(clk == 0);
        //assert(pc_op == op_prev);
    end
    always @(*) begin
        if(en == 1) begin
        if(op_prev == `PC_RESET)
            assert(pc == 0);
        if(op_prev == `PC_NOP)
            assert(pc == pc_prev);
        if(op_prev == `PC_INC)
            assert(pc == (pc_prev + 16'h2));
        if(op_prev == `PC_SET)
            assert(pc == set_prev);
    end
    end
`endif

endmodule
