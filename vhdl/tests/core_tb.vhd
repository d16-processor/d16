library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_constants.all;
entity core_tb is
end core_tb;

architecture behavior of core_tb is
	component alu
		port(
			clk           : in  std_logic;
			en            : in  std_logic;
			alu_control   : in  std_logic_vector(7 downto 0);
			en_imm        : in  std_logic;
			rD_data       : in  std_logic_vector(15 downto 0);
			rS_data       : in  std_logic_vector(15 downto 0);
			immediate     : in  std_logic_vector(15 downto 0);
			condition     : in  std_logic_vector(3 downto 0);
			flags_in      : in  std_logic_vector(3 downto 0);
			should_branch : out std_logic;
			output        : out std_logic_vector(15 downto 0);
			write         : out std_logic;
			flags_out     : out std_logic_vector(3 downto 0)
		);
	end component alu;
	component control
		port(
			clk      : in  std_logic;
			en       : in  std_logic;
			rst      : in  std_logic;
			en_mem   : in  std_logic;
			mem_wait : in  std_logic;
			control  : out std_logic_vector(CONTROL_BIT_MAX downto 0)
		);
	end component control;
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
			next_word    : out std_logic;
			en_mem       : out std_logic;
			condition    : out std_logic_vector(3 downto 0)
		);
	end component decoder;
	component pc_unit
		port(
			clk    : in  std_logic;
			en     : in  std_logic;
			pc_in  : in  std_logic_vector(15 downto 0);
			pc_op  : in  e_pc_op;
			pc_out : out std_logic_vector(15 downto 0)
		);
	end component pc_unit;
	component register_unit
		port(
			clk         : in  std_logic;
			en          : in  std_logic;
			wr_en       : in  std_logic;
			rD_sel      : in  std_logic_vector(2 downto 0);
			rS_sel      : in  std_logic_vector(2 downto 0);
			rD_data_in  : in  std_logic_vector(15 downto 0);
			rD_data_out : out std_logic_vector(15 downto 0);
			rS_data_out : out std_logic_vector(15 downto 0)
		);
	end component register_unit;
begin
	
end architecture behavior;
