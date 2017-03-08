library ieee;
use ieee.std_logic_1164.all;
entity sdram_controller_tb is

end entity;

architecture sim of sdram_controller_tb is
    component sdram_controller
        PORT
        (
            CLOCK_50      : IN STD_LOGIC;
           
           -- Signals to/from the SDRAM chip
           DRAM_ADDR   : OUT   STD_LOGIC_VECTOR (12 downto 0);
           DRAM_BA      : OUT   STD_LOGIC_VECTOR (1 downto 0);
           DRAM_CAS_N   : OUT   STD_LOGIC;
           DRAM_CKE      : OUT   STD_LOGIC;
           DRAM_CLK      : OUT   STD_LOGIC;
           DRAM_CS_N   : OUT   STD_LOGIC;
           DRAM_DQ      : INOUT STD_LOGIC_VECTOR(15 downto 0);
           DRAM_DQM      : OUT   STD_LOGIC_VECTOR(1 downto 0);
           DRAM_RAS_N   : OUT   STD_LOGIC;
           DRAM_WE_N    : OUT   STD_LOGIC;
           
           --- Inputs from rest of the system
           address      : IN     STD_LOGIC_VECTOR (23 downto 0);
           req_read      : IN     STD_LOGIC;
           req_write   : IN     STD_LOGIC;
           data_out      : OUT     STD_LOGIC_VECTOR (31 downto 0);
           data_out_valid : OUT     STD_LOGIC;
           data_in      : IN     STD_LOGIC_VECTOR (31 downto 0);
           write_complete : out std_logic
        );
    end component;
    signal address : std_logic_vector(23 downto 0) := (others => '0');
    signal req_read : std_logic := '0';
    signal req_write : std_logic := '0';
    signal data_out :std_logic_vector(31 downto 0);
    signal data_out_valid : std_logic;
    signal data_in : std_logic_vector(31 downto 0) := (others => '0');
    signal write_complete : std_logic;
    
    signal clk : std_logic;
    signal DRAM_ADDR:std_logic_vector(12 downto 0);
    signal DRAM_BA:std_logic_vector(1 downto 0);
    signal DRAM_CAS_N:std_logic;
    signal DRAM_CKE : std_logic;
    signal DRAM_CLK : std_logic;
    signal DRAM_CS_N : std_logic;
    signal DRAM_DQ : std_logic_vector(15 downto 0);
    signal DRAM_DQM : std_logic_vector(1 downto 0);
    signal DRAM_RAS_N : std_logic;
    signal DRAM_WE_N : std_logic;
    signal data_1  : std_logic := '0';

BEGIN

    uut: sdram_controller
    PORT MAP
    (
        CLOCK_50 => clk,
        DRAM_ADDR => DRAM_ADDR,
        DRAM_BA => DRAM_BA,
        DRAM_CAS_N => DRAM_CAS_N,
        DRAM_CKE => DRAM_CKE,
        DRAM_CLK => DRAM_CLK,
        DRAM_CS_N => DRAM_CS_N,
        DRAM_DQ => DRAM_DQ,
        DRAM_DQM => DRAM_DQM,
        DRAM_RAS_N => DRAM_RAS_N,
        DRAM_WE_N => DRAM_WE_N,

        address => address,
        req_read => req_read,
        req_write => req_write,
        data_out => data_out,
        data_out_valid => data_out_valid,
        data_in => data_in,
        write_complete => write_complete
    );


    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    stim_proc: process
    begin
        wait for 1500 ns;
        address <= X"000f3c";
        data_in <= X"deadbeef";
        req_write <= '1';
        wait for 20 ns;
        req_write <= '0';
        wait until write_complete = '1';
        wait for 100 ns;
        address <= X"000f40";
        data_in <= X"beefc001";
        req_write <= '1';
        wait for 20 ns;
        req_write <= '0';
        wait until write_complete = '1';
        wait for 100 ns;
        address <= X"00ffee";
        req_read <= '1';
        wait for 20 ns;
        req_read <= '0';
        wait for 160 ns;
        req_read <= '1';
        wait for 20 ns;
        req_read <= '0';
        wait;
    end process;

read_proc: process begin
    wait until rising_edge(DRAM_CLK);
    if DRAM_RAS_N = '1' and DRAM_CAS_N = '0' and DRAM_WE_N = '1' then --read
        if data_1 = '0' then
            data_1 <= '1';
            wait for 30 ns;
            DRAM_DQ <= X"FEED";
            wait for 10 ns;
            DRAM_DQ <= X"F00D";
            wait for 10 ns;
            DRAM_DQ <= (others => 'Z');
        else
            wait for 30 ns;
            DRAM_DQ <= X"5678";
            wait for 10 ns;
            DRAM_DQ <= X"1234";
            wait for 10 ns;
            DRAM_DQ <= (others => 'Z');
        end if;
    else 
        DRAM_DQ <= (others => 'Z');
    
    end if;
end process;


end;

