//deps: leds.v
`timescale 1ns/1ps
`include "cpu_constants.vh"
module mmio(
    input clk,
    input rst,
    input en,
    input write_enable,
    input byte_select,
    input byte_enable,
    input [15:0] addr,
    input [15:0] data_in,
    output [15:0] data_out,
    output [7:0] led_out);
    wire [15:0] real_addr;
    assign real_addr = {addr[14:0],byte_select};
    wire led_wr_en;
leds leds(/*AUTOINST*/
          // Outputs
          .led_out                      (led_out[7:0]),
          // Inputs
          .clk                          (clk),
          .en                           (en),
          .rst                          (rst),
          .wr_en                        (led_wr_en),
          .data                         (data_in[15:0]));
    assign led_wr_en = real_addr == `LED_WR_ADDR && write_enable == 1;

endmodule
