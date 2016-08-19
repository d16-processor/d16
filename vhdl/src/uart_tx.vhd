library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
	port(
		clk       : in  std_logic;
		data_send : in  std_logic;
		data      : in  std_logic_vector(7 downto 0);
		tx        : out std_logic;
		idle	: out std_logic
	);
end entity uart_tx;
architecture RTL of uart_tx is
	type state_type is (S_IDLE, S_START, S_SEND, S_STOP);
	signal s_data      : std_logic_vector(7 downto 0);
	signal state       : state_type := S_IDLE;
	signal clk_counter : unsigned(3 downto 0);
	signal bit_counter : unsigned(2 downto 0);
begin
	state_proc : process(clk) is
	begin
		if rising_edge(clk) then
			case state is
				when S_IDLE =>
					if data_send = '1' then
						state <= S_START;

						s_data <= data;
						
					end if;
					tx     <= '1';
					idle  <= '1';
					clk_counter <= X"0";
				when S_START =>
					tx          <= '0';
					idle  <= '0';
					clk_counter <= clk_counter + 1;
					bit_counter  <= "000";
					if clk_counter = X"F" then
						state <= S_SEND;
						
					end if;
					null;
				when S_SEND =>
					if clk_counter = X"0" then
						tx  <= s_data(to_integer(bit_counter));
						bit_counter  <= bit_counter + 1;
					end if;
					if clk_counter = X"F" and bit_counter = "000" then
						state <= S_STOP;
						clk_counter  <= X"0";
					end if;
					clk_counter <= clk_counter + 1;
					null;
				when S_STOP =>
					tx  <= '1';
					clk_counter <= clk_counter + 1;
					if clk_counter = X"F" then
						state <= S_IDLE;
						
					end if;
					null;
			end case;
		end if;
	end process state_proc;

end architecture RTL;