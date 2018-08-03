`timescale 1ns/1ps
`include "cpu_constants.vh"
module dma_controller(
    input clk,
    input rst,
    input en,
    output dma_status,

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
reg [15:0] local_addr = 0;
reg [23:0] remote_addr = 0;
reg [15:0] count = 2;
    assign dma_status = dma_in_progress;

localparam STATE_BITS          = 6;
localparam 			// auto enum dma_state
  STATE_NOP           = 6'b111111,
  STATE_DRAM_WRITE    = 6'b000000,
  STATE_DRAM_READ     = 6'b000001,
  STATE_RESERVED      = 6'b000111,
  //write
  STATE_DW_READ_LOW   = 6'b001000,
  STATE_DW_READ_HIGH  = 6'b010000,
  STATE_DW_WRITE_RAM  = 6'b011000,
  //read
  STATE_DR_READ       = 6'b001001,
  STATE_DR_WRITE_LOW  = 6'b010001,
  STATE_DR_WRITE_HIGH = 6'b011001;


reg   				// auto enum dma_state
    [STATE_BITS-1:0] state = STATE_NOP;
reg [31:0] ram_data = 0;

//configuration process
always @(posedge clk) begin
    ram_addr <= local_addr;
    if(rst == 1) begin
        state <= STATE_NOP;
        dma_in_progress <= 0;
        ram_data_out <= 0;
        ram_we <= 0;
        dram_addr <= 0;
        dram_data_out <= 0;
        dram_req_read <= 0;
        dram_req_write <= 0;
        ram_data <= 0;
    end
    else if(en == 1 && write_enable == 1) 
        case({addr[14:0],1'b0})
            `DMA_CONTROL_ADDR: begin
                dma_type <= data_in[2:0];
                dma_in_progress <= 1;
            end
            `DMA_LOCAL_ADDR: begin
                local_addr <= data_in>>1;
		end
            `DMA_PERIPH_ADDR:
                remote_addr <= {data_in,8'b0};
            `DMA_COUNT_ADDR:
                count <= data_in >> 2;
        endcase
    else 
    case(state)
        STATE_DRAM_WRITE: begin
            local_addr <= local_addr + 1;
	    ram_addr <= local_addr + 1;
            state <= STATE_DW_READ_LOW;
        end
        STATE_DW_READ_LOW:begin
            ram_data[15:0] <= ram_data_in;
            local_addr <= local_addr + 1;
	    ram_addr <= local_addr + 1;
            count <= count - 1;
            state <= STATE_DW_READ_HIGH;
        end
        STATE_DW_READ_HIGH: begin
            ram_data[31:16] <= ram_data_in;
            dram_addr <= remote_addr;
            remote_addr <= remote_addr + 2;
            dram_req_write <= 1'b1;
            dram_data_out[15:0] <= ram_data[15:0];
            dram_data_out[31:16] <= ram_data_in;
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
        STATE_DRAM_READ: begin
            ram_we <= 0;
            dram_addr <= remote_addr;
            dram_req_read <= 1;
            remote_addr <= remote_addr + 2;
            count <= count - 1;
            state <= STATE_DR_READ;
        end
        STATE_DR_READ:begin
           dram_req_read <= 0;
           if(dram_data_valid == 1)begin
              dram_req_read <= 0;
              state <= STATE_DR_WRITE_LOW;
           end
           end
        STATE_DR_WRITE_LOW:begin
            local_addr <= local_addr + 1;
            ram_we <= 1;
            ram_data_out <= dram_data_in[15:0];
            state <= STATE_DR_WRITE_HIGH;
        end
        STATE_DR_WRITE_HIGH:begin
            local_addr <= local_addr + 1;
            ram_data_out <=dram_data_in[31:16];
            if(count == 0) begin
                state <= STATE_NOP;
                dma_in_progress <= 0;
            end

            else
                state <= STATE_DRAM_READ;
        end




    
        STATE_NOP:begin
            ram_we <= 0;
            if(dma_in_progress)
                state <= {2'b0,dma_type};
        end
    endcase
end
    /*AUTOASCIIENUM("state", "state_ascii")*/
    // Beginning of automatic ASCII enum decoding
    reg [151:0]		state_ascii;		// Decode of state
    always @(state) begin
	case ({state})
	  STATE_NOP:           state_ascii = "state_nop          ";
	  STATE_DRAM_WRITE:    state_ascii = "state_dram_write   ";
	  STATE_DRAM_READ:     state_ascii = "state_dram_read    ";
	  STATE_RESERVED:      state_ascii = "state_reserved     ";
	  STATE_DW_READ_LOW:   state_ascii = "state_dw_read_low  ";
	  STATE_DW_READ_HIGH:  state_ascii = "state_dw_read_high ";
	  STATE_DW_WRITE_RAM:  state_ascii = "state_dw_write_ram ";
	  STATE_DR_READ:       state_ascii = "state_dr_read      ";
	  STATE_DR_WRITE_LOW:  state_ascii = "state_dr_write_low ";
	  STATE_DR_WRITE_HIGH: state_ascii = "state_dr_write_high";
	  default:             state_ascii = "%Error             ";
	endcase
    end
    // End of automatics


endmodule
