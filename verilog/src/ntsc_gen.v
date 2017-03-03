`timescale 1ns/1ps
module ntsc_gen(clk,v_sync,v_data);
parameter DATA_BITS = 4;
input clk;
output reg [DATA_BITS-1:0] v_data;
output v_sync;
wire [DATA_BITS-1:0] data;
wire [DATA_BITS-1:0] sync;
//50 Mhz clock
reg [9:0] xpos = 0;
reg [8:0] ypos = 0;
reg [3:0] counter = 0;
reg [7:0] colorburst = 8'b01100100;

always @(posedge clk) begin
    colorburst <= {colorburst[5:0],colorburst[7:6]};
    if(xpos == 903) begin
        xpos <= 0;
        if(ypos == 261)
            ypos <= 0;
        else
            ypos <= ypos + 1;
    end
    else
        xpos <= xpos + 1;
end
wire active = xpos < 640 && ypos < 200;
wire hsync  = 717 <= xpos && xpos < 784;
wire vsync  = 224 <= ypos && ypos < 227;
wire burst  = 798 <= xpos && xpos < 834 ;


assign data = active ? {colorburst[5:4] + (ypos[5] ? colorburst[3:2] : colorburst[7:6]),2'b0} :0;
assign sync = (!(hsync || vsync)) ? 4'b0011 : 4'b0000;
assign v_sync = active || !(hsync || vsync);
//assign v_data = ((data+v_sync) <= (1<<DATA_BITS) - 1) ? (data+v_sync) : 2'b11;
always @*
    if(burst)
        v_data = colorburst[1:0] + sync - 1;
    else
        v_data <= data + sync;


endmodule

