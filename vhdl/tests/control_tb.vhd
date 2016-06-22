library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_constants.all;

entity control_tb is
end control_tb;

architecture behavior of control_tb is
	component control
		port(
			clk     : in  std_logic;
			en      : in  std_logic;
			rst     : in  std_logic;
			en_mem  : in  std_logic;
			control : out std_logic_vector(CONTROL_BIT_MAX downto 0)
		);
	end component control;
	signal clk          : std_logic;
	signal en           : std_logic;
	signal rst          : std_logic;
	signal en_mem       : std_logic;
	signal control_in   : std_logic_vector(CONTROL_BIT_MAX downto 0);
	constant clk_period : time := 10 ns;
begin
	uut : component control
		port map(
			clk     => clk,
			en      => en,
			rst     => rst,
			en_mem  => en_mem,
			control => control_in
		);
	clk_process : process is
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process clk_process;
	stim_proc : process is
	begin
		rst  <= '1';
		wait for clk_period;
		rst  <= '0';
		en  <= '1';
		en_mem  <=  '0';
		wait until control_in = STATE_DECODE;
		wait for clk_period;
		wait until control_in = STATE_DECODE;
		en_mem <= '1';
		wait;
	end process stim_proc;
	
end architecture behavior;
