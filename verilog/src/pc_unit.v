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
`ifdef FORMAL
input [15:0] pc_in;
input [1:0] pc_op;
`else
input [15:0] pc_in;
input [1:0] pc_op;
`endif
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
    initial begin
        assume(pc_op == `PC_RESET);
        assume(pc_in == 0);
        assume(pc == 0);
        assume(clk == 0);
    end
    always @(posedge clk) begin
        if($initstate == 1) begin
            assume($past(pc_op) == `PC_NOP);
            assume($past(pc) == 0);
        end
        assume(en == 1);
        if($past(pc_op) == `PC_RESET)
            assert(pc == 0);
        if($past(pc_op) == `PC_NOP)
            assert($past(pc) == pc);
        if($past(pc_op) == `PC_SET)
            assert(pc == $past(pc_in));
        if($past(pc_op) == `PC_INC)
            assert(pc == ($past(pc) + 16'h2));
    end

`endif

endmodule
