library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;
use work.cpu_constants.ALL;
entity decoder is
	port(
		clk			: in std_logic;
		en			: in std_logic;
		instruction	: in std_logic_vector(15 downto 0);
		alu_control	: out std_logic_vector(6 downto 0);
		rD_sel		: out std_logic_vector(2 downto 0);
		rS_sel		: out std_logic_vector(2 downto 0);
		immediate	: out std_logic_vector(15 downto 0);
		en_immediate : out std_logic;
		next_word	: out std_logic
	);
	
end decoder;
architecture behavior of decoder is
variable cycle : std_logic  := '0';


begin
	
	process(clk,en)
	begin
		if rising_edge(clk) and en = '1' then
			if rising_edge(en) then
				cycle  := '0';
				if unsigned(instruction(15 downto 8)) <= unsigned(OPC_MOVB_R7) and unsigned(instruction(15 downto 8)) >= unsigned(OPC_MOVB_R0) then
					en_immediate <= '1';
					alu_control <= OPC_MOV(6 downto 0);
					next_word <= '0';
					rD_sel <= "000";
					immediate <= instruction(7 downto 0);
				else
					en_immediate <= instruction(15);
					next_word <= instruction(15);
					rD_sel <= instruction(2 downto 0);
					rS_sel  <= instruction(5 downto 3);
					immediate  <= X"0000";
				end if;	
					
						
				
			else
				immediate <= instruction;
				cycle := '1';
			end if;
	
	end if;
end process;

	
end behavior;