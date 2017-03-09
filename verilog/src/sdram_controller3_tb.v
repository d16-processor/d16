//deps: sdram_controller3.v, IS42S16160.v
`timescale 1ns/1ps
module sdram_controller3_tb;
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [12:0]          DRAM_ADDR;              // From controller of sdram_controller3.v
   wire [1:0]           DRAM_BA;                // From controller of sdram_controller3.v
   wire                 DRAM_CAS_N;             // From controller of sdram_controller3.v
   wire                 DRAM_CKE;               // From controller of sdram_controller3.v
   wire                 DRAM_CLK;               // From controller of sdram_controller3.v
   wire                 DRAM_CS_N;              // From controller of sdram_controller3.v
   wire [15:0]          DRAM_DQ;                // To/From controller of sdram_controller3.v
   wire [1:0]           DRAM_DQM;               // From controller of sdram_controller3.v
   wire                 DRAM_RAS_N;             // From controller of sdram_controller3.v
   wire                 DRAM_WE_N;              // From controller of sdram_controller3.v

   wire [31:0]          data_out;               // From controller of sdram_controller3.v
   wire                 data_valid;             // From controller of sdram_controller3.v
   wire                 write_complete;         // From controller of sdram_controller3.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   
   reg                  CLOCK_100;              // To controller of sdram_controller3.v
   reg                  CLOCK_100_del_3ns;      // To controller of sdram_controller3.v
   reg                  CLOCK_50;               // To controller of sdram_controller3.v
   
   reg [23:0]           address;                // To controller of sdram_controller3.v
   reg [31:0]           data_in;                // To controller of sdram_controller3.v
   reg                  req_read;               // To controller of sdram_controller3.v
   reg                  req_write;              // To controller of sdram_controller3.v
   reg                  rst;                    // To controller of sdram_controller3.v
   // End of automatics

   sdram_controller3 controller(/*AUTOINST*/
                                // Outputs
                                .data_out       (data_out[31:0]),
                                .data_valid     (data_valid),
                                .write_complete (write_complete),
                                .DRAM_ADDR      (DRAM_ADDR[12:0]),
                                .DRAM_BA        (DRAM_BA[1:0]),
                                .DRAM_CAS_N     (DRAM_CAS_N),
                                .DRAM_CKE       (DRAM_CKE),
                                .DRAM_CLK       (DRAM_CLK),
                                .DRAM_CS_N      (DRAM_CS_N),
                                .DRAM_DQM       (DRAM_DQM[1:0]),
                                .DRAM_RAS_N     (DRAM_RAS_N),
                                .DRAM_WE_N      (DRAM_WE_N),
                                // Inouts
                                .DRAM_DQ        (DRAM_DQ[15:0]),
                                // Inputs
                                .CLOCK_50       (CLOCK_50),
                                .CLOCK_100      (CLOCK_100),
                                .CLOCK_100_del_3ns(CLOCK_100_del_3ns),
                                .rst            (rst),
                                .address        (address[23:0]),
                                .req_read       (req_read),
                                .req_write      (req_write),
                                .data_in        (data_in[31:0]));

   IS42S16160 RAM (
                   // Inouts
                   .Dq                  (DRAM_DQ[15:0]),
                   // Inputs
                   .Addr                (DRAM_ADDR[12:0]),
                   .Ba                  (DRAM_BA[1:0]),
                   .Clk                 (DRAM_CLK),
                   .Cke                 (DRAM_CKE),
                   .Cs_n                (DRAM_CS_N),
                   .Ras_n               (DRAM_RAS_N),
                   .Cas_n               (DRAM_CAS_N),
                   .We_n                (DRAM_WE_N),
                   .Dqm                 (DRAM_DQM[1:0]));

   

   
   initial begin
      rst = 1;
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
      #20 rst = 0;
      #1000 address = 16;
      data_in = 32'h12345678;
      req_write = 1;
      #20 req_write = 0;
      @(posedge write_complete) #60
        address = 16;
      req_read = 1;
      #20
        req_read = 0;
      
   end // initial begin
   
   
   
endmodule
