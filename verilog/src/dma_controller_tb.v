`timescale 1ns/1ps
`include "cpu_constants.vh"
module dma_controller_tb;
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire                dma_status;             // From dma of dma_controller.v
    wire [23:0]         dram_addr;              // From dma of dma_controller.v
    wire [31:0]         dram_data_out;          // From dma of dma_controller.v
    wire                dram_req_read;          // From dma of dma_controller.v
    wire                dram_req_write;         // From dma of dma_controller.v
    wire [15:0]         ram_addr;               // From dma of dma_controller.v
    wire [15:0]         ram_data_out;           // From dma of dma_controller.v
    wire                ram_we;                 // From dma of dma_controller.v
    // End of automatics
    /*AUTOREGINPUT*/
    // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
    reg [15:0]          addr;                   // To dma of dma_controller.v
    reg                 clk;                    // To dma of dma_controller.v
    reg [15:0]          data_in;                // To dma of dma_controller.v
    reg [31:0]          dram_data_in;           // To dma of dma_controller.v
    reg                 dram_data_valid;        // To dma of dma_controller.v
    reg                 dram_write_complete;    // To dma of dma_controller.v
    reg                 en;                     // To dma of dma_controller.v
    reg [15:0]          ram_data_in;            // To dma of dma_controller.v
    reg                 rst;                    // To dma of dma_controller.v
    reg                 write_enable;           // To dma of dma_controller.v
    // End of automatics
    dma_controller dma(/*AUTOINST*/
                       // Outputs
                       .dma_status      (dma_status),
                       .ram_addr        (ram_addr[15:0]),
                       .ram_data_out    (ram_data_out[15:0]),
                       .ram_we          (ram_we),
                       .dram_addr       (dram_addr[23:0]),
                       .dram_data_out   (dram_data_out[31:0]),
                       .dram_req_read   (dram_req_read),
                       .dram_req_write  (dram_req_write),
                       // Inputs
                       .clk             (clk),
                       .rst             (rst),
                       .en              (en),
                       .addr            (addr[15:0]),
                       .data_in         (data_in[15:0]),
                       .write_enable    (write_enable),
                       .ram_data_in     (ram_data_in[15:0]),
                       .dram_data_in    (dram_data_in[31:0]),
                       .dram_data_valid (dram_data_valid),
                       .dram_write_complete(dram_write_complete));
    
    initial begin
        clk = 0;
        rst = 1;
        en  = 1;
        addr = 0;
        data_in = 0;
        write_enable = 0;
        ram_data_in = 16'habcd;
        dram_data_in = 0;
        dram_data_valid = 0;
        dram_write_complete = 0;
    end
    always #5 clk <= ~clk;
    initial begin
        #20 rst <= 0;
        addr = `DMA_COUNT_ADDR >> 1;
        data_in = 16;
        write_enable = 1;
        @(posedge clk)
        addr = `DMA_PERIPH_ADDR >> 1;
        data_in = 16'hf00d;
        @(posedge clk)
        addr = `DMA_LOCAL_ADDR >> 1;
        data_in = 16'hbeef;
        @(posedge clk)
        addr = `DMA_CONTROL_ADDR >> 1;
        data_in = 0;
        @(posedge clk)
        write_enable = 0;
        //test read
        @(negedge dma_status)
        #20
        addr = `DMA_COUNT_ADDR >> 1;
        data_in = 16;
        write_enable = 1;
        @(posedge clk);
        addr = `DMA_PERIPH_ADDR >> 1;
        data_in = 16'h00c0;
        @(posedge clk)
        addr = `DMA_LOCAL_ADDR >> 1;
        data_in = 16'hfe00;
        @(posedge clk);
        addr = `DMA_CONTROL_ADDR >> 1;
        data_in = 1;
        @(posedge clk)
        write_enable = 0;

    end
    reg busy = 0;
    always @(posedge clk) begin
        if(dram_req_write && !busy) begin
            #30 dram_write_complete = 1;
            busy <= 1;
        end
        if(dram_write_complete && busy) begin
            dram_write_complete <= 0;
            busy <= 0;
        end
        if(dram_req_read && !busy) begin
            #80 dram_data_valid = 1;
            busy <= 1;
        end
        if(dram_data_valid && busy) begin
            dram_data_valid <= 0;
            busy <= 0;
        end
    end

endmodule
