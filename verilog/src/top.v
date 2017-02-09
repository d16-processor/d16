module top(input CLOCK_50, input [1:0] KEY, output [7:0] LED, output Tx, input Rx);
/*AUTOWIRE*/
wire clk;
reg [2:0] rst_n;
reg [23:0] counter = 0;

core core(/*AUTOINST*/
          // Outputs
          .LED                          (LED[7:0]),
          .tx                           (Tx),
          // Inputs
          .clk                          (clk),
          .rst_n                        (rst_n[2]),
          .rx                           (Rx));
assign clk = CLOCK_50;
//assign LED[7] = Tx;

always @(posedge CLOCK_50)begin
    rst_n <= {rst_n[1:0],KEY[0]};
    counter <= counter + 1;
end
endmodule
