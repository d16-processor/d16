library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_tb is
end uart_rx_tb;

architecture Test of uart_rx_tb is
	component uart_tx
		port(
			clk       : in  std_logic;
			data_send : in  std_logic;
			data      : in  std_logic_vector(7 downto 0);
			tx        : out std_logic;
			idle      : out std_logic
		);
	end component uart_tx;
	component uart_rx
		port(
			clk        : in  std_logic;
			rx         : in  std_logic;
			data       : out std_logic_vector(7 downto 0);
			data_ready : out std_logic
		);
	end component uart_rx;
	signal clk          : std_logic;
	signal tx           : std_logic;
	signal rx           : std_logic;
	signal tx_data      : std_logic_vector(7 downto 0);
	signal rx_data      : std_logic_vector(7 downto 0);
	signal data_send    : std_logic;
	signal idle         : std_logic;
	signal data_ready   : std_logic;
	constant clk_period : time := 10 ns;
begin
	uart_rx_inst : component uart_rx
		port map(
			clk        => clk,
			rx         => rx,
			data       => rx_data,
			data_ready => data_ready
		);
	uart_tx_inst : component uart_tx
		port map(
			clk       => clk,
			data_send => data_send,
			data      => tx_data,
			tx        => tx,
			idle      => idle
		);
	rx <= tx;
	clk_proc : process is
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;

	end process clk_proc;
	stim_proc : process is
	begin
		tx_data <= X"A5";
		wait for 2 * clk_period;
		data_send <= '1';
		wait for clk_period;
		data_send  <= '0';
		wait until data_ready = '1';
		assert tx_data = rx_data severity error;
		wait;
	end process stim_proc;

end architecture Test;
