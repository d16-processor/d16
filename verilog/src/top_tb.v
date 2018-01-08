//deps: core.v, sdram_controller3.v, IS42S16160.v
`timescale 1ns/1ps
module top_tb;
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
   wire [16-1:0] Dq;                     // To/From memory of IS42S16160.v
   wire [7:0]           LED;                    // From core of core.v
   wire [31:0]          data_out;               // From controller of sdram_controller3.v
   wire                 data_valid;             // From controller of sdram_controller3.v
   wire [23:0]          dram_addr;              // From core of core.v
   wire [31:0]          dram_data_out;          // From core of core.v
   wire                 dram_req_read;          // From core of core.v
   wire                 dram_req_write;         // From core of core.v
   wire                 snd_out;                // From core of core.v
   wire [3:0]           snd_signals;            // From core of core.v
   wire                 tx;                     // From core of core.v
   wire                 write_complete;         // From controller of sdram_controller3.v
   wire [31:0]          dram_data_in;           // To core of core.v
   wire                 dram_data_valid;        // To core of core.v
   wire                 dram_write_complete;    // To core of core.v
   wire                 req_read;               // To controller of sdram_controller3.v
   wire                 req_write;              // To controller of sdram_controller3.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [13-1:0]  Addr;                   // To memory of IS42S16160.v
   reg [1:0]            Ba;                     // To memory of IS42S16160.v
   reg                  CLOCK_100;              // To controller of sdram_controller3.v
   reg                  CLOCK_100_del_3ns;      // To controller of sdram_controller3.v
   reg                  CLOCK_50;               // To controller of sdram_controller3.v
   reg                  Cas_n;                  // To memory of IS42S16160.v
   reg                  Cke;                    // To memory of IS42S16160.v
   reg                  Clk;                    // To memory of IS42S16160.v
   reg                  Cs_n;                   // To memory of IS42S16160.v
   reg [1:0]            Dqm;                    // To memory of IS42S16160.v
   reg                  Ras_n;                  // To memory of IS42S16160.v
   reg                  We_n;                   // To memory of IS42S16160.v
   reg [23:0]           address;                // To controller of sdram_controller3.v
   reg                  clk;                    // To core of core.v
   reg [31:0]           data_in;                // To controller of sdram_controller3.v

   reg                  rst;                    // To controller of sdram_controller3.v

   reg                  rx;                     // To core of core.v
   reg [3:0]            switches;               // To core of core.v

   wire                 rst_n;
   assign rst_n = ~rst;
   always @* begin
      clk <= CLOCK_50;
   end
   // End of automatics
   core core(
             // Outputs
             .LED                       (LED[7:0]),
             .tx                        (tx),
             .snd_out                   (snd_out),
             .snd_signals               (snd_signals[3:0]),
             .dram_data_out             (dram_data_in[31:0]),
             .dram_addr                 (dram_addr[23:0]),
             .dram_req_read             (dram_req_read),
             .dram_req_write            (dram_req_write),
             // Inputs
             .clk                       (clk),
             .rst_n                     (rst_n),
             .rx                        (rx),
             .switches                  (switches[3:0]),
             .dram_data_in              (dram_data_out[31:0]),
             .dram_data_valid           (dram_data_valid),
             .dram_write_complete       (dram_write_complete));
   sdram_controller3 controller(
                                // Outputs
                                .data_out       (dram_data_out[31:0]),
                                .data_valid     (dram_data_valid),
                                .write_complete (dram_write_complete),
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
                                .address        (dram_addr[23:0]),
                                .req_read       (dram_req_read),
                                .req_write      (dram_req_write),
                                .data_in        (dram_data_in[31:0]));
   IS42S16160 memory(
                     // Inouts
                     .Dq                (DRAM_DQ[16-1:0]),
                     // Inputs
                     .Addr              (DRAM_ADDR[13-1:0]),
                     .Ba                (DRAM_BA[1:0]),
                     .Clk               (DRAM_CLK),
                     .Cke               (DRAM_CKE),
                     .Cs_n              (DRAM_CS_N),
                     .Ras_n             (DRAM_RAS_N),
                     .Cas_n             (DRAM_CAS_N),
                     .We_n              (DRAM_WE_N),
                     .Dqm               (DRAM_DQM[1:0]));
   initial begin
      CLOCK_50 = 0;
      CLOCK_100 = 0;
      rst = 1;
      $dumpfile("dump.vcd");
      $dumpvars;

      
      #5000 $finish;
   end // initial begin

   initial begin
      #60 rst = 0;
   end
   
   always #10 CLOCK_50 <= ~CLOCK_50;
   always #5 begin
      CLOCK_100 <= ~CLOCK_100;
   end
   always @(CLOCK_100) begin
      #3
        CLOCK_100_del_3ns <= CLOCK_100;
   end
endmodule
