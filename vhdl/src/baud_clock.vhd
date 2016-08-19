library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--Clock rate assumed to be 50 Mhz
entity baud_clock is
	port(
		clk     : in  std_logic;
		en      : in  std_logic;
		clk_out : out std_logic
	);
end entity baud_clock;
architecture RTL of baud_clock is
	signal s_baud_clock : std_logic;
	signal s_baud_counter : unsigned(4 downto 0);
	signal s_baud_error : std_logic;
begin
	name : process(clk) is
	begin
		if rising_edge(clk) then
			if en = '1' then
				s_baud_counter  <= s_baud_counter + 1;
				if (s_baud_counter = '1' & X"A" and s_baud_clock = '0' and s_baud_error = '1') or (s_baud_counter = '1' & X"B" and s_baud_clock = '0') then
					s_baud_clock  <= '1';
					s_baud_counter  <= '0' & X"0";
					s_baud_error  <= not s_baud_error ;
				end if;
				if s_baud_counter = '1' & X"A" and s_baud_clock = '1' then
					s_baud_clock  <= '0';
					s_baud_counter  <= '0'& X"0";
				end if;
			else
				s_baud_clock <= '0';
				s_baud_counter  <= "00000";
				s_baud_error  <= '0';
			end if;
		end if;
	end process name;
	clk_out <= s_baud_clock;
end architecture RTL;
--current clk rate 1.834
--goal 1.843 Mhz