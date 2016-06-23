library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_constants.all;
entity alu is
	port(
		clk           : in  std_logic;
		en            : in  std_logic;
		alu_control   : in  std_logic_vector(7 downto 0);
		en_imm        : in  std_logic;
		rD_data       : in  std_logic_vector(15 downto 0);
		rS_data       : in  std_logic_vector(15 downto 0);
		immediate     : in  std_logic_vector(15 downto 0);
		condition     : in  std_logic_vector(3 downto 0);
		flags_in      : in  std_logic_vector(3 downto 0);
		should_branch : out std_logic;
		output        : out std_logic_vector(15 downto 0);
		write         : out std_logic;
		flags_out     : out std_logic_vector(3 downto 0)
	);
end alu;
architecture behavior of alu is
	signal s_output        : std_logic_vector(16 downto 0) := (others => '0');
	signal s_should_branch : std_logic                     := '0';

	signal s_data1_sign : std_logic;
	signal s_data2_sign : std_logic;
	signal s_flags      : std_logic_vector(3 downto 0);
	signal ov_op        : std_logic;
	pure function get_should_branch(flags : std_logic_vector(3 downto 0); code : std_logic_vector(3 downto 0)) return std_logic is
	begin
		case code is
			when CONDITION_ALWAYS =>
				return '1';
			when CONDITION_EQ =>
				return flags(FLAG_BIT_ZERO);
			when CONDITION_NE =>
				return not flags(FLAG_BIT_ZERO);
			when CONDITION_OS =>
				return flags(FLAG_BIT_OVERFLOW);
			when CONDITION_OC =>
				return not flags(FLAG_BIT_OVERFLOW);
			when CONDITION_HI =>
				return flags(FLAG_BIT_CARRY) and (not flags(FLAG_BIT_ZERO));
			when CONDITION_LS =>
				return (not flags(FLAG_BIT_CARRY)) and flags(FLAG_BIT_ZERO);
			when CONDITION_P =>
				return not flags(FLAG_BIT_SIGN);
			when CONDITION_N =>
				return flags(FLAG_BIT_SIGN);
			when CONDITION_CS =>
				return flags(FLAG_BIT_CARRY);
			when CONDITION_CC =>
				return not flags(FLAG_BIT_CARRY);
			when CONDITION_G =>
				return not (flags(FLAG_BIT_SIGN) xor flags(FLAG_BIT_OVERFLOW));
			when CONDITION_GE =>
				return (not (flags(FLAG_BIT_SIGN) xor flags(FLAG_BIT_OVERFLOW))) and (not flags(FLAG_BIT_ZERO));
			when CONDITION_LE =>
				return (flags(FLAG_BIT_SIGN) xor flags(FLAG_BIT_OVERFLOW)) and (flags(FLAG_BIT_ZERO));
			when CONDITION_L =>
				return flags(FLAG_BIT_SIGN) xor flags(FLAG_BIT_OVERFLOW);

			when others =>
				return '0';
		end case;

	end function get_should_branch;
begin
	output                     <= s_output(15 downto 0);
	should_branch              <= s_should_branch;
	s_flags(FLAG_BIT_ZERO)     <= '1' when s_output(15 downto 0) = X"0000" else '0';
	s_flags(FLAG_BIT_CARRY)    <= s_output(16);
	s_flags(FLAG_BIT_SIGN)     <= s_output(15);
	s_flags(FLAG_BIT_OVERFLOW) <= '1' when ov_op = '1' and s_data1_sign = s_data2_sign and s_data1_sign /= s_output(15) else '0';
	flags_out                  <= s_flags;
	alu_proc : process(clk) is
		variable data1 : std_logic_vector(15 downto 0);
		variable data2 : std_logic_vector(15 downto 0);
	begin
		if rising_edge(clk) then
			if en = '1' then
				data1 := rD_data;
				if en_imm = '1' then
					data2 := immediate;
				else
					data2 := rS_data;
				end if;
				case alu_control is     --overflow signals
					when OPC_ADD | OPC_SUB | OPC_ADC | OPC_SBB =>
						ov_op <= '1';
					when others =>
						ov_op <= '0';
				end case;
				case alu_control is
					when OPC_CMP =>
						write <= '0';
					when others =>
						write <= '1';
				end case;
				case alu_control is
					when OPC_ADD =>
						s_output     <= std_logic_vector(unsigned(data1(15) & data1) + unsigned(data2(15) & data2));
						s_data1_sign <= data1(15);
						s_data2_sign <= data2(15);

					when OPC_SUB =>
						s_output     <= std_logic_vector(unsigned(data1(15) & data1) - unsigned(data2(15) & data2));
						s_data1_sign <= data1(15);
						s_data2_sign <= not data2(15);
					when OPC_ADC =>
						s_output     <= std_logic_vector(unsigned(data1(15) & data1) + unsigned(data2(15) & data2) + ('0' & flags_in(FLAG_BIT_CARRY)));
						s_data1_sign <= data1(15);
						s_data2_sign <= data2(15);
					when OPC_SBB =>
						s_output     <= std_logic_vector(unsigned(data1(15) & data1) - unsigned(data2(15) & data2) - ('0' & flags_in(FLAG_BIT_CARRY)));
						s_data1_sign <= data1(15);
						s_data2_sign <= not data2(15);
					when OPC_MOV =>
						s_output(15 downto 0) <= data2;
						s_output(16)          <= '0';
					when OPC_AND =>
						s_output(15 downto 0) <= data1 and data2;
						s_output(16)          <= '0';
					when OPC_OR =>
						s_output(15 downto 0) <= data1 or data2;
						s_output(16)          <= '0';
					when OPC_XOR =>
						s_output(15 downto 0) <= data1 xor data2;
						s_output(16)          <= '0';
					when OPC_NOT =>
						s_output(15 downto 0) <= not data1;
						s_output(16)          <= '0';
					when OPC_NEG =>
						s_output(15 downto 0) <= std_logic_vector(-signed(data1));
						s_output(16)          <= '0';
					when OPC_SHL =>
						s_output <= std_logic_vector(shift_left(unsigned('0' & data1), to_integer(unsigned(data2))));
					when OPC_SHR =>
						s_output <= std_logic_vector(shift_right(unsigned('0' & data1), to_integer(unsigned(data2))));
					when OPC_ROL =>
						s_output(15 downto 0) <= std_logic_vector(rotate_left(unsigned(data1), to_integer(unsigned(data2))));
						s_output(16)          <= '0';
					when OPC_RCL =>
						s_output <= std_logic_vector(rotate_left(unsigned(flags_in(FLAG_BIT_CARRY) & data1), to_integer(unsigned(data2))));
					when OPC_CMP =>
						s_output     <= std_logic_vector(unsigned(data1(15) & data1) - unsigned(data2(15) & data2));
						s_data1_sign <= data1(15);
						s_data2_sign <= not data2(15);
					when OPC_JMP =>
						s_output      <= '0' & data1;
						should_branch <= get_should_branch(flags_in, condition);

					when others => s_output <= '0' & X"0000";
				end case;

			end if;
		end if;
	end process alu_proc;

end architecture behavior;





