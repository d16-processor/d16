//deps: fifo.v
`timescale 1ns/1ps
module fifo_tb;
parameter FIFO_WIDTH = 8;
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire                    empty;                  // From fifo of fifo.v
wire                    full;                   // From fifo of fifo.v
wire [FIFO_WIDTH-1:0]   output_data;            // From fifo of fifo.v
// End of automatics
/*AUTOREGINPUT*/
// Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
reg                     clk;                    // To fifo of fifo.v
reg [FIFO_WIDTH-1:0]    input_data;             // To fifo of fifo.v
reg                     rd;                     // To fifo of fifo.v
reg                     rst;                    // To fifo of fifo.v
reg                     wr;                     // To fifo of fifo.v
// End of automatics
fifo fifo(/*AUTOINST*/
          // Outputs
          .output_data                  (output_data[FIFO_WIDTH-1:0]),
          .empty                        (empty),
          .full                         (full),
          // Inputs
          .clk                          (clk),
          .rst                          (rst),
          .rd                           (rd),
          .wr                           (wr),
          .input_data                   (input_data[FIFO_WIDTH-1:0]));
initial begin
    clk = 0;
    input_data = 0;
    rd = 0;
    rst = 1;
    wr = 0;

    $dumpfile("dump.vcd");
    $dumpvars;
end
always #5 clk <= ~clk;

initial begin
    #10 rst <= 0;
        input_data <= 8'h67;
        wr <= 1;
    #10 wr <= 0;
    #10 input_data <= 8'h4d;
        wr <= 1;
    #10 input_data <= 8'hef;
    #10 input_data <= 8'h01;
    #10 input_data <= 8'h02;
    #10 input_data <= 8'h03;
    #10 input_data <= 8'h04;
    #10 input_data <= 8'h05;
    #10 wr <= 0;
        rd <= 1;
    #80 rd <= 0;
    #30 $finish;
end

endmodule
