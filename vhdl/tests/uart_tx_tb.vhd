library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx_tb is
end uart_tx_tb;

architecture Test of uart_tx_tb is
	component uart_tx
		port(
			clk       : in  std_logic;
			data_send : in  std_logic;
			data      : in  std_logic_vector(7 downto 0);
			tx        : out std_logic
		);
	end component uart_tx;
	signal clk : std_logic;
	signal data_send : std_logic;
	signal data : std_logic_vector(7 downto 0);
	signal tx : std_logic;
	constant clk_period : time  := 10 ns;
begin
	uart_tx_inst : component uart_tx
		port map(
			clk       => clk,
			data_send => data_send,
			data      => data,
			tx        => tx
		);
	clk_proc : process is
	begin
		wait for clk_period/2;
		clk  <= '1';
		wait for clk_period/2;
		clk  <= '0';
	end process clk_proc;
	stim_proc : process is
	begin
		data  <= X"5A";
		wait for 2*clk_period;
		data_send  <= '1';
		wait for clk_period;
		data_send  <= '0';
		wait;
	end process stim_proc;
	
end architecture Test;
