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
    output [15:0] data_out,
    output mem_wait);


parameter MEM_BYTES = 128;
parameter MEM_WORDS = MEM_BYTES / 2;
reg [15:0] mem_storage [0:MEM_WORDS-1];
reg [15:0] s_addr = 0;
initial begin
    $readmemh("mem.hex",mem_storage);
end
assign mem_wait = 0;
reg s_byte_select;
reg s_byte_enable;
assign data_out = s_byte_enable ? (s_byte_select ? mem_storage[s_addr][15:8] : mem_storage[s_addr][7:0]) :mem_storage[s_addr];
always @(posedge clk) begin
    if (rst == 1) begin
        s_addr <= 0;
        s_byte_enable <= 0;
        s_byte_select <= 0;
        /*AUTORESET*/
        // Beginning of autoreset for uninitialized flops
        // End of automatics
    end
    else if(en == 1)begin
        s_byte_enable <= byte_enable;
        s_byte_select <= byte_select;
        if(addr < MEM_WORDS) begin
            if(write_enable == 1) begin
                if(byte_enable == 1) begin
                    if(byte_select == 1)
                        mem_storage[addr][15:8] <= data_in[7:0];
                    else
                        mem_storage[addr][7:0] <= data_in[7:0];
                end
                else
                    mem_storage[addr] <= data_in;
            end
        end
                  s_addr <= addr;
                  
    end
end
endmodule
