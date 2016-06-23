library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
entity mem is
	port(
		clk          : in  std_logic;
		rst          : in  std_logic;
		en           : in  std_logic;
		write_enable : in  std_logic;
		addr         : in  std_logic_vector(15 downto 0);
		data_in      : in  std_logic_vector(15 downto 0);
		data_out     : out std_logic_vector(15 downto 0);
		mem_wait     : out std_logic
	);
end entity mem;
architecture behavior of mem is
	type t_char_file is file of character;
	type t_byte_arr is ARRAY (natural range <>) of bit_vector(7 downto 0);

	type mem_storage_t is array (0 to 63) of std_logic_vector(15 downto 0);
	signal mem_storage : mem_storage_t;

begin
	mem_wait <= '0';
	mem_proc : process(clk) is
		FILE file_in : t_char_file OPEN read_mode is "./mem.bin";
		variable char_buffer : character;

	begin
		if rising_edge(clk) then
			if rst = '1' then
				for i in mem_storage'range loop
					if not ENDFILE(file_in) then
						read(file_in, char_buffer);
						mem_storage(i)(7 downto 0) <= std_logic_vector(to_unsigned(character'pos(char_buffer), 8));
						read(file_in, char_buffer);
						mem_storage(i)(15 downto 8) <= std_logic_vector(to_unsigned(character'pos(char_buffer), 8));
					else
						mem_storage(i) <= X"0000";
					end if;
				end loop;
				file_close(file_in);
			else
				if en = '1' then
					if write_enable = '1' then
						report "Wrote " & integer'image(to_integer(unsigned(data_in))) & " to address " & integer'image(to_integer(unsigned(addr)));
					end if;
					if unsigned(addr) < 64 then
						data_out <= mem_storage(to_integer(unsigned(addr)));
						if write_enable = '1' then
							mem_storage(to_integer(unsigned(addr))) <= data_in;

						end if;
					end if;
				end if;
			end if;
		end if;
	end process mem_proc;

end architecture behavior;
