`timescale 1ns/1ps
`ifdef FORMAL
`define COVER cover
`else
`define COVER
`endif
module leds(
    input clk,
    input en,
    input rst,
    input wr_en,
    input [15:0] data,
    output reg [7:0] led_out = 0);

    always @(posedge clk) begin
        if(rst == 1)begin
            `COVER;
            led_out <= 0;
        end
        else if(en == 1 && wr_en == 1) begin
            led_out <= data[7:0];
            `COVER;
        end
    end
`ifdef FORMAL
    reg [7:0] data_past = 0;
    always @(posedge clk) begin
        data_past <= data[7:0];
        if($initstate == 1) begin
            assume($past(rst) == 1);
            assume($past(en) == 0);
            assume($past(wr_en) == 0);
            assume(led_out == 0);
        end
        else if($past(rst) == 1)
            assert(led_out == 0);
        else if($past(en) == 1) begin
            if($past(wr_en) == 1)
                assert(led_out == data_past[7:0]);

        end

    end
`endif
endmodule
