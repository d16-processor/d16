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
    output tx,
    output mem_wait);


    wire [15:0] real_addr;
    assign real_addr = {addr[14:0],byte_select};
    wire led_wr_en;
    wire [7:0] uart_data_out;
    wire [7:0] uart_status_out;
    wire uart_wr_en, uart_wait, uart_read;
leds leds(
          // Outputs
          .led_out                      (led_out[7:0]),
          // Inputs
          .clk                          (clk),
          .en                           (en),
          .rst                          (rst),
          .wr_en                        (led_wr_en),
          .data                         (data_in[15:0]));
uart_controller uart(
                     // Outputs
                     .data_out          (uart_data_out[7:0]),
                     .status_out        (uart_status_out[7:0]),
                     .tx                (tx),
                     .uart_wait         (uart_wait),
                     // Inputs
                     .rx                (rx),
                     .clk               (clk),
                     .en                (en),
                     .rst               (rst),
                     .wr_en             (uart_wr_en),
                     .read              (uart_read),
                     .data              (data_in[15:0]));
    assign led_wr_en = (real_addr == `LED_WR_ADDR) & write_enable;
    assign uart_wr_en = (real_addr == `UART_DATA_ADDR) & write_enable;
    assign uart_read = (real_addr == `UART_DATA_ADDR) & en & ~write_enable;
    assign mem_wait = uart_wait;
    always @(posedge clk)
        if(rst)
            serviced_read <= 0;
        else begin
            `COVER
            serviced_read <= en & ~write_enable & real_addr >= 16'hff00;
        end
    always @(posedge clk) begin
        if(rst)
            data_out <= 0;
        else
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
`ifdef FORMAL
    always @(posedge clk) 
        if($initstate) begin
            assume($past(rst) == 0);
            assume($past(en) == 1);
            assume($past(real_addr) == 0);
            assume($past(write_enable) == 0);
            assume($past(data_in[7:0]) == 0);
            assume(data_in[7:0] == 0);
            assume(led_out == 0);
            assume(en == 1);
            assume(write_enable == 0);
            assume(real_addr == 0);
        end
        else begin
            assume($past(en) == 1 && $past(rst) == 0);
            if($past(real_addr) == 16'hff00 && $past(write_enable) == 1) begin
                assert(led_out == $past(data_in[7:0]));
            end
        end
`endif

endmodule
