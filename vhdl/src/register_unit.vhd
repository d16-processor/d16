library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;
entity register_unit is
	port(
		clk 			: in std_logic;
		en 				: in std_logic;
		wr_en			: in std_logic;
		rD_sel 			: in std_logic_vector(2 downto 0);
		rS_sel 			: in std_logic_vector(2 downto 0);
		rD_data_in 		: in std_logic_vector(15 downto 0);
		rD_data_out 	: out std_logic_vector(15 downto 0);
		rS_data_out		: out std_logic_vector(15 downto 0)
	);
end register_unit;
architecture behavior of register_unit is
	type reg_storage is array (0 to 7) of std_logic_vector(15 downto 0);
	signal registers: reg_storage;
begin	
	process(clk, en)
	begin
		if rising_edge(clk) and en = '1' then
			rD_data_out  <= registers(to_integer(unsigned(rD_sel)));
			rS_data_out  <= registers(to_integer(unsigned(rS_sel)));
			if wr_en = '1' then
				registers(to_integer(unsigned(rD_sel)))  <= rD_data_in;
			end if;	
			
				
		end if;
	end process;
end behavior;
