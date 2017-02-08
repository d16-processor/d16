module top(input CLOCK_50, input [1:0] KEY, output [7:0] LED, output Tx, input Rx);
/*AUTOWIRE*/
wire clk;
wire rst_n;

core core(/*AUTOINST*/
          // Outputs
          .LED                          (LED),
          .tx                           (Tx),
          // Inputs
          .clk                          (clk),
          .rst_n                        (rst_n),
          .rx                           (Rx));
assign clk = CLOCK_50;

endmodule
