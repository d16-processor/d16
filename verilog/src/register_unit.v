`timescale 1ns/1ps
`include "cpu_constants.vh"
module register_unit(
    input  clk,
    input  en,
    input  rst,
    input  wr_en,
    input  rS_wr_en,
    input  [2:0] rD_sel,
    input  [2:0] rS_sel,
    input  [15:0] rD_data_in,
    output [15:0] rD_data_out,
    input  [15:0] rS_data_in,
    output [15:0] rS_data_out);
    reg [15:0] registers[0:7];
    integer i;
    initial
        for(i=0;i<8;i=i+1)
            registers[i] = 0;
    reg [15:0] rD_data;
    reg [15:0] rS_data;

    assign rD_data_out = rD_data;
    assign rS_data_out = rS_data;
always @(posedge clk)
    if(rst == 1)
        for(i=0;i<8;i=i+1)
            registers[i] = 0;
    else if(en == 1) begin
        rD_data = registers[rD_sel];
        rS_data = registers[rS_sel];
        if (wr_en == 1) 
            registers[rD_sel] <= rD_data_in;
        if (rS_wr_en == 1)
            registers[rS_sel] <= rS_data_in;
    end
endmodule
