`timescale 1ns/1ps
`include "cpu_constants.vh"
module dma_controller(
    input clk,
    input rst,
    input en,

    input [15:0] addr,
    input [15:0] data_in,
    input write_enable,

    output reg [15:0] ram_addr,
    output reg [15:0] ram_data_out,
    output reg ram_we,
    input  [15:0] ram_data_in,

    output reg [23:0] dram_addr,
    output reg [31:0] dram_data_out,
    output reg dram_req_read,
    output reg dram_req_write,
    input  [31:0] dram_data_in,
    input  dram_data_valid,
    input  dram_write_complete
    );
reg [2:0] dma_type = 0;
reg dma_in_progress = 0;
reg [15:0] local_addr;
reg [23:0] remote_addr;
reg [15:0] count;
localparam STATE_BITS = 6;
localparam STATE_NOP  = 6'b111111;
localparam STATE_DRAM_WRITE = 6'b000000;
localparam STATE_DRAM_READ  = 6'b000001; 
localparam STATE_RESERVED   = 6'b000111;
localparam STATE_DW_READ_LOW = 6'b001000;
localparam STATE_DW_READ_HIGH = 6'b010000;
localparam STATE_DW_WRITE_RAM = 6'b011000;


reg [STATE_BITS-1:0] state = STATE_NOP;
reg [31:0] ram_data;

//configuration process
always @(posedge clk) begin
    if(rst == 1) begin
        state <= STATE_NOP;
        dma_in_progress <= 0;
    end
    else if(en == 1 && write_enable == 1)
        case({addr[14:0],1'b0})
            `DMA_CONTROL_ADDR: begin
                dma_type <= data_in[2:0];
                dma_in_progress <= 1;
            end
            `DMA_LOCAL_ADDR:
                local_addr <= data_in;
            `DMA_PERIPH_ADDR:
                remote_addr <= {data_in,8'b0};
            `DMA_COUNT_ADDR:
                count <= data_in >> 1;
        endcase
    else 
    case(state)
        STATE_DRAM_WRITE: begin
            ram_addr <= local_addr;
            local_addr <= local_addr + 1;
            state <= STATE_DW_READ_LOW;
        end
        STATE_DW_READ_LOW:begin
            ram_data[31:16] <= ram_data_in;
            ram_addr <= local_addr;
            local_addr <= local_addr + 1;
            count <= count - 2;
            state <= STATE_DW_READ_HIGH;
        end
        STATE_DW_READ_HIGH: begin
            ram_data[15:0] <= ram_data_in;
            dram_addr <= remote_addr;
            remote_addr <= remote_addr - 1;
            dram_req_write <= 1'b1;
            dram_data_out  <= ram_data;
            state <= STATE_DW_WRITE_RAM;
        end
        STATE_DW_WRITE_RAM:
            if(dram_write_complete == 1) begin
                dram_req_write <= 1'b0;
                if(count == 0) begin
                    state <= STATE_NOP;
                    dma_in_progress <= 0;
                end
                else begin
                    state <= STATE_DRAM_WRITE;
                end
            end


    
        STATE_NOP:
            if(dma_in_progress)
                state <= {2'b0,dma_type};
    endcase
end


endmodule
