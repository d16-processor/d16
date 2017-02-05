`timescale 1ns/1ps
module lr(input clk,
    input rst,
    input wr_en,
    input [15:0] lr_in,
    output [15:0] lr_out);
reg [15:0] link_register = 0;
assign lr_out = link_register;
always @(posedge clk) begin
    if(rst == 1)
        link_register <= 0;
    else if(wr_en == 1)
        link_register <= lr_in;
end
`ifdef FORMAL
always @(posedge clk) begin
    if($initstate) begin
        assume(rst == 0);
        assume(wr_en == 0);
        assume($past(wr_en) == 0);
    end
    else begin
        if($past(rst) == 1)
            assert(link_register == 0);
        if($past(wr_en) == 1 && $past(rst) != 1)
            assert(link_register == $past(lr_in));
    end
end
`endif
endmodule
