//deps: core.v
`timescale 1ns/1ps
module core_tb;
/*AUTOREGINPUT*/
// Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
reg                     clk;                    // To core of core.v
reg                     rst_n;                  // To core of core.v
// End of automatics
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [7:0]              LED;                    // From core of core.v
// End of automatics
core core(/*AUTOINST*/
          // Outputs
          .LED                          (LED[7:0]),
          // Inputs
          .clk                          (clk),
          .rst_n                        (rst_n));
initial begin
    clk <= 0;
    rst_n <= 0;

    $dumpfile("dump.vcd");
    $dumpvars;
end
always #5 clk <= ~clk;
initial begin
    #20 rst_n <= 1;

    #1000 $finish;
end
endmodule
