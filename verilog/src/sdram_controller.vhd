------------------------------------------------------
-- FSM for a SDRAM controller
--
-- Version 0.1 - Ready to simulate
--
-- Author: Mike Field (hamster@snap.net.nz)
--
-- Feel free to use it however you would like, but
-- just drop me an email to say thanks.
-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sdram_controller is
    PORT (
    CLOCK_50        : IN STD_LOGIC;
    
    -- Signals to/from the SDRAM chip
    DRAM_ADDR    : OUT    STD_LOGIC_VECTOR (12 downto 0);
    DRAM_BA        : OUT    STD_LOGIC_VECTOR (1 downto 0);
    DRAM_CAS_N    : OUT    STD_LOGIC;
    DRAM_CKE        : OUT    STD_LOGIC;
    DRAM_CLK        : OUT    STD_LOGIC;
    DRAM_CS_N    : OUT    STD_LOGIC;
    DRAM_DQ        : INOUT STD_LOGIC_VECTOR(15 downto 0);
    DRAM_DQM        : OUT    STD_LOGIC_VECTOR(1 downto 0);
    DRAM_RAS_N    : OUT    STD_LOGIC;
    DRAM_WE_N     : OUT    STD_LOGIC;
    
    --- Inputs from rest of the system
    address        : IN      STD_LOGIC_VECTOR (23 downto 0);
    req_read        : IN      STD_LOGIC;
    req_write    : IN      STD_LOGIC;
    data_out        : OUT      STD_LOGIC_VECTOR (31 downto 0);
    data_out_valid : OUT      STD_LOGIC;
    data_in        : IN      STD_LOGIC_VECTOR (31 downto 0);
    write_complete : OUT      STD_LOGIC
    );
end entity;
    
    
architecture rtl of sdram_controller is

    
    type reg is record
        state         : std_logic_vector(8 downto 0);

        address      : std_logic_vector(12 downto 0);
        bank            : std_logic_vector( 1 downto 0);

        init_counter: std_logic_vector(14 downto 0);
        rf_counter    : std_logic_vector( 9 downto 0);
        rf_pending     : std_logic;

        rd_pending     : std_logic;
        wr_pending     : std_logic;
        act_row         : std_logic_vector(12 downto 0);

        data_out_low: std_logic_vector(15 downto 0);
        data_out_valid : std_logic;


        dq_masks        : std_logic_vector(1 downto 0);
        write_complete : std_logic;
    end record;
    component sdram_clk_gen
    PORT
    (
        inclk0: IN  STD_LOGIC;
        c0        : OUT STD_LOGIC;
        c1        : OUT STD_LOGIC
    );
    end component;
    signal r : reg := ((others => '0'), (others => '0'), (others => '0'),
    "000000000000000", (others => '0'), '0', '0', '0', (others => '0'),
    (others => '0'), '0', (others => '0'),'0');
    signal n : reg;
    
    -- Vectors for each SDRAM 'command'
    --- CS_N, RAS_N, CAS_N, WE_N 
    constant cmd_nop    : std_logic_vector(3 downto 0) := "0111";
    constant cmd_read  : std_logic_vector(3 downto 0) := "0101";    -- Must be sure A10 is low.
    constant cmd_write : std_logic_vector(3 downto 0) := "0100";
    constant cmd_act    : std_logic_vector(3 downto 0) := "0011";
    constant cmd_pre    : std_logic_vector(3 downto 0) := "0010";  -- Must set A10 to '1'.
    constant cmd_ref    : std_logic_vector(3 downto 0) := "0001";
    constant cmd_mrs      : std_logic_vector(3 downto 0) := "0000"; -- Mode register set
    -- State assignments
    constant s_init_nop  : std_logic_vector(8 downto 0) := "00000" & cmd_nop;
    constant s_init_pre  : std_logic_vector(8 downto 0) := "00000" & cmd_pre;
    constant s_init_ref  : std_logic_vector(8 downto 0) := "00000" & cmd_ref;
    constant s_init_mrs  : std_logic_vector(8 downto 0) := "00000" & cmd_mrs;
    
    constant s_idle  : std_logic_vector(8 downto 0) := "00001" & cmd_nop;
    
    constant s_rf0    : std_logic_vector(8 downto 0) := "00010" & cmd_ref;
    constant s_rf1    : std_logic_vector(8 downto 0) := "00011" & cmd_nop;
    constant s_rf2    : std_logic_vector(8 downto 0) := "00100" & cmd_nop;
    constant s_rf3    : std_logic_vector(8 downto 0) := "00101" & cmd_nop;
    constant s_rf4    : std_logic_vector(8 downto 0) := "00110" & cmd_nop;
    constant s_rf5    : std_logic_vector(8 downto 0) := "00111" & cmd_nop;

    constant s_ra0    : std_logic_vector(8 downto 0) := "01000" & cmd_act;
    constant s_ra1    : std_logic_vector(8 downto 0) := "01001" & cmd_nop;
    constant s_ra2    : std_logic_vector(8 downto 0) := "01010" & cmd_nop;

    constant s_dr0    : std_logic_vector(8 downto 0) := "01011" & cmd_pre;
    constant s_dr1    : std_logic_vector(8 downto 0) := "01100" & cmd_nop;

    constant s_wr0    : std_logic_vector(8 downto 0) := "01101" & cmd_write;
    constant s_wr1    : std_logic_vector(8 downto 0) := "01110" & cmd_nop;
    constant s_wr2    : std_logic_vector(8 downto 0) := "01111" & cmd_nop;
    constant s_wr3    : std_logic_vector(8 downto 0) := "10000" & cmd_nop;

    constant s_rd0    : std_logic_vector(8 downto 0) := "10001" & cmd_read;
    constant s_rd1    : std_logic_vector(8 downto 0) := "10010" & cmd_nop;
    constant s_rd2    : std_logic_vector(8 downto 0) := "10011" & cmd_nop;
    constant s_rd3    : std_logic_vector(8 downto 0) := "10100" & cmd_nop;
    constant s_rd4    : std_logic_vector(8 downto 0) := "10101" & cmd_read;
    constant s_rd5    : std_logic_vector(8 downto 0) := "10110" & cmd_nop;
    constant s_rd6    : std_logic_vector(8 downto 0) := "10111" & cmd_nop;
    constant s_rd7    : std_logic_vector(8 downto 0) := "11000" & cmd_nop;
    constant s_rd8    : std_logic_vector(8 downto 0) := "11001" & cmd_nop;
    constant s_rd9    : std_logic_vector(8 downto 0) := "11011" & cmd_nop;

    constant s_drdr0 : std_logic_vector(8 downto 0) := "11101" & cmd_pre;
    constant s_drdr1 : std_logic_vector(8 downto 0) := "11110" & cmd_nop;
    constant s_drdr2 : std_logic_vector(8 downto 0) := "11111" & cmd_nop;
    
    signal addr_row : std_logic_vector(12 downto 0);
    signal addr_bank: std_logic_vector(1 downto 0);
    signal addr_col : std_logic_vector(9 downto 0);

    signal captured : std_logic_vector(15 downto 0);
    
    signal clock_100             : std_logic;
    signal clock_100_delayed_3ns : std_logic;
begin
    -- Addressing is in 32 bit words - twice that of the DRAM width,
    -- so each burst of four access two system words.
    addr_row  <= address(23 downto 11);
    addr_bank <= address(10 downto 9);
    addr_col  <= address(8 downto  1) & "00";
    
sdram_clk_pll: sdram_clk_gen

    -- Generate the 100MHz clock and the same phase shifted by 3ns
    PORT MAP
    (
        inclk0     => CLOCK_50,
        c0            => clock_100,
        c1            => clock_100_delayed_3ns
    );

    DRAM_CLK            <= clock_100_delayed_3ns;
    DRAM_CKE         <= '1';
    DRAM_CS_N         <= r.state(3);
    DRAM_RAS_N         <= r.state(2);
    DRAM_CAS_N         <= r.state(1);
    DRAM_WE_N         <= r.state(0);
    DRAM_ADDR        <= r.address;
    DRAM_BA             <= r.bank;
    DATA_OUT            <= captured & r.data_out_low;
    DRAM_DQM         <= r.dq_masks;
    data_out_valid <= r.data_out_valid;
    write_complete <= r.write_complete;

    process (r, address, req_read, req_write, addr_row, addr_bank, addr_col, data_in, captured)
    begin
        -- copy the existing values
        n <= r;
        if req_read = '1' then
            n.rd_pending <= '1';
        end if;
        
        if req_write = '1' then
            n.wr_pending <= '1';
        end if;
        
        n.dq_masks      <= "11";
        
        -- first off, do we need to perform a refresh cycle ASAP?
        if r.rf_counter = 770 then -- 781 = 64,000,000ns / 8192 / 10ns
            n.rf_counter <= (others => '0');
            n.rf_pending <= '1';
        else
            -- only start looking for refreshes outside of the initialisation state.
            if not(r.state(8 downto 4) = s_init_nop(8 downto 4)) then
                n.rf_counter <= r.rf_counter + 1;
            end if;
        end if;
        
        -- Set the data bus into HIZ, high and low bytes masked
        DRAM_DQ     <= (others => 'Z');
        n.init_counter <= r.init_counter-1;
        
        -- Process the FSM
        case r.state(8 downto 4) is
            when s_init_nop(8 downto 4) =>
                n.state      <= s_init_nop;
                n.address <= (others => '0');
                n.bank     <= (others => '0');
                n.rf_counter    <= (others => '0');
                n.data_out_valid <= '1';
                
                -- T-130, precharge all banks.
                if r.init_counter = "000000010000010" then
                    n.state      <= s_init_pre;
                    n.address(10)    <= '1';
                end if;

                -- T-127, T-111, T-95, T-79, T-63, T-47, T-31, T-15, the 8 refreshes
                
                if r.init_counter(14 downto 7) = 0 and r.init_counter(3 downto 0) = 15 then
                    n.state      <= s_init_ref;
                end if;
                
                -- T-3, the load mode register 
                if r.init_counter = 3 then
                    n.state      <= s_init_mrs;
                                    -- Mode register is as follows:
                                    -- resvd    wr_b    OpMd    CAS=3    Seq    bust=4
                     n.address    <= "000" & "0" & "00" & "011" & "0" & "010";
                                    -- resvd
                    n.bank        <= "00";
                end if;

                
                -- T-1 The switch to the FSM (first command will be a NOP
                if r.init_counter = 1 then
                    n.state             <= s_idle;
                end if;

            ------------------------------
            -- The Idle section
            ------------------------------
            when s_idle(8 downto 4) =>
                n.state <= s_idle;

                -- do we have to activate a row?
                if r.rd_pending = '1' or r.wr_pending = '1' then
                    n.state          <= s_ra0;
                    n.address      <= addr_row;
                    n.act_row     <= addr_row;
                end if;

                -- refreshes take priority over everything
                if r.rf_pending = '1' then
                    n.state          <= s_rf0;
                    n.rf_pending <= '0';
                end if;
            ------------------------------
            -- Row activation
            -- s_ra2 is also the "idle with active row" state and provides
            -- a resting point between operations on the same row
            ------------------------------
            when s_ra0(8 downto 4) =>
                n.state          <= s_ra1;
            when s_ra1(8 downto 4) =>
                n.state          <= s_ra2;
            when s_ra2(8 downto 4) =>
                -- we can stay in this state until we have something to do
                n.state         <= s_ra2;

                -- If there is a read pending, deactivate the row
                if r.rd_pending = '1' or r.wr_pending = '1' then
                    n.state      <= s_dr0;
                    n.address(10) <= '1';
                end if;
                
                -- unless we have a read to perform on the same row? do that instead
                if r.rd_pending = '1' and r.act_row = addr_row then
                    n.state      <= s_rd0;
                    n.address <= "000" & addr_col;
                    n.bank     <= addr_bank;
                    n.dq_masks <= "00";
                    n.rd_pending <= '0';
                end if;
                
                -- unless we have a write on the same row? writes take priroty over reads
                if r.wr_pending = '1' and r.act_row = addr_row then
                    n.state      <= s_wr0;
                    n.address <= "000" & addr_col;
                    n.bank     <= addr_bank;
                    n.dq_masks<= "00";
                    n.wr_pending <= '0';
                end if;
                
                -- But refreshes take piority over everything!
                if r.rf_pending = '1' then
                    n.state      <= s_dr0;
                    n.address(10) <= '1';
                end if;
                
            ------------------------------------------------------
            -- Deactivate the current row and return to idle state
            ------------------------------------------------------
            when s_dr0(8 downto 4) =>
                n.state <= s_dr1;
            when s_dr1(8 downto 4) =>
                n.state <= s_idle;

            ------------------------------
            -- The Refresh section
            ------------------------------
            when s_rf0(8 downto 4) =>
                n.state <= s_rf1;
            when s_rf1(8 downto 4) =>
                n.state <= s_rf2;
            when s_rf2(8 downto 4) =>
                n.state <= s_rf3;
            when s_rf3(8 downto 4) =>
                n.state <= s_rf4;
            when s_rf4(8 downto 4) =>
                n.state <= s_rf5;
            when s_rf5(8 downto 4) =>
                n.state <= s_idle;
            ------------------------------
            -- The Write section
            ------------------------------
            when s_wr0(8 downto 4) =>
                n.write_complete <= '1';
                n.state     <= s_wr1;
                n.address <= "000" & addr_col;
                n.bank     <= addr_bank;
                DRAM_DQ      <= data_in(15 downto 0);
                n.dq_masks<= "00";
            when s_wr1(8 downto 4) =>
                n.state     <= s_wr2;
                DRAM_DQ      <= data_in(31 downto 16);
                n.dq_masks<= "00";
            when s_wr2(8 downto 4) =>
                DRAM_DQ      <= data_in(15 downto 0);
                n.state      <= s_wr3;
                n.dq_masks<= "00";
                n.write_complete <= '0';
            when s_wr3(8 downto 4) =>
                -- Default to the idle+row active state
                n.state      <= s_ra2;
                DRAM_DQ      <= data_in(31 downto 16);
                n.dq_masks<= "11";
                
                -- If there is a read or write then deactivate the row
                if r.rd_pending = '1' or r.wr_pending = '1' then
                    n.state            <= s_dr0;
                    n.address(10) <= '1';
                    n.write_complete <= '0';
                end if;

                -- But if there is a read pending in the same row, do that
                if r.rd_pending = '1' and r.act_row = addr_row then
                    n.state      <= s_rd0;
                    n.address <= "000" & addr_col;
                    n.bank     <= addr_bank;
                    n.dq_masks <= "00";
                    n.rd_pending <= '0';
                end if;

                -- unless there is a write pending in the same row, do that
                if r.wr_pending = '1' and r.act_row = addr_row then
                    n.state      <= s_wr0;
                    n.address <= "000" & addr_col;
                    n.bank     <= addr_bank;
                    n.dq_masks<= "00";
                    n.wr_pending <= '0';
                end if;

                -- But always try and refresh if one is pending!
                if r.rf_pending = '1' then
                    n.state         <= s_dr0;
                    n.address(10) <= '1';
                end if;
            
            ------------------------------
            -- The Read section
            ------------------------------
            when s_rd0(8 downto 4) =>
                n.data_out_valid <= '0';
                n.state <= s_rd1;
                n.dq_masks <= "00";
            when s_rd1(8 downto 4) =>
                n.state <= s_rd2;
                n.dq_masks <= "00";
            when s_rd2(8 downto 4) =>
                n.state <= s_rd3;
                n.dq_masks <= "00";
            when s_rd3(8 downto 4) =>
                -- default is to end the read with the row open
                n.state <= s_rd7;

                -- otherwise if there is a read or write prepare to deactivate the row.
                -- (This is overridden if the read/write is to the same page)
                if r.rd_pending = '1' or r.wr_pending = '1' then
                    n.write_complete <= '0';
                    n.state         <= s_drdr0;
                    n.address(10) <= '1';
                end if;

                -- override if the write is from the same row
                if r.wr_pending = '1' and r.act_row = addr_row then
                    n.state <= s_rd7;
                end if;
            
                -- override if the read is from the same row
                if r.rd_pending = '1' and r.act_row = addr_row then
                    n.state      <= s_rd4;
                    n.address <= "000" & addr_col;
                    n.bank     <= addr_bank;
                    n.dq_masks<= "00";
                end if;

                    -- If a refresh is pending then always deactivate the row
                if r.rf_pending = '1' then 
                    n.state <= s_drdr0;
                    n.address(10) <= '1';
                end if;
                n.data_out_low <= captured;
                n.data_out_valid <= '1';    
            when s_rd4(8 downto 4) =>
                n.state <= s_rd5;
                n.dq_masks<= "00";
            when s_rd5(8 downto 4) =>
                n.state <= s_rd6;
                n.data_out_low <= captured;
                n.data_out_valid <= '1';    
                n.dq_masks<= "00";
            when s_rd6(8 downto 4) =>
                n.state <= s_rd3;
                n.dq_masks<= "00";
            when s_rd7(8 downto 4) =>
                n.state <= s_rd8;
                n.data_out_low <= captured;
                n.data_out_valid <= '1';    
            when s_rd8(8 downto 4) =>
                n.state <= s_rd9;
            when s_rd9(8 downto 4) =>
                -- by default go to the idle-with-row-active state
                n.state <= s_ra2;
                n.data_out_low <= captured;
                n.data_out_valid <= '1';    
                
                -- otherwise if there is a read or write prepare to deactivate the row.
                -- (This is overridden if the read/write is to the same row)
                if r.rd_pending = '1' or r.wr_pending = '1' then
                    n.write_complete <= '0';
                    n.state <= s_dr0;
                    n.address(10) <= '1';
                end if;
                
                -- this is to catch if a read has turned up since the choices at state s_dr3
                if r.rd_pending = '1' and r.act_row = addr_row then
                    n.state <= s_rd0;
                    n.address <= "000" & addr_col;
                    n.bank     <= addr_bank;
                    n.dq_masks <= "00";
                    n.rd_pending <= '0';
                end if;

                -- this is to catch if a read has turned up since the choices at state s_dr3
                if r.wr_pending = '1' and r.act_row = addr_row then
                    n.state <= s_wr0;
                    n.address <= "000" & addr_col;
                    n.bank     <= addr_bank;
                    n.dq_masks<= "00";
                    n.wr_pending <= '0';
                end if;
                
                if r.rf_pending = '1' then
                    n.state <= s_dr0;
                    n.address(10) <= '1';
                end if;
                
            ------------------------------
            -- The Deactivate row during read section
            ------------------------------
            when s_drdr0(8 downto 4) =>
                n.state <= s_drdr1;
            when s_drdr1(8 downto 4) =>
                n.state <= s_drdr2;
                n.data_out_low <= captured;
                n.data_out_valid <= '1';    
            when s_drdr2(8 downto 4) =>
                n.state <= s_idle;

                if r.rf_pending = '1' then
                    n.state <= s_rf0;
                end if;
                
                if r.rd_pending = '1' or r.wr_pending = '1' then
                    n.write_complete <= '0';
                    n.state         <= s_ra0;
                    n.address     <= addr_row;
                    n.act_row     <= addr_row;
                    n.bank         <= addr_bank;
                end if;

            when others =>
                n.state <= s_init_nop;
        end case;
    end process;
    
    --- The clock driven logic
    process (clock_100, n)
    begin
        if clock_100'event and clock_100 = '1' then
            r <= n;
        end if;
    end process;

    process (clock_100_delayed_3ns, dram_dq)
    begin
        if clock_100_delayed_3ns'event and clock_100_delayed_3ns = '1' then
            captured <= dram_dq;
        end if;
    end process;

end rtl;
