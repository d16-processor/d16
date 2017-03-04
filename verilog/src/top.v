module top(input CLOCK_50, input [1:0] KEY, output [7:0] LED, 
    output Tx, input Rx, output [3:0] Snd, input [3:0] SW,
    //DRAM signals
    output [12:0]   DRAM_ADDR,
    output [1:0]    DRAM_BA,
    output          DRAM_CKE,
    output          DRAM_CLK,
    output          DRAM_CS_N,
    inout  [15:0]   DRAM_DQ,
    output [1:0]    DRAM_DQM,
    output          DRAM_RAS_N,
    output          DRAM_WE_N

);
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
// End of automatics
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


//assign Snd = {3'b0,snd};
//assign Snd = snd_signals;
assign clk = CLOCK_50;
ntsc_gen #(.DATA_BITS(4)) gen(/*AUTOINST*/
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
          .switches                     (SW[3:0]));

sdram_controller controller(
    .CLOCK_50(clk),
    .DRAM_ADDR(DRAM_ADDR),
    .DRAM_BA(DRAM_BA),
    .DRAM_CAS_N(DRAM_CAS_N),
    .DRAM_CKE(DRAM_CKE),
    .DRAM_CLK(DRAM_CLK),
    .DRAM_CS_N(DRAM_CS_N),
    .DRAM_DQ(DRAM_DQ),
    .DRAM_DQM(DRAM_DQM),
    .DRAM_RAS_N(DRAM_RAS_N),
    .DRAM_WE_N(DRAM_WE_N),

    .address(dram_addr),
    .req_read(dram_req_read),
    .req_write(dram_req_write),
    .data_out(dram_data_out),
    .data_out_valid(dram_data_valid),
    .data_in(dram_data_in)
);
bus_arbiter arbiter(/*AUTOINST*/);
//assign LED[7] = Tx;

always @(posedge CLOCK_50)begin
    rst_n <= {rst_n[1:0],KEY[0]};
    counter <= counter + 1;
end
endmodule
