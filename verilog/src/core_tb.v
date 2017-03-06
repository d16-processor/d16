//deps: core.v
`timescale 1ns/1ps
module core_tb;
/*AUTOREGINPUT*/
// Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
reg                     clk;                    // To core of core.v
reg [31:0]              dram_data_in;           // To core of core.v
reg                     dram_data_valid;        // To core of core.v
reg                     dram_write_complete;    // To core of core.v
reg                     rst_n;                  // To core of core.v
reg                     rx;                     // To core of core.v
reg [3:0]               switches;               // To core of core.v
// End of automatics
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [7:0]              LED;                    // From core of core.v
wire [23:0]             dram_addr;              // From core of core.v
wire [31:0]             dram_data_out;          // From core of core.v
wire                    dram_req_read;          // From core of core.v
wire                    dram_req_write;         // From core of core.v
wire                    snd_out;                // From core of core.v
wire [3:0]              snd_signals;            // From core of core.v
wire                    tx;                     // From core of core.v
// End of automatics
core core(/*AUTOINST*/
          // Outputs
          .LED                          (LED[7:0]),
          .tx                           (tx),
          .snd_out                      (snd_out),
          .snd_signals                  (snd_signals[3:0]),
          .dram_data_out                (dram_data_out[31:0]),
          .dram_addr                    (dram_addr[23:0]),
          .dram_req_read                (dram_req_read),
          .dram_req_write               (dram_req_write),
          // Inputs
          .clk                          (clk),
          .rst_n                        (rst_n),
          .rx                           (rx),
          .switches                     (switches[3:0]),
          .dram_data_in                 (dram_data_in[31:0]),
          .dram_data_valid              (dram_data_valid),
          .dram_write_complete          (dram_write_complete));
initial begin
    clk <= 0;
    rst_n <= 0;
    rx <= 1;
    dram_data_in <= 32'hdeadbeef;
    dram_data_valid <= 0;
    dram_write_complete <= 0;
    switches <= 0;


    $dumpfile("dump.vcd");
    $dumpvars;
end
always #5 clk <= ~clk;
initial begin
    #20 rst_n <= 1;

    #10000 $finish;
end
reg busy = 0;
always @(posedge clk) begin
    if(dram_req_write && busy == 0) begin
        busy <= 1;
        #40 dram_write_complete <= 1;
    end
    if(dram_write_complete) begin
        busy <= 0;
        dram_write_complete <= 0;
    end
    if(dram_req_read && busy == 0) begin
        busy <= 1;
        #80 dram_data_valid <= 1;
    end
    if(dram_data_valid) begin
        busy <= 0;
        dram_data_valid <= 0;
    end
end


endmodule
