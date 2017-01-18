`timescale 1ns/1ps
module leds(
    input clk,
    input en,
    input rst,
    input wr_en,
    input [15:0] data,
    input [15:0] addr,
    output reg [7:0] led_out);

    always @(posedge clk) begin
        if(rst == 1)
            led_out <= 0;
        else if(en == 1) 
            if({addr[14:0],1'b0} == 16'hff00 && wr_en == 1)
                led_out <= data[7:0];
    end
endmodule
