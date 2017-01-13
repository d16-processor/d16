`timescale 1ns/1ps
module mem(
    input clk,
    input rst,
    input en,
    input write_enable,
    input byte_select,
    input byte_enable,
    input [15:0] addr,
    input [15:0] data_in,
    output reg [15:0] data_out,
    output mem_wait);

reg [15:0] mem_storage [0:63];
initial begin
    $readmemh("mem.hex",mem_storage);
end
assign mem_wait = 0;
always @(posedge clk) begin
    if (rst == 1) begin
        data_out <= 0;
        /*AUTORESET*/
    end
    if(en == 1)begin
        if(addr < 64) begin
            data_out <= mem_storage[addr[5:0]];
            if(write_enable == 1) begin
                if(byte_enable == 1) begin
                    if(byte_select == 1)
                        mem_storage[addr[5:0]][15:8] <= data_in[7:0];
                    else
                        mem_storage[addr[5:0]][7:0] <= data_in[7:0];
                end
                else
                    mem_storage[addr[5:0]] <= data_in;
            end
        end
    end
end
endmodule
