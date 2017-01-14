//deps: alu.v control.v mem.v pc_unit.v register_unit.v
`timescale 1ps/1ns
`include "cpu_constants.vh"
module core(input clk,input rst);
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [15:0]             SP_out;                 // From alu of alu.v
wire [`CONTROL_BIT_MAX:0] control_o;            // From control of control.v
wire [3:0]              flags_out;              // From alu of alu.v
wire [15:0]             mem_data;               // From alu of alu.v
wire [15:0]             out;                    // From alu of alu.v
wire                    should_branch;          // From alu of alu.v
wire                    write;                  // From alu of alu.v
// End of automatics
control control(/*AUTOINST*/
                // Outputs
                .control_o              (control_o[`CONTROL_BIT_MAX:0]),
                // Inputs
                .clk                    (clk),
                .en                     (en),
                .rst                    (rst),
                .en_mem                 (en_mem),
                .mem_wait               (mem_wait),
                .should_branch          (should_branch));
alu alu(/*AUTOINST*/
        // Outputs
        .should_branch                  (should_branch),
        .out                            (out[15:0]),
        .mem_data                       (mem_data[15:0]),
        .write                          (write),
        .flags_out                      (flags_out[3:0]),
        .SP_out                         (SP_out[15:0]),
        // Inputs
        .clk                            (clk),
        .en                             (en),
        .alu_control                    (alu_control[7:0]),
        .en_imm                         (en_imm),
        .rD_data                        (rD_data[15:0]),
        .rS_data                        (rS_data[15:0]),
        .immediate                      (immediate[15:0]),
        .condition                      (condition[3:0]),
        .flags_in                       (flags_in[3:0]),
        .mem_displacement               (mem_displacement));
decoder decoder(/*AUTOINST*/);
endmodule
