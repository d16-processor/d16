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
	component mem
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
	end component mem;

	signal clk              : std_logic;
	signal rst              : std_logic;
	--ALU specific signals
	signal alu_control      : std_logic_vector(7 downto 0);
	
	signal rD_data          : std_logic_vector(15 downto 0);
	signal rS_data          : std_logic_vector(15 downto 0);
	signal immediate        : std_logic_vector(15 downto 0);
	signal flags_out        : std_logic_vector(3 downto 0);
	signal flags_in         : std_logic_vector(3 downto 0);
	signal should_branch    : std_logic;
	signal condition        : std_logic_vector(3 downto 0);
	signal alu_output       : std_logic_vector(15 downto 0);
	signal reg_write_enable : std_logic;
	--Control unit signals
	signal en_mem           : std_logic;
	signal mem_wait         : std_logic;
	signal control_state    : std_logic_vector(CONTROL_BIT_MAX downto 0);
	--Decoder specific signals
	signal instruction      : std_logic_vector(15 downto 0);
	signal rD_sel           : std_logic_vector(2 downto 0);
	signal rS_sel           : std_logic_vector(2 downto 0);
	signal dec_immediate    : std_logic_vector(15 downto 0);
	signal en_immediate     : std_logic;
	signal next_word        : std_logic;
	--PC Unit signals
	signal pc_in            : std_logic_vector(15 downto 0);
	signal pc_op            : e_pc_op;
	signal pc_out           : std_logic_vector(15 downto 0);
	--register unit signals;
	signal rD_data_in       : std_logic_vector(15 downto 0);
	--mem unit signals
	signal mem_write_enable : std_logic;
	signal mem_addr         : std_logic_vector(15 downto 0);
	signal mem_data_in      : std_logic_vector(15 downto 0);
	signal mem_data_out     : std_logic_vector(15 downto 0);
	--enable signals
	signal en_alu           : std_logic;
	signal en               : std_logic;
	signal en_decoder       : std_logic;
	signal en_pc            : std_logic;
	signal en_register      : std_logic;
	signal mem_enable       : std_logic;
	constant clk_period     : time := 10 ns;
begin
	alu_inst : component alu
		port map(
			clk           => clk,
			en            => en_alu,
			alu_control   => alu_control,
			en_imm        => en_immediate,
			rD_data       => rD_data,
			rS_data       => rS_data,
			immediate     => immediate,
			condition     => condition,
			flags_in      => flags_in,
			should_branch => should_branch,
			output        => alu_output,
			write         => reg_write_enable,
			flags_out     => flags_out
		);
	control_inst : component control
		port map(
			clk      => clk,
			en       => en,
			rst      => rst,
			en_mem   => en_mem,
			mem_wait => mem_wait,
			control  => control_state
		);
	decoder_inst : component decoder
		port map(
			clk          => clk,
			en           => en_decoder,
			instruction  => instruction,
			alu_control  => alu_control,
			rD_sel       => rD_sel,
			rS_sel       => rS_sel,
			immediate    => dec_immediate,
			en_immediate => en_immediate,
			next_word    => next_word,
			en_mem       => en_mem,
			condition    => condition
		);
	pc_unit_inst : component pc_unit
		port map(
			clk    => clk,
			en     => en_pc,
			pc_in  => pc_in,
			pc_op  => pc_op,
			pc_out => pc_out
		);
	register_unit_inst : component register_unit
		port map(
			clk         => clk,
			en          => en_register,
			wr_en       => reg_write_enable,
			rD_sel      => rD_sel,
			rS_sel      => rS_sel,
			rD_data_in  => rD_data_in,
			rD_data_out => rD_data,
			rS_data_out => rS_data
		);
	mem_inst : component mem
		port map(
			clk          => clk,
			rst          => rst,
			en           => mem_enable,
			write_enable => mem_write_enable,
			addr         => mem_addr,
			data_in      => mem_data_in,
			data_out     => mem_data_out,
			mem_wait     => mem_wait
		);
	en_alu      <= '1' when control_state = STATE_ALU else '0';
	en_decoder  <= '1' when control_state = STATE_DECODE else '0';
	en_pc       <= '1' when control_state = STATE_DECODE or control_state = STATE_REG_WR else '0';
	en_register <= '1' when control_state = STATE_REG_READ or control_state = STATE_REG_WR else '0';
	mem_enable  <= '1' when control_state = STATE_REG_WR or control_state = STATE_MEM else '0';
	mem_write_enable  <= '1' when control_state = STATE_MEM and instruction(15 downto 8) = OPC_ST else '0';
	mem_data_in  <= rS_data;
	immediate   <= mem_data_out when next_word = '1' else dec_immediate;
	rd_data_in  <= alu_output;
	pc_in   <= alu_output;
	clk_proc : process is
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process clk_proc;
	core_proc : process(clk, en) is
	begin
		if rising_edge(clk) and en = '1' then
			if rst = '1' then
				flags_in  <= "0000";
			else
				
				
				case control_state is
					when STATE_FETCH =>
						instruction <= mem_data_out;
						pc_op       <= INC;
					when STATE_MEM =>
						mem_addr         <= pc_out;
						
					when STATE_ALU  => 
						if en_mem = '0' then
							mem_addr  <= pc_out;
						end if;
						report "ALU Output: " & integer'image(to_integer(unsigned(alu_output)));
					when STATE_DECODE =>
						flags_in  <= flags_out;
						if instruction(15) = '1' then
							pc_op <= INC;
						else
							pc_op <= NOP;
						end if;

					when others =>
				end case;
			end if;
		end if;
	end process core_proc;

	stim_proc : process is
	begin
		rst <= '1';
		wait for clk_period;
		rst <= '0';
		en  <= '1';

		wait;
	end process stim_proc;
end architecture behavior;
