library IEEE;
use IEEE.std_logic_1164.all;

use std.textio.all;
entity reg_tb is
end reg_tb;


architecture behavior of reg_tb is
	component register_unit
		port(
			clk         : in  std_logic;
			en          : in  std_logic;
			wr_en       : in  std_logic;
			rD_sel      : in  std_logic_vector(2 downto 0);
			rS_sel      : in  std_logic_vector(2 downto 0);
			rD_data_in  : in  std_logic_vector(15 downto 0);
			rD_data_out : out std_logic_vector(15 downto 0);
			rS_data_out : out std_logic_vector(15 downto 0)
		);
	end component register_unit;
	
	signal clk 		: std_logic  := '0';
	signal en 		: std_logic  := '0';
	signal wr_en	: std_logic  := '0';
	signal rD_sel	: std_logic_vector(2 downto 0)  := (others  => '0');
	signal rS_sel	: std_logic_vector(2 downto 0)  := (others  => '0');
	signal rD_data	: std_logic_vector(15 downto 0) := (others  => '0');
	signal rS_data 	: std_logic_vector(15 downto 0) := (others  => '0');
	signal rD_out	: std_logic_vector(15 downto 0) := (others  => '0');
	constant clk_period : time   := 10 ns;
	begin
	uut: register_unit port map(
		clk  => clk,
		en  => en,
		wr_en  => wr_en,
		rD_sel  => rD_sel,
		rS_sel  => rS_sel,
		rD_data_in  => rD_out,
		rD_data_out  => rD_data,
		rS_data_out  => rS_data
	);
	clk_process: process
	begin
		clk  <= '0';
		wait for clk_period/2;
		clk  <= '1';
		wait for clk_period/2;
		
	end process;
	stim_process: process
	begin
		wait for 20 ns;
		en <= '1';
		rD_sel  <= "001";
		rD_out  <= X"feed";
		wr_en <= '1';
		
		wait for clk_period;
		rD_sel  <= "000";
		rD_out  <= X"beef";
		wr_en <= '1';
		
		wait for clk_period;
		rD_sel  <= "000";
		rS_sel  <= "001";
		wr_en  <= '0';
		wait;
	end process;
		

end behavior;	
