// File ../../vhdl/src/alu.vhd translated with vhd2vl v2.5 VHDL to Verilog RTL translator
// vhd2vl settings:
//    * Verilog Module Declaration Style: 2001

// vhd2vl is Free (libre) Software:
//     Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//         http://www.ocean-logic.com
//     Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//     Modifications (C) 2010 Shankar Giri
//     Modifications Copyright (C) 2002, 2005, 2008-2010, 2015 Larry Doolittle - LBNL
//         http://doolittle.icarus.com/~larry/vhd2vl/
//
//     vhd2vl comes with ABSOLUTELY NO WARRANTY.    Always check the resulting
//     Verilog for correctness, ideally with a formal verification tool.
//
//     You are welcome to redistribute vhd2vl under certain conditions.
//     See the license (GPLv2) file included with the source for details.

// The result of translation follows.    Its copyright status should be
// considered unchanged from the original VHDL.

// no timescale needed
`include "cpu_constants.vh"
module alu(
input wire clk,
input wire en,
input wire [7:0] alu_control,
input wire en_imm,
input wire [15:0] rD_data,
input wire [15:0] rS_data,
input wire [15:0] immediate,
input wire [3:0] condition,
input wire [3:0] flags_in,
input wire mem_displacement,
output wire should_branch,
output wire [15:0] out,
output wire [15:0] mem_data,
output reg write,
output wire [3:0] flags_out,
output reg [15:0] SP_out
);


//nonblocking "variable" registers
reg [15:0] data1;
reg [15:0] data2;

reg [16:0] s_output = 0;
reg s_should_branch = 1'b 0;
reg s_data1_sign;
reg s_data2_sign;
wire [3:0] s_flags;
reg ov_op;
reg [15:0] s_mem_data;    //pure function get_should_branch(flags : std_logic_vector(3 downto 0); code : std_logic_vector(3 downto 0)) return std_logic is
//begin
//case code is
//when CONDITION_ALWAYS =>
//return '1';
//when CONDITION_EQ =>
//return flags(FLAG_BIT_ZERO);
//when CONDITION_NE =>
//return not flags(FLAG_BIT_ZERO);
//when CONDITION_OS =>
//return flags(FLAG_BIT_OVERFLOW);
//when CONDITION_OC =>
//return not flags(FLAG_BIT_OVERFLOW);
//when CONDITION_HI =>
//return flags(FLAG_BIT_CARRY) and (not flags(FLAG_BIT_ZERO));
//when CONDITION_LS =>
//return (not flags(FLAG_BIT_CARRY)) and flags(FLAG_BIT_ZERO);
//when CONDITION_P =>
//return not flags(FLAG_BIT_SIGN);
//when CONDITION_N =>
//return flags(FLAG_BIT_SIGN);
//when CONDITION_CS =>
//return flags(FLAG_BIT_CARRY);
//when CONDITION_CC =>
//return not flags(FLAG_BIT_CARRY);
//when CONDITION_G =>
//return not (flags(FLAG_BIT_SIGN) xor flags(FLAG_BIT_OVERFLOW));
//when CONDITION_GE =>
//return (not (flags(FLAG_BIT_SIGN) xor flags(FLAG_BIT_OVERFLOW))) and (not flags(FLAG_BIT_ZERO));
//when CONDITION_LE =>
//return (flags(FLAG_BIT_SIGN) xor flags(FLAG_BIT_OVERFLOW)) and (flags(FLAG_BIT_ZERO));
//when CONDITION_L =>
//return flags(FLAG_BIT_SIGN) xor flags(FLAG_BIT_OVERFLOW);
//when others =>
//return '0';
//end case;
//end function get_should_branch;

    assign out = s_output[15:0];
    assign should_branch = s_should_branch;
    assign s_flags[`FLAG_BIT_ZERO] = s_output[15:0] == 16'h 0000 ? 1'b 1 : 1'b 0;
    assign s_flags[`FLAG_BIT_CARRY] = s_output[16];
    assign s_flags[`FLAG_BIT_SIGN] = s_output[15];
    assign s_flags[`FLAG_BIT_OVERFLOW] = ov_op == 1'b 1 && s_data1_sign == s_data2_sign && s_data1_sign != s_output[15] ? 1'b 1 : 1'b 0;
    assign flags_out = s_flags;
    assign mem_data = s_mem_data;
    always @(posedge clk) begin
            //variable data1 : std_logic_vector(15 downto 0);
        //variable data2 : std_logic_vector(15 downto 0);
        if(en == 1'b 1) begin
            data1 = rD_data;
            if(en_imm == 1'b 1) begin
                data2 = immediate;
            end
            else begin
                data2 = rS_data;
            end
            case(alu_control)
                        //overflow signals
            `OPC_ADD,`OPC_SUB,`OPC_ADC,`OPC_SBB : begin
                ov_op <= 1'b 1;
            end
            default : begin
                ov_op <= 1'b 0;
            end
            endcase
            case(alu_control)
            `OPC_CMP : begin
                write <= 1'b 0;
            end
            `OPC_ST : begin
                write <= 1'b 0;
            end
            `OPC_JMP : begin
                write <= 1'b 0;
            end
            `OPC_PUSH : begin
                write <= 1'b 0;
            end
            default : begin
                write <= 1'b 1;
            end
            endcase
            case(alu_control)
            `OPC_JMP : begin
                s_should_branch <= get_should_branch(flags_in,condition);
            end
            default : begin
                s_should_branch <= 1'b 0;
            end
            endcase
            case(alu_control)
            `OPC_ADD : begin
                s_output <= ({data1[15],data1} + {data2[15],data2});
                s_data1_sign <= data1[15];
                s_data2_sign <= data2[15];
            end
            `OPC_SUB : begin
                s_output <= ({data1[15],data1} - {data2[15],data2});
                s_data1_sign <= data1[15];
                s_data2_sign <=    ~data2[15];
            end
            `OPC_ADC : begin
                s_output <= ({data1[15],data1} + {data2[15],data2} + {16'b 0,flags_in[`FLAG_BIT_CARRY]});
                s_data1_sign <= data1[15];
                s_data2_sign <= data2[15];
            end
            `OPC_SBB : begin
                s_output <= ({data1[15],data1} - {data2[15],data2} - {16'b 0,flags_in[`FLAG_BIT_CARRY]});
                s_data1_sign <= data1[15];
                s_data2_sign <=    ~data2[15];
            end
            `OPC_MOV : begin
                s_output[15:0] <= data2;
                s_output[16] <= 1'b 0;
            end
            `OPC_AND : begin
                s_output[15:0] <= data1 & data2;
                s_output[16] <= 1'b 0;
            end
            `OPC_OR : begin
                s_output[15:0] <= data1 | data2;
                s_output[16] <= 1'b 0;
            end
            `OPC_XOR : begin
                s_output[15:0] <= data1 ^ data2;
                s_output[16] <= 1'b 0;
            end
            `OPC_NOT : begin
                s_output[15:0] <=    ~data1;
                s_output[16] <= 1'b 0;
            end
            `OPC_NEG : begin
                s_output[15:0] <= ( -((data1)));
                s_output[16] <= 1'b 0;
            end
            `OPC_SHL : begin
                s_output <= {1'b0,data1} << data2; 
                //shift_left
            end
            `OPC_SHR : begin
                s_output <= {1'b0,data1} >> data2; 
                //shift_right
            end
            `OPC_ROL : begin
                s_output[15:0] <= 16'hbeef;
                //rol
                s_output[16] <= 1'b 0;
            end
            `OPC_RCL : begin
                s_output <= {1'b0,16'hbeef};
                // rcl
            end
            `OPC_CMP : begin
                s_output <= ({data1[15],data1} - {data2[15],data2});
                s_data1_sign <= data1[15];
                s_data2_sign <=    ~data2[15];
            end
            `OPC_JMP : begin
                if(en_imm == 1'b 1) begin
                    s_output <= {1'b 0,immediate};
                end
                else begin
                    s_output <= {1'b 0,data1};
                end
            end
            `OPC_ST : begin
                if(mem_displacement == 1'b 1) begin
                    s_output[15:0] <= (((rS_data)) + ((immediate)));
                end
                else begin
                    s_output[15:0] <= data2;
                end
                s_mem_data <= data1;
            end
            `OPC_LD : begin
                if(mem_displacement == 1'b 1) begin
                    s_output[15:0] <= (((rS_data)) + ((immediate)));
                end
                else begin
                    s_output[15:0] <= data2;
                end
            end
            `OPC_SET : begin
                s_output[15:0] <= {15'b000,get_should_branch(flags_in,condition)};
            end
            `OPC_PUSH : begin
                if(en_imm == 1'b 1) begin
                    s_mem_data <= immediate;
                end
                else begin
                    s_mem_data <= rD_data;
                end
                s_output[15:0] <= (((rS_data)) - 2);
                SP_out <= (((rS_data)) - 2);
            end
            `OPC_POP : begin
                s_output[15:0] <= rS_data;
                SP_out <= (((rS_data)) + 2);
            end
            default : begin
                s_output <= {1'b 0,16'h 0000};
            end
            endcase
        end
    end

    function get_should_branch;
    input [3:0] flags;
    input [3:0] code;
    case (code)
        `CONDITION_ALWAYS: get_should_branch = 1;
        `CONDITION_EQ: get_should_branch = flags[`FLAG_BIT_ZERO];
        `CONDITION_NE: get_should_branch = ~flags[`FLAG_BIT_ZERO];
        `CONDITION_OS: get_should_branch = flags[`FLAG_BIT_OVERFLOW];
        `CONDITION_OC: get_should_branch = ~flags[`FLAG_BIT_OVERFLOW];
        `CONDITION_HI: get_should_branch = flags[`FLAG_BIT_CARRY] & ~flags[`FLAG_BIT_ZERO];
        `CONDITION_LS: get_should_branch = ~flags[`FLAG_BIT_CARRY] & flags[`FLAG_BIT_ZERO];
        `CONDITION_P:  get_should_branch = ~flags[`FLAG_BIT_SIGN];
        `CONDITION_N:  get_should_branch = flags[`FLAG_BIT_SIGN];
        `CONDITION_CS: get_should_branch = flags[`FLAG_BIT_CARRY];
        `CONDITION_CC: get_should_branch = ~flags[`FLAG_BIT_CARRY];
        `CONDITION_G:  get_should_branch = 
            ~flags[`FLAG_BIT_SIGN] ^ flags[`FLAG_BIT_OVERFLOW];
        `CONDITION_GE: get_should_branch = 
            (~flags[`FLAG_BIT_SIGN] ^ flags[`FLAG_BIT_OVERFLOW]) & ~flags[`FLAG_BIT_ZERO];
        `CONDITION_LE: get_should_branch =
            (flags[`FLAG_BIT_SIGN] ^ flags[`FLAG_BIT_OVERFLOW]) & flags[`FLAG_BIT_ZERO];
        `CONDITION_L:  get_should_branch =
            flags[`FLAG_BIT_SIGN] ^ flags[`FLAG_BIT_OVERFLOW];
        default:       get_should_branch = 0;

    endcase;
    endfunction

endmodule
