`timescale 1ns/1ps
module sdram_controller3
  (
   input 	     CLOCK_50,
   input 	     CLOCK_100,
   input 	     CLOCK_100_del_3ns,
			       
   input [23:0]      address,
   input 	     req_read,
   input 	     req_write,
   input [31:0]      data_in,
   output reg [31:0] data_out,
   output reg 	     data_valid= 0,
   output reg 	     write_complete= 0,
			       
   output reg [12:0] DRAM_ADDR,
   output reg [1:0]  DRAM_BA,
   output reg 	     DRAM_CAS_N,
   output 	     DRAM_CKE,
   output 	     DRAM_CLK,
   output reg 	     DRAM_CS_N,
   inout [15:0]      DRAM_DQ,
   output reg [1:0]  DRAM_DQM,
   output reg 	     DRAM_RAS_N,
   output reg 	     DRAM_WE_N);

   localparam [3:0] cmd_nop 	   = 4'b0111;
   localparam [3:0] cmd_read 	   = 4'b0101;
   localparam [3:0] cmd_write 	   = 4'b0100;
   localparam [3:0] cmd_act 	   = 4'b0011;
   localparam [3:0] cmd_pre 	   = 4'b0010;
   localparam [3:0] cmd_ref 	   = 4'b0001;
   localparam [3:0] cmd_mrs 	   = 4'b0000;

   localparam s_init_nop 	   = 9'b000000000 | cmd_nop;
   localparam s_init_pre 	   = 9'b000000000 | cmd_pre;
   localparam s_init_ref 	   = 9'b000000000 | cmd_ref;
   localparam s_init_mrs 	   = 9'b000000000 | cmd_mrs;
   localparam s_init 		   = 5'b00000;
   
   localparam s_idle 		   = 9'b00001_0000 | cmd_nop;

   localparam s_rf0 		   = 9'b00010_0000 | cmd_ref;
   localparam s_rf1 		   = 9'b00011_0000 | cmd_nop;
   localparam s_rf2 		   = 9'b00100_0000 | cmd_nop;
   localparam s_rf3 		   = 9'b00101_0000 | cmd_nop;
   localparam s_rf4 		   = 9'b00110_0000 | cmd_nop;
   localparam s_rf5 		   = 9'b00111_0000 | cmd_nop;

   localparam s_act0 		   = 9'b01000_0000 | cmd_act;
   localparam s_act1 		   = 9'b01001_0000 | cmd_nop;
   localparam s_act2 		   = 9'b01010_0000 | cmd_nop;

   localparam s_wr0 		   = 9'b01011_0000 | cmd_write;
   localparam s_wr1 		   = 9'b01100_0000 | cmd_nop;
   localparam s_wr2 		   = 9'b01101_0000 | cmd_nop;
   localparam s_wr3 		   = 9'b01110_0000 | cmd_nop;
   localparam s_wr4 		   = 9'b01111_0000 | cmd_pre;
   localparam s_wr5 		   = 9'b10000_0000 | cmd_nop;
   localparam s_wr6 		   = 9'b10001_0000 | cmd_nop;

   localparam s_rd0 		   = 9'b10010_0000 | cmd_read;
   localparam s_rd1 		   = 9'b10011_0000 | cmd_nop;
   localparam s_rd2 		   = 9'b10100_0000 | cmd_nop;
   localparam s_rd3 		   = 9'b10101_0000 | cmd_nop;
   localparam s_rd4 		   = 9'b10110_0000 | cmd_pre;
   localparam s_rd5 		   = 9'b10111_0000 | cmd_nop;
   localparam s_rd6 		   = 9'b11000_0000 | cmd_nop;
   

   reg [8:0] 	     state 	   = s_init_nop;
`ifdef SIMULATION
   reg [14:0] 	     init_counter  = 15'b00000000010000;
`else
   reg [14:0] 	     init_counter  = 15'b00000000000000;
`endif
   reg [9:0] 	     rf_counter    = 0;
   reg 		     rf_pending    = 0;
   reg 		     s_data_valid = 0;
   reg 		     s_write_complete;
   
   
   assign DRAM_CLK 		   = CLOCK_100_del_3ns;
   assign DRAM_CKE 		   = 1;

   wire [12:0]	     addr_row 	   = address[23:11];
   wire [1:0]	     addr_bank 	   = address[10:9];
   wire [9:0]	     addr_col 	   = {address [8:1],2'b0};
   

   reg 		     wr_pending    = 0;
   reg 		     rd_pending    = 0;
   reg [15:0] 	     dram_dq 	   = 0;
   reg 		     dram_oe 	   = 0;
   
   assign DRAM_DQ 		   = dram_oe ? dram_dq : 'bZ;
   reg [15:0] 	     captured;
   always @(posedge CLOCK_100_del_3ns)
     captured <= DRAM_DQ;
   always @(posedge CLOCK_50)begin
      data_valid <= s_data_valid;
      write_complete <= s_write_complete;
   end
   

always @(posedge CLOCK_100)begin
   init_counter <= init_counter - 1;
   if(req_read)
     rd_pending <= 1;
   if(req_write)
     wr_pending <= 1;
   DRAM_WE_N 	<= state[0];
   DRAM_CAS_N 	<= state[1];
   DRAM_RAS_N 	<= state[2];
   DRAM_CS_N 	<= state[3];
   if(rf_counter == 770) begin
      rf_counter <= 0;
      rf_pending <= 1;
   end
   else if(state[8:4] != s_init_nop[8:4])
     rf_counter <= rf_counter + 1;
   
   
   
   case(state[8:4])
     s_init: begin
	state 		 <= s_init_nop;
	
	if(init_counter == 'b000000010000010) begin
	   state 	 <= s_init_pre;
	   DRAM_ADDR[10] <= 1'b1;
	end
	if(init_counter[14:7] == 0 && init_counter[3:0] == 4'b1111)
	  state      <= s_init_ref;
	if(init_counter == 3) begin
	   state     <= s_init_mrs;
	   //            res  wr_b opmd cas=3  seq  brst=2
	   DRAM_ADDR <= 13'b000_0_00_011_0_001;
	   DRAM_BA   <= 2'b0;
	end
	if(init_counter == 1)
	  state <= s_idle;
     end // case: s_init
     s_idle[8:4]:begin
	if(rd_pending == 1 || wr_pending == 1) begin
	   state     <= s_act0;
	   DRAM_ADDR <= addr_row;
	end
	if(rf_pending) begin
	   state      <= s_rf0;
	   rf_pending <= 0;
	end
	s_data_valid <= 0;
	
     end
     s_act0[8:4]:
       state <= s_act1;
     s_act1[8:4]:
       state <= s_act2;
     s_act2[8:4]: begin
	if(wr_pending)begin
	   state     <= s_wr0;
	   DRAM_ADDR <= addr_col;
	   DRAM_BA   <= addr_bank;
	   DRAM_DQM  <= 2'b0;
	end
	if(rd_pending)begin
	   state     <= s_rd0;
	   DRAM_ADDR <= addr_col;
	   DRAM_BA   <= addr_bank;
	   DRAM_DQM  <= 2'b0;
	end
     end // case: s_act2
     s_wr0[8:4]:begin
	wr_pending <= 0;
	state 	   <= s_wr1;
	DRAM_ADDR  <= addr_col;
	dram_dq    <= data_in[15:0];
	dram_oe    <= 1;
	DRAM_BA    <= addr_bank;
	DRAM_DQM   <= 0;
	
	end
     s_wr1[8:4]:begin
	state 	<= s_wr2;
	dram_dq <= data_in[31:16];
     end
     s_wr2[8:4]:begin
	state 	       <= s_wr3;
	dram_oe        <= 0;
	s_write_complete <= 1;
     end
     s_wr3[8:4]:
       state <= s_wr4;
     s_wr4[8:4]:begin
	state <= s_wr5;
     end
     s_wr5[8:4]:
       state <= s_wr6;
     s_wr6[8:4]:begin
	state <= s_idle;
	s_write_complete <= 0;
     end

     s_rd0[8:4]:begin
	rd_pending <= 0;
	state <= s_rd1;
	DRAM_DQM <= 0;
     end
     s_rd1[8:4]:
       state <= s_rd2;
     s_rd2[8:4]:
       state <= s_rd3;
     s_rd3[8:4]: begin
	state <= s_rd4;

     end
     s_rd4[8:4]:begin
	state <= s_rd5;
	data_out[15:0] <= captured;	
     end
     s_rd5[8:4]:begin
	state 	       <= s_rd6;
        data_out[31:16] <= captured;
	s_data_valid     <= 1;
     end
     s_rd6[8:4]:begin

	   state       <= s_idle;
     end
     s_rf0[8:4]:
       state <= s_rf1;
     s_rf1[8:4]:
       state <= s_rf2;
     s_rf2[8:4]:
       state <= s_rf3;
     s_rf3[8:4]:
       state <= s_rf4;
     s_rf4[8:4]:
       state <= s_rf5;
     s_rf5[8:4]:
       state <= s_idle;
     
     
     
     
     

   endcase

end	     
   endmodule
