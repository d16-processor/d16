//deps: leds.v, uart_controller.v
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
    output reg [15:0] data_out,
    output [7:0] led_out,
    output reg serviced_read = 0,
    input rx,
    output tx);
    wire [15:0] real_addr;
    assign real_addr = {addr[14:0],byte_select};
    wire led_wr_en;
    wire [7:0] uart_data_out;
    wire [7:0] uart_status_out;
    wire uart_wr_en;
leds leds(
          // Outputs
          .led_out                      (led_out[7:0]),
          // Inputs
          .clk                          (clk),
          .en                           (en),
          .rst                          (rst),
          .wr_en                        (led_wr_en),
          .data                         (data_in[15:0]));
uart_controller uart(/*AUTOINST*/
                     // Outputs
                     .data_out          (uart_data_out[7:0]),
                     .status_out        (uart_status_out[7:0]),
                     .tx                (tx),
                     // Inputs
                     .rx                (rx),
                     .clk               (clk),
                     .en                (en),
                     .rst               (rst),
                     .wr_en             (uart_wr_en),
                     .data              (data_in[15:0]));
    assign led_wr_en = (real_addr == `LED_WR_ADDR) & write_enable;
    assign uart_wr_en = (real_addr == `UART_DATA_ADDR) & write_enable;
    always @(posedge clk)
        serviced_read <= en && !write_enable && real_addr >= 16'hff00;
    always @(posedge clk) begin
        case(real_addr)
            16'hff00:
                data_out <= led_out;
            16'hff03:
                data_out <= uart_status_out;
            16'hff02:
                data_out <= uart_data_out;
            default:
                data_out <= 0;

        endcase
    end

endmodule
