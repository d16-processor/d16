library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_tb is
end mem_tb;

architecture Test of mem_tb is
	component mem
		port(
			clk          : in  std_logic;
			rst          : in  std_logic;
			en           : in  std_logic;
			write_enable : in  std_logic;
			byte_select  : in  std_logic;
			byte_enable  : in  std_logic;
			addr         : in  std_logic_vector(15 downto 0);
			data_in      : in  std_logic_vector(15 downto 0);
			data_out     : out std_logic_vector(15 downto 0);
			mem_wait     : out std_logic
		);
	end component mem;
	signal clk          : std_logic;
	signal rst          : std_logic;
	signal en           : std_logic;
	signal addr         : std_logic_vector(15 downto 0);
	signal data_in      : std_logic_vector(15 downto 0);
	signal data_out     : std_logic_vector(15 downto 0);
	signal mem_wait     : std_logic;
	signal write_enable : std_logic;
	signal byte_enable  : std_logic;
	signal byte_select  : std_logic;
	constant clk_period : time := 10 ns;
begin
	mem_inst : entity work.mem
		port map(
			byte_select => byte_select,
			byte_enable => byte_enable,
			write_enable => write_enable,
			clk          => clk,
			rst          => rst,
			en           => en,
			addr         => addr,
			data_in      => data_in,
			data_out     => data_out,
			mem_wait     => mem_wait
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
		rst <= '1';
		wait for clk_period;
		rst  <= '0';
		en   <= '1';
		addr <= X"0000";
		wait for clk_period;
		for i in 0 to 10 loop
			addr <= std_logic_vector(unsigned(addr) + 1);
			wait for clk_period;
		end loop;
		data_in      <= X"DDCC";
		addr         <= X"001c";
		write_enable <= '1';
		wait;
	end process stim_proc;

end architecture Test;
