library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_constants.all;
entity alu_tb is
end alu_tb;

architecture behavior of alu_tb is
	component alu
		port(
			clk              : in  std_logic;
			en               : in  std_logic;
			alu_control      : in  std_logic_vector(7 downto 0);
			en_imm           : in  std_logic;
			rD_data          : in  std_logic_vector(15 downto 0);
			rS_data          : in  std_logic_vector(15 downto 0);
			immediate        : in  std_logic_vector(15 downto 0);
			condition        : in  std_logic_vector(3 downto 0);
			flags_in         : in  std_logic_vector(3 downto 0);
			mem_displacement : in  std_logic;
			should_branch    : out std_logic;
			output           : out std_logic_vector(15 downto 0);
			mem_data         : out std_logic_vector(15 downto 0);
			write            : out std_logic;
			flags_out        : out std_logic_vector(3 downto 0);
			SP_out           : out std_logic_vector(15 downto 0)
		);
	end component alu;
	signal s_clk         : std_logic := '0';
	signal s_en          : std_logic := '0';
	signal s_alu_control : std_logic_vector(7 downto 0);
	signal s_en_imm      : std_logic := '0';
	signal s_rD_data     : std_logic_vector(15 downto 0);
	signal s_rS_data     : std_logic_vector(15 downto 0);
	signal s_immediate   : std_logic_vector(15 downto 0);

	signal s_should_branch  : std_logic;
	signal s_output         : std_logic_vector(15 downto 0);
	signal s_flags_in       : std_logic_vector(3 downto 0);
	signal s_flags_out      : std_logic_vector(3 downto 0);
	signal s_write_en       : std_logic;
	signal s_mem_data       : std_logic_vector(15 downto 0);
	signal s_condition      : std_logic_vector(3 downto 0);
	signal mem_displacement : std_logic := '0';
	signal SP_out           : std_logic_vector(15 downto 0);
	constant clk_period     : time      := 10 ns;

begin
	uut : entity work.alu
		port map(
			mem_displacement => mem_displacement,
			mem_data         => s_mem_data,
			condition        => s_condition,
			clk              => s_clk,
			en               => s_en,
			alu_control      => s_alu_control,
			en_imm           => s_en_imm,
			rD_data          => s_rD_data,
			rS_data          => s_rS_data,
			immediate        => s_immediate,
			flags_in         => s_flags_in,
			should_branch    => s_should_branch,
			output           => s_output,
			write            => s_write_en,
			flags_out        => s_flags_out,
			SP_out           => SP_out
		);
	clk_proc : process is
	begin
		s_clk <= '0';
		wait for clk_period / 2;
		s_clk <= '1';
		wait for clk_period / 2;
	end process clk_proc;
	stim_proc : process is
	begin
		s_en <= '0';
		wait for 2 * clk_period;
		s_en          <= '1';
		s_rD_data     <= X"0005";
		s_rS_data     <= X"0002";
		s_alu_control <= OPC_ADD;
		s_en_imm      <= '0';
		wait for clk_period;
		assert s_output = X"0007" report "Incorrect value after ADD" severity failure;

		s_alu_control <= OPC_SUB;
		wait for clk_period;
		assert s_output = X"0003" report "Incorrect value after SUB" severity failure;

		s_alu_control <= OPC_MOV;
		s_en_imm      <= '1';
		s_immediate   <= X"001D";
		wait for clk_period;
		assert s_output = X"001D" report "Incorrect value after MOV" severity failure;

		s_alu_control <= OPC_ADD;
		s_rD_data     <= X"7fff";
		s_immediate   <= X"0001";
		wait for clk_period;
		assert s_output = X"8000" report "Incorrect value after ADDI" severity failure;

		s_alu_control <= OPC_AND;
		s_rD_data     <= X"0fa5";
		s_rS_data     <= X"1d3C";
		s_en_imm      <= '0';
		wait for clk_period;
		assert s_output = X"0d24" report "Incorrect value after AND" severity failure;

		s_alu_control <= OPC_OR;
		wait for clk_period;
		assert s_output = X"1fbd" report "Incorrect value after OR" severity failure;

		s_alu_control <= OPC_XOR;
		wait for clk_period;
		assert s_output = X"1299" report "Incorrect value after XOR" severity failure;

		s_alu_control <= OPC_NOT;
		wait for clk_period;
		assert s_output = X"f05a" report "Incorrect value after NOT" severity failure;

		s_alu_control <= OPC_NEG;
		wait for clk_period;
		assert s_output = X"f05b" report "Incorrect value after NEG" severity failure;
		s_alu_control <= OPC_SHL;
		s_immediate   <= X"0003";
		s_en_imm      <= '1';
		wait for clk_period;
		assert s_output = X"7D28" report "Incorrect value after SHL" severity failure;
		s_alu_control <= OPC_SHR;

		wait for clk_period;
		assert s_output = X"01f4" report "Incorrect value after SHR" severity failure;
		s_alu_control <= OPC_ROL;
		s_immediate   <= X"0006";
		wait for clk_period;
		assert s_output = X"E943" report "Incorrect value after ROL" severity failure;
		s_alu_control <= OPC_ADC;
		s_flags_in    <= (FLAG_BIT_CARRY => '1', others => '0');
		s_rD_data     <= X"0001";
		wait for clk_period;
		assert s_output = X"0008" report "Incorrect value after ADC" severity failure;
		s_alu_control <= OPC_PUSH;
		s_rD_data     <= X"0567";
		s_rS_data     <= X"0100";
		wait for clk_period;
		assert s_output = X"00FE";
		assert SP_out = X"00FE";
		assert s_mem_data = X"0567";
		wait;
	end process stim_proc;

end architecture behavior;
