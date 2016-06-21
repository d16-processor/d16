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
	signal s_output        : std_logic_vector(15 downto 0) := (others => '0');
	signal s_should_branch : std_logic                     := '0';

begin
	output        <= s_output;
	should_branch <= s_should_branch;

	proc : process(clk) is
	begin
		if rising_edge(clk) then
			if en = '1' then
				case alu_control is
					when OPC_ADD =>
						if en_imm = '1' then
							s_output <= std_logic_vector(unsigned(rD_data) + unsigned(immediate));
						else
							s_output <= std_logic_vector(unsigned(rD_data) + unsigned(rS_data));
						end if;
					when OPC_SUB =>
						if en_imm = '1' then
							s_output <= std_logic_vector(unsigned(rD_data) - unsigned(immediate));
						else
							s_output <= std_logic_vector(unsigned(rD_data) - unsigned(rS_data));
						end if;
					when OPC_MOV =>
						if en_imm = '1' then
							s_output <= immediate;
						else
							s_output <= rS_data;
						end if;
					when others => s_output <= X"0000";
				end case;

			end if;
		end if;
	end process proc;

end architecture behavior;
