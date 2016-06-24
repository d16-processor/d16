library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_constants.all;
entity pc_unit is
	port(
		clk    : in  std_logic;
		en     : in  std_logic;
		pc_in  : in  std_logic_vector(15 downto 0);
		pc_op  : in  std_logic_vector(1 downto 0);
		pc_out : out std_logic_vector(15 downto 0)
	);
end entity pc_unit;
architecture behavior of pc_unit is
	signal pc : std_logic_vector(15 downto 0) := X"0000";
begin
	pc_out <= pc;
	name : process(clk) is
	begin
		if rising_edge(clk) then
			if en = '1' then
				case pc_op is
					when PC_NOP =>
						pc <= pc;
					when PC_INC =>
						pc <= std_logic_vector(unsigned(pc) + 2);
					when PC_SET =>
						pc <= pc_in;
					when PC_RESET =>
						pc <= X"0000";
					when others => 
						
				end case;

			end if;
		end if;
	end process name;

end architecture behavior;
