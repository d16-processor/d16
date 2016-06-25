library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_tb is
end cpu_tb;

architecture Test of cpu_tb is
	component core
		port(
			clk              : in  std_logic;
			rst              : in  std_logic;
			en               : in  std_logic;
			mem_wait         : in  std_logic;
			mem_data_in      : out std_logic_vector(15 downto 0);
			mem_addr         : out std_logic_vector(15 downto 0);
			mem_data_out     : in  std_logic_vector(15 downto 0);
			mem_byte_enable  : out std_logic;
			mem_byte_select  : out std_logic;
			mem_write_enable : out std_logic;
			mem_enable       : out std_logic
		);
	end component core;
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
	signal clk              : std_logic;
	signal rst              : std_logic;
	signal en               : std_logic;
	signal mem_wait         : std_logic;
	signal mem_addr         : std_logic_vector(15 downto 0);
	signal mem_data_out     : std_logic_vector(15 downto 0);
	signal mem_data_in      : std_logic_vector(15 downto 0);
	signal mem_byte_enable  : std_logic;
	signal mem_byte_select  : std_logic;
	signal mem_enable       : std_logic;
	signal mem_write_enable : std_logic;
	constant clk_period     : time := 10 ns;
begin
	core_inst : component core
		port map(
			en               => en,
			clk              => clk,
			rst              => rst,
			mem_wait         => mem_wait,
			mem_data_in      => mem_data_in,
			mem_addr         => mem_addr,
			mem_data_out     => mem_data_out,
			mem_byte_enable  => mem_byte_enable,
			mem_byte_select  => mem_byte_select,
			mem_write_enable => mem_write_enable,
			mem_enable       => mem_enable
		);
	mem_inst : component mem
		port map(
			clk          => clk,
			rst          => rst,
			en           => en,
			write_enable => mem_write_enable,
			byte_select  => mem_byte_select,
			byte_enable  => mem_byte_enable,
			addr         => mem_addr,
			data_in      => mem_data_in,
			data_out     => mem_data_out,
			mem_wait     => mem_wait
		);
	clk_proc : process is
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process clk_proc;
	stim_proc : process is
	begin
		
		rst <= '1';
		wait for clk_period;
		rst <= '0';
		en  <= '1';
		wait;
	end process stim_proc;
end architecture Test;
