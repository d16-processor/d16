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
 input wire 			  clk,
 input wire 			  en,
 input wire 			  rst,
 input wire 			  en_mem,
 input wire 			  mem_wait,
 input wire 			  should_branch,
 input wire 			  imm,
 output reg [`CONTROL_BIT_MAX:0] control_o,
 output reg [1:0] 		  pc_op
);
   localparam 			// auto enum state_info
     RST = 0,
     FETCH = 4'h1,
     DECODE = 4'h2,
     REG_READ = 4'h3,
     ALU = 4'h4,
     MEM = 4'h5,
     REG_WR = 4'h6,
     PC_DELAY = 4'h7,
     BRANCH_DELAY = 4'h8;
   reg [3:0] 			// auto enum state_info
				state, next_state;
   always @(posedge clk) begin
      if(rst)
	state <= 0;
      else if(en)
	state <= next_state;
   end // always @ (posedge clk)

   always @(/*AUTOSENSE*/state) begin
      control_o <= 0;
	case(state)
	  FETCH:
	    control_o[`BIT_FETCH] <= 1;
	  DECODE:
	    control_o[`BIT_DECODE] <= 1;
	  REG_READ:
	    control_o[`BIT_REG_READ] <= 1;
	  ALU:
	    control_o[`BIT_ALU] <= 1;
	  REG_WR:begin
	     if(!should_branch)
	       control_o[`BIT_FETCH] <= 1;
	     control_o[`BIT_REG_WR] <= 1;
	     end
	  MEM:
	    control_o[`BIT_MEM] <= 1;
	  PC_DELAY:
	    control_o[`BIT_PC_DELAY] <= 1;
	  BRANCH_DELAY:
	    control_o[`BIT_BRANCH_DELAY] <= 1;
	  default:
	    control_o <= 0;
	endcase // case (state)
   end
   always @(* ) begin
      pc_op <= `PC_NOP;
      case(state)
	RST:
	  pc_op <= `PC_RESET;
        REG_READ:
	  if(imm)
	    pc_op <= `PC_INC;
	FETCH:
	  pc_op <= `PC_INC;
	REG_WR:
	  if(!should_branch)
	    pc_op <= `PC_INC;
	  else
	    pc_op <= `PC_SET;
	// PC_DELAY:
	//   pc_op <= `PC_SET;
      endcase // case (state)
      
   end
   

   always @(/*AS*/en_mem or mem_wait or should_branch or state) begin
      case(state)
	FETCH:
	  next_state <= DECODE;
	DECODE:
	  next_state <= REG_READ;
	REG_READ:
	  next_state <= ALU;
	ALU:
	   if(en_mem)
	     next_state <= MEM;
	   else
	     next_state <= REG_WR;
	MEM:
	  if(mem_wait)
	    next_state <= MEM;
	  else
	    next_state <= REG_WR;
	REG_WR:
	  if(should_branch)
	    next_state <= PC_DELAY;
	  else
	    next_state <= DECODE;
	PC_DELAY:
	  next_state <= FETCH;
	default:
	  next_state <= FETCH;
      endcase // case (state)
   end
   
   


   

   /*AUTOASCIIENUM("state", "state_ascii")*/
   // Beginning of automatic ASCII enum decoding
   reg [95:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	RST:          state_ascii = "rst         ";
	FETCH:        state_ascii = "fetch       ";
	DECODE:       state_ascii = "decode      ";
	REG_READ:     state_ascii = "reg_read    ";
	ALU:          state_ascii = "alu         ";
	MEM:          state_ascii = "mem         ";
	REG_WR:       state_ascii = "reg_wr      ";
	PC_DELAY:     state_ascii = "pc_delay    ";
	BRANCH_DELAY: state_ascii = "branch_delay";
	default:      state_ascii = "%Error      ";
      endcase
   end
   // End of automatics
endmodule // control

      
// Local Variables:
// verilog-auto-sense-defines-constant: t
// End:
