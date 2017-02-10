`timescale 1ns/1ps
module fifo(clk,rst,rd,wr,input_data,output_data,empty,full);
parameter FIFO_WIDTH = 8;
parameter FIFO_DEPTH = 8;
parameter POINTER_BITS = 3;
input clk;
input rst;
input rd;
input wr;
input [FIFO_WIDTH-1:0] input_data;
output reg [FIFO_WIDTH-1:0] output_data;
output empty;
output full;
reg [FIFO_WIDTH-1:0] memory [0:FIFO_DEPTH-1];
reg [POINTER_BITS:0] rd_ptr = 0;
reg [POINTER_BITS:0] wr_ptr = 0;

assign empty = rd_ptr == wr_ptr;
assign full = (rd_ptr[POINTER_BITS-1:0] == wr_ptr[POINTER_BITS-1:0]) & (rd_ptr[POINTER_BITS] ^ wr_ptr[POINTER_BITS]);
always @(posedge clk)begin
    output_data <= memory[rd_ptr[POINTER_BITS-1:0]];
    if(rst == 1) begin
        rd_ptr <= 0;
        wr_ptr <= 0;
        output_data <= 0;
    end
    else begin
        if(rd == 1) begin
            rd_ptr <= rd_ptr + 1;
        end
        if(wr == 1) begin
            memory[wr_ptr[POINTER_BITS-1:0]] <= input_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

end
endmodule
