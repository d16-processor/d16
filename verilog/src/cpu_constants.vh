`define OPC_NOP 8'h00
`define OPC_ADD 8'h01
`define OPC_SUB 8'h02
`define OPC_PUSH 8'h03
`define OPC_POP 8'h04
`define OPC_MOVB_R0 8'h05
`define OPC_MOVB_R1 8'h06
`define OPC_MOVB_R2 8'h07
`define OPC_MOVB_R3 8'h08
`define OPC_MOVB_R4 8'h09
`define OPC_MOVB_R5 8'h0A
`define OPC_MOVB_R6 8'h0B
`define OPC_MOVB_R7 8'h0C
`define OPC_MOV 8'h0D
`define OPC_AND 8'h0E
`define OPC_OR 8'h0F
`define OPC_XOR 8'h10
`define OPC_NOT 8'h11
`define OPC_NEG 8'h12
`define OPC_LD 8'h13
`define OPC_ST 8'h14
`define OPC_CMP 8'h15
`define OPC_JMP 8'h16
`define OPC_CALL 8'h17
`define OPC_SPEC 8'h18
`define OPC_SHL 8'h19
`define OPC_SHR 8'h1A
`define OPC_ROL 8'h1B
`define OPC_RCL 8'h1C
`define OPC_LDCP 8'h1D
`define OPC_STCP 8'h1E
`define OPC_ADC 8'h1F
`define OPC_SBB 8'h20
`define OPC_SET 8'h21
`define OPC_TEST 8'h22
`define OPC_PUSHLR 8'h23
`define OPC_SAR 8'h24

`define OPC_ADDI 8'h81
`define OPC_SUBI 8'h82
`define OPC_PUSHI 8'h83
`define OPC_MOVI 8'h8D
`define OPC_ANDI 8'h8E
`define OPC_ORI 8'h8F
`define OPC_XORI 8'h90
`define OPC_LDI 8'h93
`define OPC_STI 8'h94
`define OPC_CMPI 8'h95
`define OPC_JMPI 8'h96
`define OPC_CALLI 8'h97
`define OPC_SHLI 8'h99
`define OPC_SHRI 8'h9A
`define OPC_ROLI 8'h9B
`define OPC_RCLI 8'h9C
`define OPC_ADCI 8'h9F
`define OPC_SBBI 8'hA0
`define OPC_TESTI 8'hA2
`define OPC_SARI 8'hA4

`define FLAG_BIT_ZERO 0
`define FLAG_BIT_CARRY 1
`define FLAG_BIT_SIGN 2
`define FLAG_BIT_OVERFLOW 3

`define CONDITION_NEVER 4'b0000
`define CONDITION_EQ 4'b0001
`define CONDITION_NE 4'b0010
`define CONDITION_OS 4'b0011
`define CONDITION_OC 4'b0100
`define CONDITION_HI 4'b0101
`define CONDITION_LS 4'b0110
`define CONDITION_P 4'b0111
`define CONDITION_N 4'b1000
`define CONDITION_CS 4'b1001
`define CONDITION_CC 4'b1010
`define CONDITION_GE 4'b1011
`define CONDITION_G 4'b1100
`define CONDITION_LE 4'b1101
`define CONDITION_L 4'b1110
`define CONDITION_ALWAYS 4'b1111

`define CONTROL_BIT_MAX 7

`define STATE_FETCH 8'b00000001
`define STATE_DECODE 8'b00000010
`define STATE_REG_READ 8'b00000100
`define STATE_ALU 8'b00001000
`define STATE_MEM 8'b00010000
`define STATE_REG_WR 8'b00100000
`define STATE_PC_DELAY 8'b01000000
`define STATE_BRANCH_DELAY 8'b10000000

`define BIT_FETCH 0
`define BIT_DECODE 1
`define BIT_REG_READ 2
`define BIT_ALU 3
`define BIT_MEM 4
`define BIT_REG_WR 5
`define BIT_PC_DELAY 6
`define BIT_BRANCH_DELAY 7

`define PC_NOP 2'b00
`define PC_INC 2'b01
`define PC_SET 2'b10
`define PC_RESET 2'b11

`define LED_WR_ADDR 16'hff00
`define UART_STATUS_ADDR 16'hff03
`define UART_DATA_ADDR 16'hff02
`define TIMER_DATA_ADDR 16'hff06
`define SOUND_DATA_ADDR 16'hff08

`define DMA_CONTROL_ADDR 16'hff0a
`define DMA_LOCAL_ADDR   16'hff0c
`define DMA_PERIPH_ADDR  16'hff0e
`define DMA_COUNT_ADDR   16'hff10



`ifdef FORMAL
`define COVER(x) cover(x);
`else

`define COVER
`endif
