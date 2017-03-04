`timescale 1ns/1ps
module bus_arbiter_tb;
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire [31:0]         data1;                  // From arbiter of bus_arbiter.v
    wire [31:0]         data_out2;              // From arbiter of bus_arbiter.v
    wire                data_valid1;            // From arbiter of bus_arbiter.v
    wire                data_valid2;            // From arbiter of bus_arbiter.v
    wire [23:0]         dram_addr;              // From arbiter of bus_arbiter.v
    wire [31:0]         dram_data_in;           // From arbiter of bus_arbiter.v
    wire                dram_req_read;          // From arbiter of bus_arbiter.v
    wire                dram_req_write;         // From arbiter of bus_arbiter.v
    wire                write_complete2;        // From arbiter of bus_arbiter.v
    // End of automatics
    /*AUTOREGINPUT*/
    // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
    reg [23:0]          addr1;                  // To arbiter of bus_arbiter.v
    reg [23:0]          addr2;                  // To arbiter of bus_arbiter.v
    reg                 clk;                    // To arbiter of bus_arbiter.v
    reg [31:0]          data_in2;               // To arbiter of bus_arbiter.v
    reg [31:0]          dram_data_out;          // To arbiter of bus_arbiter.v
    reg                 dram_data_out_valid;    // To arbiter of bus_arbiter.v
    reg                 dram_write_complete;    // To arbiter of bus_arbiter.v
    reg                 req_read1;              // To arbiter of bus_arbiter.v
    reg                 req_read2;              // To arbiter of bus_arbiter.v
    reg                 req_write2;             // To arbiter of bus_arbiter.v
    // End of automatics
    bus_arbiter arbiter(/*AUTOINST*/
                        // Outputs
                        .data1          (data1[31:0]),
                        .data_valid1    (data_valid1),
                        .data_out2      (data_out2[31:0]),
                        .data_valid2    (data_valid2),
                        .write_complete2(write_complete2),
                        .dram_addr      (dram_addr[23:0]),
                        .dram_data_in   (dram_data_in[31:0]),
                        .dram_req_read  (dram_req_read),
                        .dram_req_write (dram_req_write),
                        // Inputs
                        .clk            (clk),
                        .addr1          (addr1[23:0]),
                        .req_read1      (req_read1),
                        .addr2          (addr2[23:0]),
                        .data_in2       (data_in2[31:0]),
                        .req_read2      (req_read2),
                        .req_write2     (req_write2),
                        .dram_data_out  (dram_data_out[31:0]),
                        .dram_data_out_valid(dram_data_out_valid),
                        .dram_write_complete(dram_write_complete));
initial begin
    addr1 = 0;
    addr2 = 0;
    clk = 0;
    data_in2 = 0;
    dram_data_out = 0;
    dram_data_out_valid = 0;
    dram_write_complete = 0;
    req_read1 = 0;
    req_read2 = 0;
    req_write2 = 0;
end
always #10 clk <= ~clk;
initial begin
    #20 
    addr1 <= 'hfe00;
    req_read1 <= 1;
    #20 
    req_read1 <= 0;
    @(posedge data_valid1)
    req_read1 <= 1;
    addr1 <= 'hfe10;
    req_write2 <= 1;
    addr2 <= 'h3454;
    data_in2 <= 'hfeed;
    @(posedge data_valid1) 
    req_read1 <= 0;
    @(posedge write_complete2)
    req_write2 <= 0;
end
reg busy = 0;
always @(posedge clk)begin
    if(dram_req_read == 1 && busy == 0) begin
        #140 dram_data_out = 32'hdeadbeef;
        dram_data_out_valid = 1;
        #20 
        dram_data_out_valid = 0;
    end
    else if(dram_req_write == 1 && busy == 0) begin
        #80 dram_write_complete = 1;
        #20 dram_write_complete = 0;
    end
end


endmodule
