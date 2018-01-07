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
	  REG_WR:
	    control_o[`BIT_REG_WR] <= 1;
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
	PC_DELAY:
	  pc_op <= `PC_SET;
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
	    next_state <= FETCH;
	PC_DELAY:
	  next_state <= BRANCH_DELAY;
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

module control_old(
 input wire 			  clk,
 input wire 			  en,
 input wire 			  rst,
 input wire 			  en_mem,
 input wire 			  mem_wait,
 input wire 			  should_branch,
 input wire 			  imm,
 output wire [`CONTROL_BIT_MAX:0] control_o,
 output reg [1:0] 		  pc_op
);




reg [`CONTROL_BIT_MAX:0] s_control = `STATE_FETCH;

  assign control_o = s_control;
  always @(posedge clk) begin
    if(rst == 1'b 1) begin
       s_control <= 0;
       pc_op <= 0;
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
	   if(imm)
	     pc_op <= `PC_INC;
	   else
	     pc_op <= `PC_NOP;
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
	     pc_op <= `PC_SET;
	  end
	  else begin
	     s_control <= `STATE_FETCH;
	     pc_op <= `PC_INC;
          end
        end
        `STATE_PC_DELAY : begin
	   s_control <= `STATE_BRANCH_DELAY;
	   pc_op <= `PC_INC;
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

module check(/*AUTOARG*/
   // Outputs
   control_o, pc_op,
   // Inputs
   clk, en, rst, en_mem, mem_wait, should_branch, imm
   );
/*AUTOINOUTMODULE("control_old")*/
// Beginning of automatic in/out/inouts (from specific module)
output [`CONTROL_BIT_MAX:0] control_o;
output [1:0]		pc_op;
input			clk;
input			en;
input			rst;
input			en_mem;
input			mem_wait;
input			should_branch;
input			imm;
// End of automatics
  wire [`CONTROL_BIT_MAX:0] control_uut;
   wire [1:0] 		    pc_op_uut;
  control uut(
	      // Outputs
	      .control_o		(control_uut[`CONTROL_BIT_MAX:0]),
	      .pc_op			(pc_op_uut[1:0]),
	      // Inputs
	      .clk			(clk),
	      .en			(en),
	      .rst			(rst),
	      .en_mem			(en_mem),
	      .mem_wait			(mem_wait),
	      .should_branch		(should_branch),
	      .imm			(imm));
   control_old gold(
		    // Outputs
		    .control_o		(control_o[`CONTROL_BIT_MAX:0]),
		    .pc_op		(pc_op[1:0]),
		    // Inputs
		    .clk		(clk),
		    .en			(en),
		    .rst		(rst),
		    .en_mem		(en_mem),
		    .mem_wait		(mem_wait),
		    .should_branch	(should_branch),
		    .imm		(imm));
`ifdef FORMAL
   assert property(control_uut == control_o); 
   `else
    wire en_pc = control_uut[`BIT_FETCH] | control_uut[`BIT_REG_READ] | control_uut[`BIT_PC_DELAY];
   wire 		    equiv = control_uut == control_o && en_pc ? pc_op == pc_op_uut : 1;
   `endif // !`ifdef FORMAL
   
endmodule
      
      
// Local Variables:
// verilog-auto-sense-defines-constant: t
// End:
