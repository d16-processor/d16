//deps: control.v
`include "cpu_constants.vh"
module control_tb;
// Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
reg			clk;			// To uut of control.v
reg			en;			// To uut of control.v
reg			en_mem;			// To uut of control.v
reg			imm;			// To uut of control.v
reg			mem_wait;		// To uut of control.v
reg			rst;			// To uut of control.v
reg			should_branch;		// To uut of control.v
// End of automatics
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [`CONTROL_BIT_MAX:0] control_o;		// From uut of control.v
   wire [1:0]		pc_op;			// From uut of control.v
   // End of automatics

   control uut(/*AUTOINST*/
   	       // Outputs
   	       .control_o		(control_o[`CONTROL_BIT_MAX:0]),
   	       .pc_op			(pc_op[1:0]),
   	       // Inputs
   	       .clk			(clk),
   	       .en			(en),
   	       .rst			(rst),
   	       .en_mem			(en_mem),
   	       .mem_wait		(mem_wait),
   	       .should_branch		(should_branch),
   	       .imm			(imm));
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      clk = 0;
      rst = 1;
      en = 0;
      en_mem = 0;
      imm = 0;
      mem_wait = 0;
      should_branch = 0;
      #20 rst = 0;
      en = 1;
      #300 $finish;
   end // initial begin
   always #5 clk <= ~clk;
   always @(posedge clk) begin
      if(control_o[`BIT_ALU])
	en_mem <= ~en_mem;
      if(control_o[`BIT_REG_WR])
	 should_branch <= ~should_branch;
      if(control_o[`BIT_ALU])
	imm <= ~imm;
   end
   
endmodule // control_tb
