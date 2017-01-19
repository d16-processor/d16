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
`timescale 1ns/1ps
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
output reg [15:0] SP_out,
output wire lr_wr_en
);


//nonblocking "variable" registers
wire [15:0] data1;
wire [15:0] data2;

reg [16:0] s_output = 0;
reg s_should_branch = 1'b 0;
reg s_data1_sign;
reg s_data2_sign;
reg s_lr_wr_en = 0;
wire [3:0] s_flags;
reg ov_op;
reg [15:0] s_mem_data;    
    assign data1 = rD_data;
    assign data2 = en_imm ? immediate : rS_data;
    assign out = s_output[15:0];
    assign should_branch = s_should_branch;
    assign s_flags[`FLAG_BIT_ZERO] = s_output[15:0] == 16'h 0000 ? 1'b 1 : 1'b 0;
    assign s_flags[`FLAG_BIT_CARRY] = s_output[16];
    assign s_flags[`FLAG_BIT_SIGN] = s_output[15];
    assign s_flags[`FLAG_BIT_OVERFLOW] = ov_op == 1'b 1 && s_data1_sign == s_data2_sign && s_data1_sign != s_output[15] ? 1'b 1 : 1'b 0;
    assign flags_out = s_flags;
    assign mem_data = s_mem_data;
    assign lr_wr_en = s_lr_wr_en;
    always @(posedge clk) begin
            //variable data1 : std_logic_vector(15 downto 0);
        //variable data2 : std_logic_vector(15 downto 0);
        if(en == 1'b 1) begin
            //data1 = rD_data;
            //if(en_imm == 1'b 1) begin
                //data2 = immediate;
            //end
            //else begin
                //data2 = rS_data;
            //end
            case(alu_control)
                        //overflow signals
            `OPC_ADD,`OPC_SUB,`OPC_ADC,`OPC_SBB,`OPC_CMP : begin
                ov_op <= 1'b 1;
            end
            default : begin
                ov_op <= 1'b 0;
            end
            endcase
            case(alu_control)
            `OPC_CMP, `OPC_TEST, `OPC_ST, `OPC_JMP, `OPC_PUSH, `OPC_CALL: begin
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
            `OPC_CALL : begin
                if(get_should_branch(flags_in, condition) == 1) begin
                    s_should_branch <= 1;
                    s_lr_wr_en <= 1;
                end
                else begin
                    s_should_branch <= 0;
                    s_lr_wr_en <= 0;
                end
            end
            `OPC_SPEC: begin
                s_should_branch <= 1;
            end
            default : begin
                s_should_branch <= 1'b 0;
                s_lr_wr_en <= 0;
            end
            endcase
            case(alu_control)
            `OPC_ADD : begin
                s_output <= (data1 + data2);
                s_data1_sign <= data1[15];
                s_data2_sign <= data2[15];
            end
            `OPC_SUB : begin
                s_output <= (data1 - data2);
                s_data1_sign <= data1[15];
                s_data2_sign <=    ~data2[15];
            end
            `OPC_ADC : begin
                s_output <= (data1 + data2 + {15'b 0,flags_in[`FLAG_BIT_CARRY]});
                s_data1_sign <= data1[15];
                s_data2_sign <= data2[15];
            end
            `OPC_SBB : begin
                s_output <= (data1 - data2 - {15'b 0,flags_in[`FLAG_BIT_CARRY]});
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
                s_output[15:0] <=  -data1;
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
            `OPC_SAR : begin
                s_output[15:0] <= $signed(data1) >>> $unsigned(data2[3:0]); 
                s_output[16] <= 0;
            end
            `OPC_ROL : begin
                s_output[15:0] <= {data1,data1} >> (16-data2[3:0]);
                //rol
                s_output[16] <= 1'b 0;
            end
            `OPC_RCL : begin
                s_output <= {1'b0,16'hbeef};
                // rcl
            end
            `OPC_CMP : begin
                s_output <= (data1 - data2);
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
            `OPC_CALL : begin
                if(en_imm == 1'b1) 
                    s_output <= {1'b0, immediate};
                else
                    s_output <= {1'b0, data1};
            end
            `OPC_SPEC: begin
                s_output <= {1'b0,immediate}; // immediate is link register
            end
            `OPC_ST : begin
                if(mem_displacement == 1'b 1) begin
                    s_output[15:0] <= rS_data + immediate;
                end
                else begin
                    s_output[15:0] <= data2;
                end
                s_mem_data <= data1;
            end
            `OPC_LD : begin
                if(mem_displacement == 1'b 1) 
                    s_output[15:0] <= rS_data + immediate;
                else 
                    s_output[15:0] <= data2;
            end
            `OPC_SET : begin
                s_output[16:0] <= {16'b000,get_should_branch(flags_in,condition)};
            end
            `OPC_TEST: begin
                s_output[15:0] <= data1 & data2;
                s_output[16] <= 0;
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
`ifdef FORMAL
    reg [7:0] opc_prev = 0;
    reg [15:0] data1_prev;
    reg [15:0] data2_prev;
    reg [15:0] rS_data_prev = 0;
    reg [3:0] flags_prev = 0;
    reg [3:0] cond_prev = 0;
    reg mem_disp_prev = 0;
    reg en_imm_prev = 0;
    restrict property(en == 1);
    always @* begin
        assert(data1 == rD_data);
        if(en_imm == 1) begin
            assert(data2 == immediate);
        end
        else begin
            assert(data2 == rS_data);
        end
    end
    always @(posedge clk) begin
        assert(flags_out[`FLAG_BIT_SIGN] == s_output[15]);
        assert(flags_out[`FLAG_BIT_ZERO] == (s_output[15:0] == 0));
        if(en == 1) begin
            opc_prev <= alu_control;
            data1_prev <= data1;
            data2_prev <= data2;
            rS_data_prev <= rS_data;
            flags_prev <= flags_in;
            cond_prev <= condition;
            mem_disp_prev <= mem_displacement;
            en_imm_prev <= en_imm;
        end
        if(opc_prev == `OPC_ADD) begin
            assert(s_output[15:0] == (data1_prev+data2_prev) & 'hffff);
            assert(flags_out[`FLAG_BIT_CARRY] == 
                $unsigned({1'b0,data1_prev} + {1'b0,data2_prev}) > 17'hffff);
            assert(flags_out[`FLAG_BIT_OVERFLOW] == ( 
                (data1_prev[15] == data2_prev[15]) && 
                (s_output[15] != data1_prev[15])));
        end
        if(opc_prev == `OPC_SUB) begin
            assert(s_output[15:0] == (data1_prev - data2_prev) & 'hffff);
            assert(flags_out[`FLAG_BIT_CARRY] == 
                $unsigned({1'b0,data1_prev} - {1'b0,data2_prev}) > 17'hffff);
            assert(flags_out[`FLAG_BIT_OVERFLOW] == ( 
                (data1_prev[15] == ~data2_prev[15]) && 
                (s_output[15] != data1_prev[15])));
        end
        if(opc_prev == `OPC_AND) begin
            assert(s_output[15:0] == (data1_prev[15:0] & data2_prev[15:0]) & 'hffff);
            assert(s_output[16] == 0);
            assert(flags_out[`FLAG_BIT_CARRY] == 0);
            assert(flags_out[`FLAG_BIT_OVERFLOW] == 0);
        end
        if(opc_prev == `OPC_OR) begin
            assert(s_output[15:0] == (data1_prev[15:0] | data2_prev[15:0]) & 'hffff);
            assert(s_output[16] == 0);
        end
        if(opc_prev == `OPC_XOR) begin
            assert(s_output[15:0] == (data1_prev[15:0] ^ data2_prev[15:0]) & 'hffff);
            assert(s_output[16] == 0);
        end
        if(opc_prev == `OPC_NOT) begin
            assert(s_output[15:0] == (~data1_prev[15:0]));
            assert(s_output[16] == 0);
        end
        if(opc_prev == `OPC_NEG) begin
            assert(s_output[15:0] == -data1_prev[15:0]);
        end
        if(opc_prev == `OPC_SHL) begin
            assert(s_output[16:0] == {1'b0,data1_prev[15:0]} << data2_prev);
            assert(flags_out[`FLAG_BIT_CARRY] == s_output[16]);
        end
        if(opc_prev == `OPC_SHR) begin
            assert(s_output[16:0] == {1'b0,data1_prev[15:0]} >> data2_prev);
            assert(flags_out[`FLAG_BIT_CARRY] == s_output[16]);
            assert(flags_out[`FLAG_BIT_OVERFLOW] == 0);
        end
        if(opc_prev == `OPC_ADC) begin
            assert(s_output[15:0] == (data1_prev+data2_prev + flags_prev[`FLAG_BIT_CARRY]) & 'hffff);
            assert(flags_out[`FLAG_BIT_CARRY] == 
                $unsigned({1'b0,data1_prev} + {1'b0,data2_prev} + 
                    flags_prev[`FLAG_BIT_CARRY]) > 17'hffff);
            assert(flags_out[`FLAG_BIT_OVERFLOW] == ( 
                (data1_prev[15] == data2_prev[15]) && 
                (s_output[15] != data1_prev[15])));
        end
        if(opc_prev == `OPC_SBB) begin
            assert(s_output[15:0] == (data1_prev-data2_prev - flags_prev[`FLAG_BIT_CARRY]) & 'hffff);
            assert(flags_out[`FLAG_BIT_CARRY] == 
                $unsigned({1'b0,data1_prev} - {1'b0,data2_prev} - 
                    flags_prev[`FLAG_BIT_CARRY]) > 17'hffff);
            assert(flags_out[`FLAG_BIT_OVERFLOW] == ( 
                (data1_prev[15] == ~data2_prev[15]) && 
                (s_output[15] != data1_prev[15])));
        end
        if(opc_prev == `OPC_CMP) begin
            assert(s_output[15:0] == (data1_prev - data2_prev) & 16'hffff);
            assert(write == 0);
            assert(flags_out[`FLAG_BIT_CARRY] == 
                $unsigned({1'b0,data1_prev} - {1'b0,data2_prev}) > 17'hffff);
            assert(flags_out[`FLAG_BIT_OVERFLOW] == ( 
                (data1_prev[15] == ~data2_prev[15]) && 
                (s_output[15] != data1_prev[15])));
        end
        if(opc_prev == `OPC_TEST) begin
            assert(s_output[15:0] == (data1_prev & data2_prev) & 16'hffff);
            assert(write == 0);
            assert(flags_out[`FLAG_BIT_CARRY] == 0);
            assert(flags_out[`FLAG_BIT_OVERFLOW] == 0);
        end
        if(opc_prev == `OPC_SAR) begin
            assume(data2_prev[15:4] == 0);
            assert($signed(s_output[15:0]) == $signed(($signed(data1_prev) >>> data2_prev[3:0])));
            assert(flags_out[`FLAG_BIT_CARRY] == 0);
            assert(flags_out[`FLAG_BIT_OVERFLOW] == 0);
            if(data2_prev[3:0] == 1)
                assert(s_output[15:0] == {data1_prev[15],data1_prev[15:1]});
            if(data2_prev[3:0] == 2)
                assert(s_output[15:0] == {data1_prev[15],data1_prev[15],data1_prev[15:2]});
        end
        if(opc_prev == `OPC_SET) begin
            assert(s_output[0] == get_should_branch(flags_prev, cond_prev));
            assert(s_output[16:1] == 0);
            assert(flags_out[`FLAG_BIT_CARRY] == 0);
            assert(flags_out[`FLAG_BIT_OVERFLOW] == 0);
        end
        if(opc_prev == `OPC_JMP) begin
            if(en_imm_prev == 0)
                assert(s_output == data1_prev);
            else
                assert(s_output == data2_prev);
            assert(s_should_branch == get_should_branch(flags_prev,cond_prev));
            assert(write == 0);
        end
        if(opc_prev == `OPC_CALL) begin
            if(en_imm_prev == 0)
                assert(s_output == data1_prev);
            else
                assert(s_output == data2_prev);
            assert(s_should_branch == get_should_branch(flags_prev,cond_prev));
            assert(s_lr_wr_en == get_should_branch(flags_prev,cond_prev));
            assert(write == 0);
        end
        if(opc_prev == `OPC_LD) begin
            if(mem_disp_prev == 1) begin
                assume(en_imm_prev == 1);
                assert(s_output[15:0] == (data2_prev + rS_data_prev) & 16'hffff);
            end
            else
                assert(s_output[15:0] == data2_prev[15:0]);
        end
        if(opc_prev == `OPC_ST) begin
            if(mem_disp_prev == 1) begin
                assume(en_imm_prev == 1);
                assert(s_output[15:0] == (data2_prev + rS_data_prev) & 16'hffff);
            end
            else
                assert(s_output[15:0] == data2_prev[15:0]);
            assert(s_mem_data == data1_prev);
            assert(write == 0);
        end

    end
    reg [3:0] tflags;
    // bit 3210
    // fl  VNCZ
    // taken directly from https://www.community.arm.com/processors/b/blog/posts/condition-codes-1-condition-flags-and-codes
    // And I forgot that ARM's carry is cleared when there is a subtraction
    // with borrow. Whoops
    assert property(get_should_branch(tflags, `CONDITION_ALWAYS) == 1);
    assert property(get_should_branch(tflags, `CONDITION_NEVER) == 0);
    assert property(get_should_branch(tflags, `CONDITION_EQ) == tflags[`FLAG_BIT_ZERO]);
    assert property(get_should_branch(tflags, `CONDITION_NE) == !tflags[`FLAG_BIT_ZERO]);
    assert property(get_should_branch(tflags, `CONDITION_CS) == tflags[`FLAG_BIT_CARRY]);
    assert property(get_should_branch(tflags, `CONDITION_CC) == !tflags[`FLAG_BIT_CARRY]);
    assert property(get_should_branch(tflags, `CONDITION_OS) == tflags[`FLAG_BIT_OVERFLOW]);
    assert property(get_should_branch(tflags, `CONDITION_OC) == !tflags[`FLAG_BIT_OVERFLOW]);
    assert property(get_should_branch(tflags, `CONDITION_P) == !tflags[`FLAG_BIT_SIGN]);
    assert property(get_should_branch(tflags, `CONDITION_N) == tflags[`FLAG_BIT_SIGN]);
    assert property(get_should_branch(tflags, `CONDITION_HI) == 
        ((tflags[`FLAG_BIT_CARRY] == 0) && (tflags[`FLAG_BIT_ZERO] == 0)));
    assert property(get_should_branch(tflags, `CONDITION_LS) == 
        ((tflags[`FLAG_BIT_CARRY] == 1) || (tflags[`FLAG_BIT_ZERO] == 1)));
    assert property(get_should_branch(tflags, `CONDITION_GE) ==
        (tflags[`FLAG_BIT_SIGN] == tflags[`FLAG_BIT_OVERFLOW]));
    assert property(get_should_branch(tflags, `CONDITION_L) ==
        (tflags[`FLAG_BIT_SIGN] != tflags[`FLAG_BIT_OVERFLOW]));
    assert property(get_should_branch(tflags, `CONDITION_G) ==
        (tflags[`FLAG_BIT_ZERO] == 0 && (tflags[`FLAG_BIT_SIGN] == tflags[`FLAG_BIT_OVERFLOW])));
    assert property(get_should_branch(tflags, `CONDITION_LE) ==
        (tflags[`FLAG_BIT_ZERO] == 1 || (tflags[`FLAG_BIT_SIGN] != tflags[`FLAG_BIT_OVERFLOW])));
`endif
    function get_should_branch;
    input [3:0] flags;
    input [3:0] code;
    begin
    case (code)
        `CONDITION_ALWAYS: get_should_branch = 1;
        `CONDITION_EQ: get_should_branch = flags[`FLAG_BIT_ZERO];
        `CONDITION_NE: get_should_branch = ~flags[`FLAG_BIT_ZERO];
        `CONDITION_OS: get_should_branch = flags[`FLAG_BIT_OVERFLOW];
        `CONDITION_OC: get_should_branch = ~flags[`FLAG_BIT_OVERFLOW];
        `CONDITION_HI: get_should_branch = ~flags[`FLAG_BIT_CARRY] & ~flags[`FLAG_BIT_ZERO];
        `CONDITION_LS: get_should_branch = flags[`FLAG_BIT_CARRY] | flags[`FLAG_BIT_ZERO];
        `CONDITION_P:  get_should_branch = ~flags[`FLAG_BIT_SIGN];
        `CONDITION_N:  get_should_branch = flags[`FLAG_BIT_SIGN];
        `CONDITION_CS: get_should_branch = flags[`FLAG_BIT_CARRY];
        `CONDITION_CC: get_should_branch = ~flags[`FLAG_BIT_CARRY];
        `CONDITION_GE:  get_should_branch = 
            ~flags[`FLAG_BIT_SIGN] ^ flags[`FLAG_BIT_OVERFLOW];
        `CONDITION_G: get_should_branch = 
            (~flags[`FLAG_BIT_SIGN] ^ flags[`FLAG_BIT_OVERFLOW]) & ~flags[`FLAG_BIT_ZERO];
        `CONDITION_LE: get_should_branch =
            (flags[`FLAG_BIT_SIGN] ^ flags[`FLAG_BIT_OVERFLOW]) | flags[`FLAG_BIT_ZERO];
        `CONDITION_L:  get_should_branch =
            flags[`FLAG_BIT_SIGN] ^ flags[`FLAG_BIT_OVERFLOW];
        default:       get_should_branch = 0;

    endcase
    end
    endfunction

endmodule
