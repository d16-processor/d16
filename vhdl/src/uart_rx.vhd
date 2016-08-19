library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
	port(
		clk        : in  std_logic;
		rx         : in  std_logic;
		data       : out std_logic_vector(7 downto 0);
		data_ready : out std_logic
	);
end entity uart_rx;
architecture RTL of uart_rx is
	type state_type is (S_IDLE, S_START, S_DATA, S_END);
	signal state       : state_type := S_IDLE;
	signal clk_counter : unsigned(3 downto 0);
	signal rx_data : std_logic_vector(7 downto 0);
	signal data_counter : unsigned(2 downto 0);
begin
	name : process(clk) is
	begin
		if rising_edge(clk) then
			case state is
				when S_IDLE =>
					if rx = '0' then    --start bit
						state       <= S_START;
						clk_counter <= X"6";
						
					end if;
				when S_START =>
					if clk_counter = X"0" and rx = '0' then
						state  <= S_DATA;
						clk_counter  <= X"F";
						data_counter  <=  "000";
						rx_data  <= X"00";
						data_ready  <= '0';
					end if;
					clk_counter  <=  clk_counter - 1;
					null;
				when S_DATA =>
					if clk_counter = X"0" then
						rx_data(to_integer(data_counter)) <=  rx;
						if data_counter = "111" then
							state  <= S_END;
						end if;
						data_counter  <= data_counter + 1;
					end if;
					clk_counter  <=  clk_counter - 1;
					null;
				when S_END =>
					if clk_counter = X"0" then
						state  <= S_IDLE;
						data_ready  <= '1';
						data  <=  rx_data;
					end if;
					clk_counter  <=  clk_counter - 1;
					null;
			end case;
			
		end if;
	end process name;

end architecture RTL;
