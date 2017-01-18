module top(input CLOCK_50, input [1:0] KEY, output [7:0] LED);
/*AUTOWIRE*/
wire clk;
wire rst_n;

reg [2:0] rst_sync = 0;
reg [23:0] counter = 0;
core core(/*AUTOINST*/
          // Outputs
          .LED                          (LED),
          // Inputs
          .clk                          (clk),
          .rst_n                        (rst_n));
assign clk = counter[21];
assign rst_n = rst_sync[2];
always @(posedge CLOCK_50) begin
    counter <= counter + 1;
	 rst_sync <= {rst_sync[1:0],KEY[1]};
end

endmodule
