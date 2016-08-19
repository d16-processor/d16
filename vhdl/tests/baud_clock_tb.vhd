library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_clock_tb is
end baud_clock_tb;

architecture Test of baud_clock_tb is
	component baud_clock
		port(
			clk     : in  std_logic;
			en      : in  std_logic;
			clk_out : out std_logic
		);
	end component baud_clock;
	signal clk_in  : std_logic := '0';
	signal clk_out : std_logic := '0';
	signal en      : std_logic := '0';
	constant clk_period : time  := 10 ns;
begin
	baud_clock_inst : component baud_clock
		port map(
			clk     => clk_in,
			en      => en,
			clk_out => clk_out
		);
	clk_process : process is
	begin
		wait for clk_period/2;
		clk_in  <= '1';
		wait for clk_period/2;
		clk_in  <= '0';
	end process clk_process;
	stim_proc : process is
	begin
		en  <= '0';
		wait for 2*clk_period;
		en  <= '1';
		wait;
	end process stim_proc;
	
end architecture Test;
