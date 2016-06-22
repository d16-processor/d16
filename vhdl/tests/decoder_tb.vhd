library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
entity decoder_tb is
end decoder_tb;

architecture behavior of decoder_tb is
	component decoder
		port(
			clk          : in  std_logic;
			en           : in  std_logic;
			instruction  : in  std_logic_vector(15 downto 0);
			alu_control  : out std_logic_vector(7 downto 0);
			rD_sel       : out std_logic_vector(2 downto 0);
			rS_sel       : out std_logic_vector(2 downto 0);
			immediate    : out std_logic_vector(15 downto 0);
			en_immediate : out std_logic;
			next_word    : out std_logic
		);
	end component decoder;
	signal clk 		: std_logic  := '0';
	signal en 		: std_logic  := '0';
	signal instruction : std_logic_vector(15 downto 0)  := (others  => '0');
	signal alu_control : std_logic_vector(7 downto 0)  :=  (others  => '0');
	signal rD_sel		: std_logic_vector(2 downto 0)  := (others  => '0');
	signal rS_sel		: std_logic_vector(2 downto 0)  := (others  => '0');
	signal immediate	: std_logic_vector(15 downto 0)  := (others  => '0');
	signal en_imm		: std_logic  := '0';
	signal next_word	: std_logic  := '0';
	constant clk_period : time  := 10 ns;
begin
	uut: component decoder
		port map(
			clk          => clk,
			en           => en,
			instruction  => instruction,
			alu_control  => alu_control,
			rD_sel       => rD_sel,
			rS_sel       => rS_sel,
			immediate    => immediate,
			en_immediate => en_imm,
			next_word    => next_word
		);
	clk_process : process
		begin
		clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
	end process;
	stim_process : process
		begin
		wait for 2*clk_period;
		en <= '1';
		instruction  <= X"0108"; --add r0,r1
		wait for clk_period*2;
		assert alu_control = X"01" report "ALU control set to incorrect value: "& integer'image(to_integer(unsigned(alu_control))) severity failure;
		assert rD_sel = "000" report "RD selector set to: "&integer'image(to_integer(unsigned(rD_sel))) severity failure;
		assert rS_sel = "001" report "RS selector set to: "&integer'image(to_integer(unsigned(rS_sel))) severity failure;
		
		instruction  <= X"8203"; --sub r3, #2
		wait for clk_period;
		
		
		assert next_word = '1' report "Next word not set" severity failure;
		assert en_imm = '1' report "Immediate not set" severity failure;
		
		assert alu_control = X"02" report "ALU control set to incorrect value: "& integer'image(to_integer(unsigned(alu_control))) severity failure;
		assert rD_sel = "011" report "RD selector set to: "&integer'image(to_integer(unsigned(rD_sel))) severity failure;
		instruction  <= X"101b"; --xor r3,r3
		wait for clk_period;
		
		
		assert alu_control = X"10" report "ALU control set to incorrect value: "& integer'image(to_integer(unsigned(alu_control))) severity failure;
		assert rD_sel = "011" report "RD selector set to: "&integer'image(to_integer(unsigned(rD_sel))) severity failure;
		assert rS_sel = "011" report "RS selector set to: "&integer'image(to_integer(unsigned(rS_sel))) severity failure;
		instruction  <= X"0952"; --mov r4,#82
		wait for clk_period;
		
		
		assert immediate = X"0052" report "Incorrect immediate value" severity failure;
		assert en_imm = '1' report "Immediate not set" severity failure;
		assert next_word = '0' report "Next word not reset" severity failure;
		assert alu_control = X"0D" report "ALU control set to incorrect value: "& integer'image(to_integer(unsigned(alu_control))) severity failure;
		assert rD_sel = "100" report "RD selector set to: "&integer'image(to_integer(unsigned(rD_sel))) severity failure;
		instruction  <= X"8d05"; --mov r5,#314
		wait for clk_period;
		
		
		assert en_imm = '1' report "Immediate not set" severity failure;
		assert next_word = '1' report "Next word not set" severity failure;
		assert alu_control = X"0D" report "ALU control set to incorrect value: "& integer'image(to_integer(unsigned(alu_control))) severity failure;
		assert rD_sel = "101" report "RD selector set to: "&integer'image(to_integer(unsigned(rD_sel))) severity failure;
		
		instruction  <= X"0d0e"; --mov r6,r1
		wait for clk_period;
		
		
		assert alu_control = X"0D" report "ALU control set to incorrect value: "& integer'image(to_integer(unsigned(alu_control))) severity failure;
		assert rD_sel = "110" report "RD selector set to: "&integer'image(to_integer(unsigned(rD_sel))) severity failure;
		assert rS_sel = "001" report "RS selector set to: "&integer'image(to_integer(unsigned(rS_sel))) severity failure;
		instruction  <= X"1318"; --ld r0,r3
		wait for clk_period;
		
		
		assert alu_control = X"13" report "ALU control set to incorrect value: "& integer'image(to_integer(unsigned(alu_control))) severity failure;
		assert rD_sel = "000" report "RD selector set to: "&integer'image(to_integer(unsigned(rD_sel))) severity failure;
		assert rS_sel = "011" report "RS selector set to: "&integer'image(to_integer(unsigned(rS_sel))) severity failure;
		wait;
	end process;
end behavior;
