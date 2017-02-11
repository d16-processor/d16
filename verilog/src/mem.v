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

reg [15:0] mem_storage [0:MEM_WORDS-1];
reg [15:0] s_addr = 0;
reg s_byte_select, s_byte_enable;
wire [15:0] mem_data;
parameter MEM_BYTES = 128;
parameter MEM_WORDS = MEM_BYTES / 2;

initial begin
    $readmemh("mem.hex",mem_storage);
end
assign mem_wait = 0;
assign mem_data = mem_storage[s_addr];
always @* begin
    if(s_byte_enable == 1)
        if(s_byte_select == 1)
            data_out <= {8'b0,mem_data[15:8]};
        else
            data_out <= {8'b0,mem_data[7:0]};
    else
        data_out <= mem_data;
end
always @(posedge clk) begin
    s_byte_enable <= byte_enable;
    s_byte_select <= byte_select;
    if (rst == 1) begin
        s_addr <= 0;
        /*AUTORESET*/
    end
    else if(en == 1)begin
        if(addr < MEM_WORDS) begin
            if(write_enable == 1) begin
                if(byte_enable == 1) begin
                    if(byte_select == 1) begin
                        mem_storage[addr][15:8] <= data_in[7:0];
                        mem_storage[addr][7:0] <= mem_storage[addr][7:0];
                    end
                    else begin
                        mem_storage[addr][7:0] <= data_in[7:0];
                        mem_storage[addr][15:8] <= mem_storage[addr][15:8];
                    end
                end
                else
                    mem_storage[addr] <= data_in;
            end
        end
		  s_addr <= addr;
		  
    end
end
endmodule
