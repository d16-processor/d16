module dma_controller(
    input clk,
    input rst,
    input en,

    input [15:0] addr,
    input [15:0] data_in,
    input write_enable);
reg [2:0] dma_type = 0;
reg dma_in_progress = 0;
reg [15:0] local_addr;
reg [23:0] remote_addr;
reg [15:0] count;

//configuration process
always @(posedge clk) begin
    if(en == 1 && write_enable == 1)
        case({addr[14:0],1'b0})
            `DMA_CONTROL_ADDR:
                dma_type <= data_in[2:0];
            `DMA_LOCAL_ADDR:
                local_addr <= data_in;
            `DMA_PERIPH_ADDR:
                remote_addr <= {data_in,8'b0};
            `DMA_COUNT_ADDR:
                count <= data_in >> 1;
        endcase
end


endmodule
