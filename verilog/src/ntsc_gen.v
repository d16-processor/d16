`timescale 1ns/1ps
module ntsc_gen(clk,v_sync,v_data);
parameter DATA_BITS = 2;
input clk;
output reg [DATA_BITS-1:0] v_data;
output v_sync;
wire [DATA_BITS-1:0] data;
//50 Mhz clock
reg [9:0] xpos = 0;
reg [8:0] ypos = 0;
reg [3:0] counter = 0;

reg [3:0] cburst_table[0:63];
reg [5:0] cburst_pointer = 0;
initial
    $readmemh("colorburst.hex",cburst_table);
always @(posedge clk) begin
    if(counter == 0)
        if(xpos == 635) begin
            xpos <= 0;
            if(ypos == 311)
                ypos <= 0;
            else
                ypos <= ypos + 1;
        end
        else
            xpos <= xpos + 1;

    if(counter == 4) 
        counter <= 0;
    else 
        counter <= counter + 1;
    if(cburst_pointer == 52)
        cburst_pointer <= 0;
    else 
        cburst_pointer <= cburst_pointer + 1;
end
wire active = xpos < 526 && ypos < 268;
wire hsync  = 541 <= xpos && xpos < 588 && ypos < 268;
wire vsync  = 276 <= ypos && ypos <= 279;
wire [3:0] colorburst = (cburst_table[cburst_pointer] >>2) +2;
wire colorburst_en = 598 <= xpos && xpos < 623 && ypos < 268;


assign data = active ? {xpos[6:5],2'b0} :0;
assign v_sync = active || !(hsync || vsync);
//assign v_data = ((data+v_sync) <= (1<<DATA_BITS) - 1) ? (data+v_sync) : 2'b11;
always @*
    if(colorburst_en && 0)
        v_data <= colorburst;
    else
        v_data <= data + (v_sync << 1) + 1;


endmodule

