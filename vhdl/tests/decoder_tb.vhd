library IEEE;
use IEEE.std_logic_1164.all;

use std.textio.all;
entity decoder_tb is
end decoder_tb;

architecture behavior of decoder_tb is
	component decoder
		port(
			clk          : in  std_logic;
			en           : in  std_logic;
			instruction  : in  std_logic_vector(15 downto 0);
			alu_control  : out std_logic_vector(6 downto 0);
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
	signal alu_control : std_logic_vector(6 downto 0)  :=  (others  => '0');
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
		wait for clk_period;
		instruction  <= X"8203"; --sub r3, #2
		wait for clk_period;
		instruction  <= X"101b"; --xor r3,r3
		wait for clk_period;
		instruction  <= X"0952"; --mov r4,#82
		wait for clk_period;
		instruction  <= X"8d05"; --mov r5,#314
		wait for clk_period;
		instruction  <= X"0d0e"; --mov r6,r1
		wait for clk_period;
		instruction  <= X"1318"; --ld r0,r3
		wait;
	end process;
end behavior;
