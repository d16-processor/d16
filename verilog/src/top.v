module top(input CLOCK_50, input [1:0] KEY, output [7:0] LED, 
    output Tx, input Rx, output [3:0] Snd, input [3:0] SW,
    //DRAM signals
    output [12:0]   DRAM_ADDR,
    output [1:0]    DRAM_BA,
    output          DRAM_CKE,
    output          DRAM_CLK,
         output                           DRAM_CAS_N,
    output          DRAM_CS_N,
    inout  [15:0]   DRAM_DQ,
    output [1:0]    DRAM_DQM,
    output          DRAM_RAS_N,
    output          DRAM_WE_N

);

wire [31:0]             data1;                  // From arbiter of bus_arbiter.v
wire [31:0]             data_out2;              // From arbiter of bus_arbiter.v
wire                    data_valid1;            // From arbiter of bus_arbiter.v
wire                    data_valid2;            // From arbiter of bus_arbiter.v
wire                    write_complete2;        // From arbiter of bus_arbiter.v
wire                    v_sync;                 // From gen of ntsc_gen.v
wire clk;
wire snd;
wire ntsc_clk;
wire [3:0] snd_signals;
reg [2:0] rst_n = 3'b000;
reg [23:0] counter = 0;

//DRAM wires
wire [23:0] dram_addr;
wire dram_req_read, dram_req_write, dram_data_valid;
wire [31:0] dram_data_out, dram_data_in;

wire [31:0] data_in2;
wire [23:0] addr2, addr1;

wire req_read2, req_write2, req_read1, dram_write_complete;


//assign Snd = {3'b0,snd};
//assign Snd = snd_signals;
assign clk = CLOCK_50;
ntsc_gen #(.DATA_BITS(4)) gen(
                              // Outputs
                              .v_data           (Snd),
                              .v_sync           (v_sync),
                              // Inputs
                              .clk              (ntsc_clk));
pll1 pll(
    .inclk0(CLOCK_50),
    .c0(ntsc_clk));

core core(
          // Outputs
          .LED                          (LED[7:0]),
          .tx                           (Tx),
          .snd_out                      (snd),
          .snd_signals                  (snd_signals),
          // Inputs
          .clk                          (clk),
          .rst_n                        (rst_n[2]),
          .rx                           (Rx),
          .switches                     (SW[3:0]),
      
          .dram_data_out                (data_in2),
          .dram_addr                    (addr2),
          .dram_req_read                (req_read2),
          .dram_req_write               (req_write2),
          .dram_data_in                 (data_out2),
          .dram_data_valid              (data_valid2),
          .dram_write_complete          (write_complete2)
        
      );
   wire CLOCK_100, CLOCK_100_del_3ns;
   sdram_clk_gen clk_gen(
                     .inclk0(CLOCK_50),
                     .c0(CLOCK_100_del_3ns),
                     .c1(CLOCK_100));
   
   sdram_controller3 controller(
                                .data_out       (dram_data_out[31:0]),
                                .data_valid     (dram_data_valid),
                                // Outputs
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
                                .data_in        (dram_data_in[31:0])
                                /*AUTOINST*/);
   

bus_arbiter arbiter(
                    // Outputs
                    .data1              (data1[31:0]),
                    .data_valid1        (data_valid1),
                    .data_out2          (data_out2[31:0]),
                    .data_valid2        (data_valid2),
                    .write_complete2    (write_complete2),
                    .dram_addr          (dram_addr[23:0]),
                    .dram_data_in       (dram_data_in[31:0]),
                    .dram_req_read      (dram_req_read),
                    .dram_req_write     (dram_req_write),
                    // Inputs
                    .clk                (clk),
                    .addr1              (addr1[23:0]),
                    .req_read1          (req_read1),

                    .addr2              (addr2[23:0]),
                    .data_in2           (data_in2[31:0]),
                    .req_read2          (req_read2),
                    .req_write2         (req_write2),
                    .dram_data_out      (dram_data_out[31:0]),
                    .dram_data_out_valid(dram_data_valid),
                    .dram_write_complete(dram_write_complete));
//assign LED[7] = Tx;

always @(posedge CLOCK_50)begin
    rst_n <= {rst_n[1:0],KEY[0]};
    counter <= counter + 1;
end
endmodule
