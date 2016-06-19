library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;
entity decoder is
	port(
		clk			: in std_logic;
		en			: in std_logic;
		instruction	: in std_logic_vector(15 downto 0);
		alu_control	: out std_logic_vector(7 downto 0);
		rD_sel		: out std_logic_vector(2 downto 0);
		rS_sel		: out std_logic_vector(2 downto 0);
		immediate	: out std_logic_vector(15 downto 0);
		next_word	: out std_logic;
	);
	
end decoder;
architecture behavior of decoder is
variable cycle : std_logic  := '0';
begin
process(clk,en)
begin
	if rising_edge(clk) and en = '1' then
		if rising_edge(en) then
			cycle  := '0';
		end if;
		
	
	end if;
end process;
	
	
end behavior;