library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_constants.all;
entity alu_tb is
end alu_tb;

architecture behavior of alu_tb is
	component alu
		port(
			clk           : in  std_logic;
			en            : in  std_logic;
			alu_control   : in  std_logic_vector(7 downto 0);
			en_imm        : in  std_logic;
			rD_data       : in  std_logic_vector(15 downto 0);
			rS_data       : in  std_logic_vector(15 downto 0);
			should_branch : out std_logic;
			output        : out std_logic_vector(15 downto 0)
		);
	end component alu;
	signal s_clk         : std_logic := '0';
	signal s_en          : std_logic := '0';
	signal s_alu_control : std_logic_vector(7 downto 0);
	signal s_en_imm      : std_logic := '0';
	signal s_rD_data     : std_logic_vector(15 downto 0);
	signal s_rS_data	: std_logic_vector(15 downto 0);
	signal s_immediate : std_logic_vector(15 downto 0);
	
	signal s_should_branch : std_logic;
	signal s_output : std_logic_vector(15 downto 0);
	constant clk_period : time  := 10 ns;

begin
	uut: entity work.alu
		port map(
			immediate => s_immediate,
			clk           => s_clk,
			en            => s_en,
			alu_control   => s_alu_control,
			en_imm        => s_en_imm,
			rD_data       => s_rD_data,
			rS_data       => s_rS_data,
			should_branch => s_should_branch,
			output        => s_output
		);
	clk_proc : process is
	begin
		s_clk  <= '0';
		wait for clk_period/2;
		s_clk  <= '1';
		wait for clk_period/2;
	end process clk_proc;
	stim_proc : process is
	begin
		s_en  <= '0';
		wait for 2*clk_period;
		s_en  <= '1';
		s_rD_data  <= X"0005";
		s_rS_data <= X"0002";
		s_alu_control  <= OPC_ADD;
		s_en_imm  <= '0';
		wait for clk_period;
		assert s_output =  X"0007" report "Incorrect value after ADD" severity error;
		
		
		s_alu_control  <= OPC_SUB;
		wait for clk_period;
		assert s_output =  X"0003" report "Incorrect value after SUB" severity error;
		
		s_alu_control  <= OPC_MOV;
		s_en_imm  <= '1';
		s_immediate  <= X"001D";
		wait for clk_period;
		assert s_output = X"001D" report "Incorrect value after MOV" severity error;
		
		s_alu_control  <= OPC_ADD;
		s_rD_data  <= X"0014";
		s_immediate  <= X"0005";
		wait for clk_period;
		assert s_output = X"0019" report "Incorrect value after ADDI" severity error;
		
		wait;
	end process stim_proc;
	
	
end architecture behavior;
