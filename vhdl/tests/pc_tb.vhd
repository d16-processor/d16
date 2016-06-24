library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_constants.all;
entity pc_tb is
end pc_tb;

architecture behavior of pc_tb is
	component pc_unit
		port(
			clk    : in  std_logic;
			en     : in  std_logic;
			pc_in  : in  std_logic_vector(15 downto 0);
			pc_op  : in  std_logic_vector(1 downto 0);
			pc_out : out std_logic_vector(15 downto 0)
		);
	end component pc_unit;
	signal clk          : std_logic;
	signal en           : std_logic;
	signal pc_in        : std_logic_vector(15 downto 0);
	signal pc_op        : std_logic_vector(1 downto 0);
	signal pc_out       : std_logic_vector(15 downto 0);
	constant clk_period : time := 10 ns;
begin
	uut : entity work.pc_unit
		port map(
			clk    => clk,
			en     => en,
			pc_in  => pc_in,
			pc_op  => pc_op,
			pc_out => pc_out
		);
	clk_proc : process is
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process clk_proc;
	stim_proc : process is
	begin
		wait for clk_period;
		en  <= '1';
		pc_op  <= PC_RESET;
		wait for clk_period;
		assert pc_out = X"0000" report "Incorrect PC Value after reset" severity failure;
		pc_op  <= PC_INC;
		wait for 5*clk_period;
		assert pc_out = X"000A" report "Incorrect PC Value after pc increment" severity failure;
		
		pc_op  <= PC_SET;
		pc_in  <= X"1D43";
		wait for clk_period;
		assert pc_out = X"1d43" report "Incorrect PC Value after pc set" severity failure;
		pc_op  <= PC_INC;
		wait for 4*clk_period;
		assert pc_out = X"1d4B" report "Incorrect PC Value after pc increment" severity failure;
		en  <= '0';
		wait;
	end process stim_proc;
	
end architecture behavior;
