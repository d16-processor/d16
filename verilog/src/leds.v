`timescale 1ns/1ps
module leds(
    input clk,
    input en,
    input rst,
    input wr_en,
    input [15:0] data,
    output reg [7:0] led_out);

    always @(posedge clk) begin
        if(rst == 1)
            led_out <= 0;
        else if(en == 1 && wr_en == 1) 
            led_out <= data[7:0];
    end
`ifdef FORMAL
    always @(posedge clk) begin
        if($initstate == 1) begin
            assume($past(rst) == 1);
            assume($past(en) == 0);
            assume($past(wr_en) == 0);
            assume($past(data[7:0]) == 0);
            assume(led_out == 0);
        end
        else if($past(rst) == 1)
            assert(led_out == 0);
        else if($past(en) == 1) begin
            if($past(wr_en) == 1)
                assert(led_out == $past(data[7:0]));

        end

    end
`endif
endmodule
