//deps: mem.v
`timescale 1ns/1ps
module mem_tb;
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [15:0]             data_out;               // From mem of mem.v
wire                    mem_wait;               // From mem of mem.v
// End of automatics
/*AUTOREGINPUT*/
// Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
reg [15:0]              addr;                   // To mem of mem.v
reg                     byte_enable;            // To mem of mem.v
reg                     byte_select;            // To mem of mem.v
reg                     clk;                    // To mem of mem.v
reg [15:0]              data_in;                // To mem of mem.v
reg                     en;                     // To mem of mem.v
reg                     rst;                    // To mem of mem.v
reg                     write_enable;           // To mem of mem.v
// End of automatics
mem mem (/*AUTOINST*/
         // Outputs
         .data_out                      (data_out[15:0]),
         .mem_wait                      (mem_wait),
         // Inputs
         .clk                           (clk),
         .rst                           (rst),
         .en                            (en),
         .write_enable                  (write_enable),
         .byte_select                   (byte_select),
         .byte_enable                   (byte_enable),
         .addr                          (addr[15:0]),
         .data_in                       (data_in[15:0]));
     initial begin
         addr <= 0;
         byte_enable <=0;
         byte_select <= 0;
         clk <= 0;
         data_in <= 0;
         en <= 0;
         rst <= 0;
         write_enable <= 0;

         $dumpfile("dump.vcd");
         $dumpvars;
     end
     always #5 clk <= ~clk;
     integer i;
     initial begin
         #10 en <= 1;
         for(i=0;i<10;i=i+1)
            #10 addr <= addr + 1;
        data_in <= 16'hDDCC;
        addr <= 'h1c;
        write_enable <= 1;
        #10 write_enable <= 0;
        #40 $finish;
    end

endmodule
