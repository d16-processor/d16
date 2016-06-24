library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.cpu_constants.all;
entity control is
	port(
		clk           : in  std_logic;
		en            : in  std_logic;
		rst           : in  std_logic;
		en_mem        : in  std_logic;
		mem_wait      : in  std_logic;
		should_branch : in  std_logic;
		control       : out std_logic_vector(CONTROL_BIT_MAX downto 0)
	);
end entity control;
architecture behavior of control is
	signal s_control : std_logic_vector(CONTROL_BIT_MAX downto 0);

begin
	control <= s_control;
	name : process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				s_control <= STATE_FETCH;
			else
				if en = '1' then
					--basically a FSM
					case s_control is
						when STATE_FETCH =>
							if mem_wait = '1' then
								s_control <= STATE_FETCH;
							else
								s_control <= STATE_DECODE;
							end if;
						when STATE_DECODE =>
							s_control <= STATE_REG_READ;
						when STATE_REG_READ =>
							s_control <= STATE_ALU;
						when STATE_ALU =>
							if en_mem = '1' then
								s_control <= STATE_MEM;
							else
								s_control <= STATE_REG_WR;
							end if;
						when STATE_MEM =>
							if mem_wait = '1' then
								s_control <= STATE_MEM;
							else
								s_control <= STATE_REG_WR;
							end if;
						when STATE_REG_WR =>
							if should_branch = '1' then
								s_control  <= STATE_PC_DELAY;
							else
								s_control <= STATE_FETCH;
							end if;
						when STATE_PC_DELAY  => 
							s_control  <= STATE_BRANCH_DELAY;
						when STATE_BRANCH_DELAY  => 
							s_control  <= STATE_FETCH;
						when others =>
							s_control <= STATE_FETCH;
					end case;
				end if;
			end if;
		end if;
	end process name;

end architecture behavior;
