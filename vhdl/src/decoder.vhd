library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

use work.cpu_constants.ALL;
entity decoder is
	port(
		clk          : in  std_logic;
		en           : in  std_logic;
		instruction  : in  std_logic_vector(15 downto 0);
		alu_control  : out std_logic_vector(7 downto 0);
		rD_sel       : out std_logic_vector(2 downto 0);
		rS_sel       : out std_logic_vector(2 downto 0);
		immediate    : out std_logic_vector(15 downto 0);
		en_immediate : out std_logic;
		next_word    : out std_logic;
		en_mem       : out std_logic;
		condition    : out std_logic_vector(3 downto 0)
	);

end decoder;
architecture behavior of decoder is
	signal s_alu_control : std_logic_vector(7 downto 0);
	signal s_rD_sel      : std_logic_vector(2 downto 0);
	signal s_rS_sel      : std_logic_vector(2 downto 0);
	signal s_immediate   : std_logic_vector(15 downto 0);
	signal s_en_imm      : std_logic;
	signal s_next_word   : std_logic;
	pure function get_should_branch (flags : std_logic_vector(3 downto 0); code : std_logic_vector(3 downto 0)) return std_logic is
begin
	case code is
	when CONDITION_ALWAYS  => 
		return '1';
	
	end case;
	return '1';
	end function get_should_branch;
	
begin
	alu_control  <= s_alu_control;
	rD_sel       <= s_rD_sel;
	rS_sel       <= s_rS_sel;
	immediate    <= s_immediate;
	en_immediate <= s_en_imm;
	next_word    <= s_next_word;
	
	process(clk, en)
		variable opcode : std_logic_vector(7 downto 0);

	begin
		if rising_edge(clk) and en = '1' then
			opcode := instruction(15 downto 8);
			if unsigned(opcode) <= unsigned(OPC_MOVB_R7) and unsigned(opcode) >= unsigned(OPC_MOVB_R0) then
				s_en_imm      <= '1';
				s_alu_control <= OPC_MOV;
				s_next_word   <= '0';

				s_immediate <= X"00" & instruction(7 downto 0);
				case instruction(15 downto 8) is
					when OPC_MOVB_R0 =>
						s_rD_sel <= "000";
					when OPC_MOVB_R1 =>
						s_rD_sel <= "001";
					when OPC_MOVB_R2 =>
						s_rD_sel <= "010";
					when OPC_MOVB_R3 =>
						s_rD_sel <= "011";
					when OPC_MOVB_R4 =>
						s_rD_sel <= "100";
					when OPC_MOVB_R5 =>
						s_rD_sel <= "101";
					when OPC_MOVB_R6 =>
						s_rD_sel <= "110";
					when OPC_MOVB_R7 =>
						s_rD_sel <= "111";
					when others =>
				end case;
			else
				s_alu_control <= '0' & opcode(6 downto 0);
				s_en_imm      <= instruction(15);
				s_next_word   <= instruction(15);
				s_rD_sel      <= instruction(2 downto 0);
				s_rS_sel      <= instruction(5 downto 3);
				s_immediate   <= X"0000";
			end if;
			if opcode = OPC_ST or opcode = OPC_LD then
				en_mem  <= '1';
			else
				en_mem  <= '0';
			end if;
			if opcode = OPC_JMP then
				condition  <= instruction(6 downto 3);
			else 
				condition  <= "0000";
			end if;

		end if;
	end process;
	
end behavior;

	