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
    output mem_wait,
    //port 2
    input write_enable_2,
    input [15:0] addr2,
    input [15:0] data_in2,
    output reg [15:0] data_out2
    );
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire [15:0]         q_a;                    // From ram of ram_macro.v
    wire [15:0]         q_b;                    // From ram of ram_macro.v
    reg [15:0]         data_a;
    reg [1:0] byteena_a;
    assign mem_wait = 0;
    // End of automatics
    ram_macro ram(
                  // Outputs
                  .q_a                  (q_a[15:0]),
                  .q_b                  (q_b[15:0]),
                  // Inputs
                  .address_a            (addr[13:0]),
                  .address_b            (addr2[13:0]),
                  .byteena_a            (byteena_a[1:0]),
                  .clock                (clk),
                  .data_a               (data_a[15:0]),
                  .data_b               (data_in2[15:0]),
                  .wren_a               (write_enable),
                  .wren_b               (write_enable2));
//input logic
always @* begin
    if(byte_enable) begin
        if(byte_select) begin
            byteena_a <= 2'b10;
        end
        else begin
            byteena_a <= 2'b01;
        end
    end
    else begin
        byteena_a <= 2'b11;
    end
    data_a <= data_in;
end
always @* begin
    if(byte_enable) begin
        if(byte_select)
            data_out <= {8'b0,q_a[15:8]};
        else
            data_out <= {8'b0,q_a[7:0]};
    end
    else begin
        data_out <= q_a;
    end
end
always @* begin
    data_out2 <= q_b;
end

endmodule
