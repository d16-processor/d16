//deps: register_unit.v
`timescale 1ns/1ps
module register_unit_tb;
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [15:0]             rD_data_out;            // From ru of register_unit.v
wire [15:0]             rS_data_out;            // From ru of register_unit.v
// End of automatics
/*AUTOREGINPUT*/
// Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
reg                     clk;                    // To ru of register_unit.v
reg                     en;                     // To ru of register_unit.v
reg [15:0]              rD_data_in;             // To ru of register_unit.v
reg [2:0]               rD_sel;                 // To ru of register_unit.v
reg [15:0]              rS_data_in;             // To ru of register_unit.v
reg [2:0]               rS_sel;                 // To ru of register_unit.v
reg                     rS_wr_en;               // To ru of register_unit.v
reg                     wr_en;                  // To ru of register_unit.v
// End of automatics
register_unit ru (/*AUTOINST*/
                  // Outputs
                  .rD_data_out          (rD_data_out[15:0]),
                  .rS_data_out          (rS_data_out[15:0]),
                  // Inputs
                  .clk                  (clk),
                  .en                   (en),
                  .wr_en                (wr_en),
                  .rS_wr_en             (rS_wr_en),
                  .rD_sel               (rD_sel[2:0]),
                  .rS_sel               (rS_sel[2:0]),
                  .rD_data_in           (rD_data_in[15:0]),
                  .rS_data_in           (rS_data_in[15:0]));
            
    initial begin
        clk <= 0;
        rD_sel <= 0;
        en <= 0;
        rS_sel <= 0;
        wr_en <= 0;
        rS_wr_en <= 0;
        rD_data_in <= 0;
        rS_data_in <= 0;
        $dumpfile("dump.vcd");
        $dumpvars;
    end
    always #5 clk <= ~clk;

    initial begin
        #20
            en <= 1;
            rD_sel <= 1;
            rD_data_in <= 16'hfeed;
            wr_en <= 1;
        #10
            rD_sel <= 0;
            rD_data_in <= 16'hbeef;
            wr_en <= 1;
        #10
            rD_sel <= 0;
            rS_sel <= 1;
            wr_en <= 0;
        #10
            $finish;
    end

endmodule
