library IEEE;
use IEEE.std_logic_1164.all;
package cpu_constants is
	constant OPC_NOP     : std_logic_vector(7 downto 0) := X"00";
	constant OPC_ADD     : std_logic_vector(7 downto 0) := X"01";
	constant OPC_SUB     : std_logic_vector(7 downto 0) := X"02";
	constant OPC_PUSH    : std_logic_vector(7 downto 0) := X"03";
	constant OPC_POP     : std_logic_vector(7 downto 0) := X"04";
	constant OPC_MOVB_R0 : std_logic_vector(7 downto 0) := X"05";
	constant OPC_MOVB_R1 : std_logic_vector(7 downto 0) := X"06";
	constant OPC_MOVB_R2 : std_logic_vector(7 downto 0) := X"07";
	constant OPC_MOVB_R3 : std_logic_vector(7 downto 0) := X"08";
	constant OPC_MOVB_R4 : std_logic_vector(7 downto 0) := X"09";
	constant OPC_MOVB_R5 : std_logic_vector(7 downto 0) := X"0A";
	constant OPC_MOVB_R6 : std_logic_vector(7 downto 0) := X"0B";
	constant OPC_MOVB_R7 : std_logic_vector(7 downto 0) := X"0C";
	constant OPC_MOV     : std_logic_vector(7 downto 0) := X"0D";
	constant OPC_AND     : std_logic_vector(7 downto 0) := X"0E";
	constant OPC_OR      : std_logic_vector(7 downto 0) := X"0F";
	constant OPC_XOR     : std_logic_vector(7 downto 0) := X"10";
	constant OPC_NOT     : std_logic_vector(7 downto 0) := X"11";
	constant OPC_NEG     : std_logic_vector(7 downto 0) := X"12";
	constant OPC_LD      : std_logic_vector(7 downto 0) := X"13";
	constant OPC_ST      : std_logic_vector(7 downto 0) := X"14";
	constant OPC_CMP     : std_logic_vector(7 downto 0) := X"15";
	constant OPC_JMP     : std_logic_vector(7 downto 0) := X"16";
	constant OPC_CALL    : std_logic_vector(7 downto 0) := X"17";
	constant OPC_SPEC    : std_logic_vector(7 downto 0) := X"18";
	constant OPC_SHL     : std_logic_vector(7 downto 0) := X"19";
	constant OPC_SHR     : std_logic_vector(7 downto 0) := X"1A";
	constant OPC_ROL     : std_logic_vector(7 downto 0) := X"1B";
	constant OPC_RCL     : std_logic_vector(7 downto 0) := X"1C";
	constant OPC_LDCP    : std_logic_vector(7 downto 0) := X"1D";
	constant OPC_STCP    : std_logic_vector(7 downto 0) := X"1E";

	constant FLAG_BIT_ZERO     : integer := 0;
	constant FLAG_BIT_CARRY    : integer := 1;
	constant FLAG_BIT_SIGN     : integer := 2;
	constant FLAG_BIT_OVERFLOW : integer := 3;

	constant CONDITION_EQ     : std_logic_vector(3 downto 0) := "0001";
	constant CONDITION_NE     : std_logic_vector(3 downto 0) := "0010";
	constant CONDITION_OS     : std_logic_vector(3 downto 0) := "0011";
	constant CONDITION_OC     : std_logic_vector(3 downto 0) := "0100";
	constant CONDITION_HI     : std_logic_vector(3 downto 0) := "0101";
	constant CONDITION_LS     : std_logic_vector(3 downto 0) := "0110";
	constant CONDITION_P      : std_logic_vector(3 downto 0) := "0111";
	constant CONDITION_N      : std_logic_vector(3 downto 0) := "1000";
	constant CONDITION_CS     : std_logic_vector(3 downto 0) := "1001";
	constant CONDITION_CC     : std_logic_vector(3 downto 0) := "1010";
	constant CONDITION_GE     : std_logic_vector(3 downto 0) := "1011";
	constant CONDITION_G      : std_logic_vector(3 downto 0) := "1100";
	constant CONDITION_LE     : std_logic_vector(3 downto 0) := "1101";
	constant CONDITION_L      : std_logic_vector(3 downto 0) := "1110";
	constant CONDITION_ALWAYS : std_logic_vector(3 downto 0) := "1111";

	
	constant CONTROL_BIT_MAX      : integer := 5;
	                                                                         
	constant STATE_FETCH    : std_logic_vector(CONTROL_BIT_MAX downto 0)  := "000001"; 
	constant STATE_DECODE   : std_logic_vector(CONTROL_BIT_MAX downto 0)  := "000010"; 
	constant STATE_REG_READ : std_logic_vector(CONTROL_BIT_MAX downto 0)  := "000100"; 
	constant STATE_ALU      : std_logic_vector(CONTROL_BIT_MAX downto 0)  := "001000"; 
	constant STATE_MEM      : std_logic_vector(CONTROL_BIT_MAX downto 0)  := "010000"; 
	constant STATE_REG_WR   : std_logic_vector(CONTROL_BIT_MAX downto 0)  := "100000";
	
	type e_pc_op is (NOP, INC,SET,RESET);
	 
end cpu_constants;                                                           