//deps: fifo.v, uart.v
`timescale 1ns/1ps
module uart_controller(
    input rx,
    input clk,
    input en,
    input rst,
    input wr_en,
    input read,
    input [15:0] data,
    output [7:0] data_out,
    output reg [7:0] status_out = 0,
    output tx,
    output reg uart_wait = 0);
    parameter FIFO_WIDTH = 8;
    parameter CLOCK_FREQUENCY = 50_000_000;
    parameter BAUD_RATE = 5000000;
    /*AUTOWIRE*/
    wire                empty;                  // From tx_fifo of fifo.v, ...
    wire                full;                   // From tx_fifo of fifo.v, ...
    wire [FIFO_WIDTH-1:0] output_data;          // From tx_fifo of fifo.v, ...
    wire [7:0] rx_input;
    reg [7:0] tx_input = 0;
    wire [7:0] tx_output;
    wire [7:0] rx_output;
    reg tx_rd = 0,tx_wr = 0,rx_rd = 0,rx_wr = 0,transmit = 0;
    wire tx_empty, tx_full, rx_empty, rx_full;
    wire received, is_receiving, recv_error, is_transmitting;
    fifo tx_fifo(
                 // Outputs
                 .output_data           (tx_output[FIFO_WIDTH-1:0]),
                 .empty                 (tx_empty),
                 .full                  (tx_full),
                 // Inputs
                 .clk                   (clk),
                 .rst                   (rst),
                 .rd                    (tx_rd),
                 .wr                    (tx_wr),
                 .input_data            (tx_input[FIFO_WIDTH-1:0]));
    fifo rx_fifo(
                 // Outputs
                 .output_data           (data_out[FIFO_WIDTH-1:0]),
                 .empty                 (rx_empty),
                 .full                  (rx_full),
                 // Inputs
                 .clk                   (clk),
                 .rst                   (rst),
                 .rd                    (rx_rd),
                 .wr                    (rx_wr),
                 .input_data            (rx_input[FIFO_WIDTH-1:0]));
    uart #(
        .CLOCK_DIVIDE(CLOCK_FREQUENCY/(BAUD_RATE*4))) uart(
              // Outputs
              .tx                       (tx),
              .received                 (received),
              .rx_byte                  (rx_input[7:0]),
              .is_receiving             (is_receiving),
              .is_transmitting          (is_transmitting),
              .recv_error               (recv_error),
              // Inputs
              .clk                      (clk),
              .rst                      (rst),
              .rx                       (rx),
              .transmit                 (transmit),
              .tx_byte                  (tx_output));
    always @(posedge clk) begin
        if(rst == 1) begin
            status_out <= 0;
            /*AUTORESET*/
            // Beginning of autoreset for uninitialized flops
            tx_input <= 8'h0;
            tx_wr <= 1'h0;
            uart_wait <= 0;
            // End of automatics
        end
        else begin
            status_out[0] <= !tx_full;
            status_out[1] <= tx_empty;
            status_out[2] <= !rx_empty;
            status_out[3] <= 0;
            //CPU side
            //TX 
            if(wr_en == 1) begin
                if(!tx_full) begin
                    tx_input <= data[7:0];
                    tx_wr <= 1;
                    uart_wait <= 0;
                end
                else
                    uart_wait <= 1;
            end
            if(tx_wr == 1)
                tx_wr <= 0;
            if(read)
                rx_rd <= 1;
            if(rx_rd == 1)
                rx_rd <= 0;
            //UART side
            //TX 
            if(tx_empty == 0 && is_transmitting == 0)
                tx_rd <= 1;
            if(tx_rd == 1) begin
                tx_rd <= 0;
                transmit <= 1;
            end
            if(transmit == 1)
                transmit <= 0;
            //RX
            if(received) 
                rx_wr <= 1;
            if(rx_wr)
                rx_wr <= 0;

            

        end
    end
endmodule
