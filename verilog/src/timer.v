module timer(
    input clk,
    input en,
    input wr_en,
    input rst,
    input [15:0] data_in,
    output [15:0] data_out);
parameter CLOCK_FREQUENCY = 50_000_000;
parameter TICKS_PER_SECOND = 1000;
localparam COUNT = CLOCK_FREQUENCY/TICKS_PER_SECOND -1;
reg [23:0] counter_1 = 0;
reg [15:0] counter_2 = 0;
assign data_out = counter_2;
always @(posedge clk) begin
    if(rst == 1) begin
        counter_1 <= 0;
        counter_2 <= 0;
    end
    if(wr_en == 1 && en == 1) begin
        counter_1 <= 0;
        counter_2 <= data_in;
    end
    else
        if(counter_1 >= COUNT) 
            counter_1 <= 0;
        else
            counter_1 <= counter_1 + 1;
    if(counter_1 == COUNT && counter_2 != 0)
        counter_2 <= counter_2 - 1;

end


endmodule
