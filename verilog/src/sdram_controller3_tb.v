//deps: sdram_controller3.v
`timescale 1ns/1ps
module sdram_controller3_tb;
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [12:0]		DRAM_ADDR;		// From controller of sdram_controller3.v
   wire [1:0]		DRAM_BA;		// From controller of sdram_controller3.v
   wire			DRAM_CAS_N;		// From controller of sdram_controller3.v
   wire			DRAM_CKE;		// From controller of sdram_controller3.v
   wire			DRAM_CLK;		// From controller of sdram_controller3.v
   wire			DRAM_CS_N;		// From controller of sdram_controller3.v
   wire [15:0]		DRAM_DQ;		// To/From controller of sdram_controller3.v
   wire [1:0]		DRAM_DQM;		// From controller of sdram_controller3.v
   wire			DRAM_RAS_N;		// From controller of sdram_controller3.v
   wire			DRAM_WE_N;		// From controller of sdram_controller3.v
   wire [31:0]		data_out;		// From controller of sdram_controller3.v
   wire			data_valid;		// From controller of sdram_controller3.v
   wire			write_complete;		// From controller of sdram_controller3.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			CLOCK_100;		// To controller of sdram_controller3.v
   reg			CLOCK_100_del_3ns;	// To controller of sdram_controller3.v
   reg			CLOCK_50;		// To controller of sdram_controller3.v
   reg [23:0]		address;		// To controller of sdram_controller3.v
   reg [31:0]		data_in;		// To controller of sdram_controller3.v
   reg			req_read;		// To controller of sdram_controller3.v
   reg			req_write;		// To controller of sdram_controller3.v
   // End of automatics

   sdram_controller3 controller(/*AUTOINST*/
				// Outputs
				.data_out	(data_out[31:0]),
				.data_valid	(data_valid),
				.write_complete	(write_complete),
				.DRAM_ADDR	(DRAM_ADDR[12:0]),
				.DRAM_BA	(DRAM_BA[1:0]),
				.DRAM_CAS_N	(DRAM_CAS_N),
				.DRAM_CKE	(DRAM_CKE),
				.DRAM_CLK	(DRAM_CLK),
				.DRAM_CS_N	(DRAM_CS_N),
				.DRAM_DQM	(DRAM_DQM[1:0]),
				.DRAM_RAS_N	(DRAM_RAS_N),
				.DRAM_WE_N	(DRAM_WE_N),
				// Inouts
				.DRAM_DQ	(DRAM_DQ[15:0]),
				// Inputs
				.CLOCK_50	(CLOCK_50),
				.CLOCK_100	(CLOCK_100),
				.CLOCK_100_del_3ns(CLOCK_100_del_3ns),
				.address	(address[23:0]),
				.req_read	(req_read),
				.req_write	(req_write),
				.data_in	(data_in[31:0]));
   reg [15:0] 		dram_dq = 0;
   reg 			dram_oe = 0;
   
   assign DRAM_DQ = dram_oe ? dram_dq : 'hZ;
   
   initial begin
      CLOCK_50 = 0;
      CLOCK_100 = 0;
      CLOCK_100_del_3ns = 0;
      address = 0;
      req_read = 0;
      req_write = 0;
      data_in = 0;

      
      $dumpfile("dump.vcd");
      $dumpvars;

      #3000 $finish;
   end
   always #10 CLOCK_50 <= ~CLOCK_50;
   always #5 begin
      CLOCK_100 <= ~CLOCK_100;
   end
   always @(CLOCK_100) begin
      #3
	CLOCK_100_del_3ns <= CLOCK_100;
   end
   initial begin
      #300 address = 16;
      data_in = 32'h12345678;
      req_write = 1;
      #20 req_write = 0;
      @(posedge write_complete) #60
	address = 18;
      req_read = 1;
      #20
	req_read = 0;
      
   end // initial begin
   always @* begin
      if(DRAM_CS_N == 0 && DRAM_RAS_N == 1 && DRAM_CAS_N == 0 && DRAM_WE_N == 1)begin
	 #33
	 dram_oe <= 1;
	 dram_dq <= 16'hf00d;
	 #10
	   dram_dq <= 16'hbeef;
	 #10
	   dram_oe <= 0;
	 
	 
      end
   end
   
   
   
endmodule