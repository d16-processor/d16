module sound(
    input clk,
    input rst,
    input en,
    input wr_en,
    input [15:0] data_in,
    output snd_out);
    wire snd1,snd2,snd3,snd4;
    reg [2:0] sigma1 = 0;

    
    assign snd_out = sigma1[2];
    reg [13:0] c1_divider = 0;
    reg [13:0] c2_divider = 0;
    reg [13:0] c3_divider = 0;
    reg [13:0] c4_divider = 0;
    always @(posedge clk) begin
        if(rst == 1) begin
            c1_divider <= 0;
            c2_divider <= 0;
            c3_divider <= 0;
            c4_divider <= 0;
        end
        else if(wr_en == 1)
            case(data_in[15:14])
                2'b00:
                    c1_divider <= data_in[13:0];
                2'b01:
                    c2_divider <= data_in[13:0];
                2'b10:
                    c3_divider <= data_in[13:0];
                2'b11:
                    c4_divider <= data_in[13:0];
            endcase
       sigma1 <= sigma1[1:0] + snd1+snd2+snd3+snd4;
       //sigma2 <= sigma2[1:0] + snd3+snd4;
    end
    channel channel1(
                     // Outputs
                     .snd               (snd1),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .divider           (c1_divider[13:0]));
    channel channel2(
                     // Outputs
                     .snd               (snd2),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .divider           (c2_divider[13:0]));

    channel channel3(
                     // Outputs
                     .snd               (snd3),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .divider           (c3_divider[13:0]));
    channel channel4(
                     // Outputs
                     .snd               (snd4),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .divider           (c4_divider[13:0]));

endmodule
module channel(
    input clk, 
    input rst,
    input [13:0] divider,
    output reg snd);    
    reg [18:0] counter;
    always @(posedge clk) begin
        if(rst == 1) begin
            snd <= 0;
            counter <= 0;
        end
        if(counter == 0) begin
            counter <= {divider,5'b0};
            if(divider != 0)
                snd <= ~snd;
        end
        else
            counter <= counter - 1;
    

    end
     
endmodule
