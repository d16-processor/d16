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
		output        : out std_logic_vector(15 downto 0)
	);
end alu;
architecture behavior of alu is
	signal s_output        : std_logic_vector(16 downto 0) := (others => '0');
	signal s_should_branch : std_logic                     := '0';
	signal s_flags         : std_logic_vector(3 downto 0);
begin
	output        <= s_output(15 downto 0);
	should_branch <= s_should_branch;
	s_flags(FLAG_BIT_ZERO)  <= '1' when s_output(15 downto 0) = X"0000" else '0';
	s_flags(FLAG_BIT_CARRY) <= s_output(16);
	s_flags(FLAG_BIT_SIGN)  <= s_output(15);
	proc : process(clk) is
	begin
		if rising_edge(clk) then
			if en = '1' then
				case alu_control is
					when OPC_ADD =>
						if en_imm = '1' then
							s_output <= std_logic_vector(unsigned(rD_data(15) & rD_data) + unsigned(immediate(15) & immediate));
						else
							s_output <= std_logic_vector(unsigned(rD_data(15) & rD_data) + unsigned(rS_data(15) & rS_data));
						end if;
					when OPC_SUB =>
						if en_imm = '1' then
							s_output <= std_logic_vector(unsigned(rD_data(15) & rD_data) - unsigned(immediate(15) & immediate));
						else
							s_output <= std_logic_vector(unsigned(rD_data(15) & rD_data) - unsigned(rS_data(15) & rS_data));
						end if;
					when OPC_MOV =>
						if en_imm = '1' then
							s_output(15 downto 0) <= immediate;
						else
							s_output(15 downto 0) <= rS_data;
						end if;
						s_output(16) <= '0';
					when OPC_AND =>
						if en_imm = '1' then
							s_output(15 downto 0) <= rD_data and immediate;
						else
							s_output(15 downto 0) <= rD_data and rS_data;
						end if;
						s_output(16) <= '0';
					when OPC_OR =>
						if en_imm = '1' then
							s_output(15 downto 0) <= rD_data or immediate;
						else
							s_output(15 downto 0) <= rD_data or rS_data;
						end if;
						s_output(16) <= '0';
					when OPC_XOR =>
						if en_imm = '1' then
							s_output(15 downto 0) <= rD_data xor immediate;
						else
							s_output(15 downto 0) <= rD_data xor rS_data;
						end if;
					when OPC_NOT => 
						s_output(15 downto 0) <= not rD_data;
						s_output(16)         <= '0';
					when OPC_NEG => 
						s_output(15 downto 0) <= std_logic_vector(-signed(rD_data));
						s_output(16)  <= '0';
					when OPC_SHL =>
						if en_imm = '1' then
							s_output <= std_logic_vector(shift_left(unsigned('0' & rD_data), to_integer(unsigned(immediate))));
						else
							s_output <= std_logic_vector(shift_left(unsigned('0' & rD_data), to_integer(unsigned(rS_data))));
						end if;
					when OPC_SHR =>
						if en_imm = '1' then
							s_output <= std_logic_vector(shift_right(unsigned('0' & rD_data), to_integer(unsigned(immediate))));
						else
							s_output <= std_logic_vector(shift_right(unsigned('0' & rD_data), to_integer(unsigned(rS_data))));
						end if;
					when OPC_ROL =>
						if en_imm = '1' then
							s_output(15 downto 0) <= std_logic_vector(rotate_left(unsigned(rD_data), to_integer(unsigned(immediate))));
						else
							s_output(15 downto 0) <= std_logic_vector(rotate_left(unsigned(rD_data), to_integer(unsigned(rS_data))));
						end if;
						s_output(16)        <= '0';
					when others => s_output <= '0' & X"0000";
				end case;

			end if;
		end if;
	end process proc;

end architecture behavior;
