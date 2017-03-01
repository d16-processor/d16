module top(input CLOCK_50, input [1:0] KEY, output [7:0] LED, 
    output Tx, input Rx, output [3:0] Snd, input [3:0] SW);
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire                    v_sync;                 // From gen of ntsc_gen.v
// End of automatics
wire clk;
wire snd;
wire [3:0] snd_signals;
reg [2:0] rst_n = 3'b000;
reg [23:0] counter = 0;
//assign Snd = {3'b0,snd};
//assign Snd = snd_signals;
ntsc_gen #(.DATA_BITS(4)) gen(/*AUTOINST*/
                              // Outputs
                              .v_data           (Snd),
                              .v_sync           (v_sync),
                              // Inputs
                              .clk              (clk));

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
assign clk = CLOCK_50;
//assign LED[7] = Tx;

always @(posedge CLOCK_50)begin
    rst_n <= {rst_n[1:0],KEY[0]};
    counter <= counter + 1;
end
endmodule
