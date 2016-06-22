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
		should_branch : out std_logic;
		output        : out std_logic_vector(15 downto 0);
		write         : out std_logic
	);
end alu;
architecture behavior of alu is
	signal s_output        : std_logic_vector(16 downto 0) := (others => '0');
	signal s_should_branch : std_logic                     := '0';
	signal s_flags         : std_logic_vector(3 downto 0);
	signal s_data1_sign    : std_logic;
	signal s_data2_sign    : std_logic;

	signal ov_op : std_logic;
begin
	output                     <= s_output(15 downto 0);
	should_branch              <= s_should_branch;
	s_flags(FLAG_BIT_ZERO)     <= '1' when s_output(15 downto 0) = X"0000" else '0';
	s_flags(FLAG_BIT_CARRY)    <= s_output(16);
	s_flags(FLAG_BIT_SIGN)     <= s_output(15);
	s_flags(FLAG_BIT_OVERFLOW) <= '1' when ov_op = '1' and s_data1_sign = s_data2_sign and s_data1_sign /= s_output(15) else '0';
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
					when OPC_ADD =>
						ov_op <= '1';
					when OPC_SUB =>
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
						s_output  <= std_logic_vector(rotate_left(unsigned(s_flags(FLAG_BIT_CARRY) & data1), to_integer(unsigned(data2))));
					when OPC_CMP =>
						s_output     <= std_logic_vector(unsigned(data1(15) & data1) - unsigned(data2(15) & data2));
						s_data1_sign <= data1(15);
						s_data2_sign <= not data2(15);

					when others => s_output <= '0' & X"0000";
				end case;

			end if;
		end if;
	end process alu_proc;

end architecture behavior;





