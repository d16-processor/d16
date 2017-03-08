`define PASS_THROUGH
module bus_arbiter(
    input clk,

    input [23:0] addr1,
    output reg [31:0] data1 = 0,
    input req_read1,
    output data_valid1, 

    input [23:0] addr2,
    input [31:0] data_in2,
    output reg [31:0] data_out2 = 0,
    input req_read2,
    input req_write2,
    output data_valid2, 
    output write_complete2,

    output reg [23:0] dram_addr,
    output reg [31:0] dram_data_in, 
    output reg dram_req_read,
    output reg dram_req_write,
    input [31:0] dram_data_out,
    input dram_data_out_valid,
    input dram_write_complete);

reg current_device = 0;
reg busy = 0;
assign write_complete2 = current_device ? dram_write_complete : 0;
assign data_valid1 = current_device ? 0 : dram_data_out_valid;
assign data_valid2 = current_device ? dram_data_out_valid : 0;

`ifdef PASS_THROUGH
    always @* begin
        current_device <= 1'b1;
        dram_addr <= addr2;
        dram_data_in <= data_in2;
        data_out2 <= dram_data_out;
        dram_req_read <= req_read2;
        dram_req_write <= req_write2;
    end

`else
always @(posedge clk) begin
    if(req_read1 == 1 && !busy) begin
        current_device <= 0;
        dram_addr <= addr1;
        dram_req_read <= 1;
        busy <= 1;
    end
    else if((req_read2 || req_write2) && !busy) begin
        current_device <= 1;
        busy <= 1;
        dram_addr <= addr2;
        dram_req_read <= req_read2;
        dram_req_write <= req_write2;
        dram_data_in <= data_in2;
    end
    else begin
        dram_req_read <= 0;
        dram_req_write <= 0;
    end

    if(busy == 1) begin
        dram_req_read <= 0;
        dram_req_write <= 0;
        if(dram_data_out_valid == 1)
            if(current_device == 1) begin
                data_out2 <= dram_data_out;
                busy <= 0;
            end
            else begin
                data1 <= dram_data_out;
                busy <= 0;
            end
        if(dram_write_complete) begin
           busy <= 0;
       end
   end
end
`endif
endmodule
