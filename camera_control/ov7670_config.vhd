library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ov7670_config is
    port (
        i_sys_clk : in std_logic;
        i_rst : in std_logic;

        o_scl : out std_logic;
        o_sda : out std_logic;
        o_config_done : out std_logic 
     );
end ov7670_config;

architecture Behavioral of ov7670_config is

    ---------------
    -- I2C_SIGNALS
    ----------------
    constant c_i2c_clk_period : integer := 100_000_000 / 100_000; 
    signal clk_count : integer := 0;

    type i2c_state_type is (IDLE, START1, START2, START3, LOAD_BYTE, WRITE_LOW, WRITE_HIGH, ACK_LOW, ACK_HIGH, NEXT_BYTE, STOP1, STOP2, STOP3, I2C_DONE_STATE);
    signal i2c_state : i2c_state_type := IDLE;
    signal i2c_state_dbg : std_logic_vector(3 downto 0) := (others => '0');

    signal tick : std_logic;
    signal scl_t : std_logic := '1'; -- SCL line i2c_state
    signal sda_t : std_logic := '1'; -- SDA line i2c_state
    signal sda_en : std_logic := '0'; -- SDA line enable

    signal shift_reg : std_logic_vector(7 downto 0) := (others=>'0');
    signal byte_sel  : integer range 0 to 2 := 0;
    signal bit_count : integer range 0 to 7 := 0;
    
    signal busy_i2c : std_logic;
    signal done_i2c : std_logic;


    -----------------
    --- INIT_SIGNALS
    -----------------

    type init_state_type is (IDLE, SEND, WAIT_BUSY, WAIT_DONE, NEXT_DATA, DONE);
    signal init_state : init_state_type := IDLE;

    signal index : integer := 0;

    type reg_array is array (0 to 2) of std_logic_vector(15 downto 0);
        constant c_regs : reg_array := (
        -- Initialization and System Reset
        x"12_80", x"12_80", -- Reset
        x"12_00"           -- Setup
        x"11_00", x"0C_00", 
        x"3E_00", x"8C_00", 
        x"04_00", x"40_02", 
        x"3A_04",

        -- Matrix and Control Logic
        x"14_38", x"4F_40", 
        x"50_34", x"51_0C", 
        x"52_17", x"53_29", 
        x"54_40", x"3D_C0",

        -- Timing and Windowing
        x"11_03", x"17_11", 
        x"18_61", x"32_A4", 
        x"19_03", x"1A_7B", 
        x"03_0A",

        -- Digital Signal Processing / Image Quality
        x"0E_61", x"0F_4B", 
        x"16_02", x"1E_37", 
        x"21_02", x"22_91", 
        x"29_07", x"33_0B", 
        x"35_0B", x"37_1D", 
        x"38_71", x"39_2A", 
        x"3C_78", x"4D_40", 
        x"4E_20", x"69_00", 
        x"6B_0A", x"74_10",

        -- Backend / Calibration Registers
        x"8D_4F", x"8E_00", 
        x"8F_00", x"90_00", 
        x"91_00", x"96_00", 
        x"9A_00", x"B0_84", 
        x"B1_0C", x"B2_0E", 
        x"B3_82", x"B8_0A"
    );
    
    signal init_done : std_logic;
    signal start_i2c : std_logic;
    signal slave_address, register_address, register_data : std_logic_vector(7 downto 0) := (others=>'0');

begin

    ---------------------------------------------------------
    -- INITIALIZATION SEQUENCY
    --------------------------------------------------------

    o_config_done <= init_done;

    INIT_FSM_PROC : process(i_sys_clk)
    begin
        if rising_edge(i_sys_clk) then
            if i_rst = '1' then
                init_state <= IDLE;
                index <= 0;
                start_i2c <= '0';
                init_done <= '0';
            else
                case init_state is
                    when IDLE =>
                        index <= 0;
                        init_state <= SEND;
                        start_i2c <= '0';
                        init_done <= '0';

                    when SEND =>
                        slave_address <= X"42";
                        register_address <= c_regs(index)(15 downto 8);
                        register_data    <= c_regs(index)(7 downto 0);
                        start_i2c <= '1';
                        init_state <= WAIT_BUSY;
                    
                    when WAIT_BUSY =>
                        if busy_i2c = '1' then
                            init_state <= WAIT_DONE;
                        end if;

                    when WAIT_DONE =>
                        if done_i2c = '1' then
                            init_state <= NEXT_DATA;
                            start_i2c <= '0';
                        end if;

                    when NEXT_DATA =>
                        if index = (c_regs'length-1) then
                            init_state <= DONE;
                        else
                            index <= index + 1;
                            init_state <= SEND;
                        end if;

                    when DONE =>
                        init_done <= '1';
                        
                   when others =>
                        init_state <= IDLE;

                end case;
            end if;
        end if;
    end process;


    ----------------------------------------------------
    -- I2C
    ---------------------------------------------------

    o_sda <= sda_t when sda_en = '1' else '1'; -- forget inout
    o_scl <= scl_t;

    with i2c_state select
    i2c_state_dbg <=
        "0000" when IDLE,
        "0001" when START1,
        "0010" when START2,
        "0011" when START3,
        "0100" when LOAD_BYTE,
        "0101" when WRITE_LOW,
        "0110" when WRITE_HIGH,
        "0111" when ACK_LOW,
        "1000" when ACK_HIGH,
        "1001" when NEXT_BYTE,
        "1010" when STOP1,
        "1011" when STOP2,
        "1100" when STOP3,
        "1101" when I2C_DONE_STATE,
        "1111" when others;
    
    I2C_CLK_PROC : process(i_sys_clk)
    begin
        if rising_edge(i_sys_clk) then
            if i_rst = '1' then
                tick <= '0';
                clk_count <= 0;
            else
                if clk_count = c_i2c_clk_period/2 -1 then
                    tick <= '1';
                    clk_count <= 0;
                else
                    tick <= '0';
                    clk_count <= clk_count + 1;
                end if;
            end if;
        end if;
    end process;

    I2C_FSM_PROC : process(i_sys_clk)
    begin
        if rising_edge(i_sys_clk) then
            if i_rst = '1' then
                i2c_state <= IDLE;
                scl_t <= '1';
                sda_en <= '0';
                sda_t <= '1';

                busy_i2c <= '0';
                done_i2c <= '0';

                byte_sel <= 0;
                bit_count <= 0;

            else
                if tick = '1' then
                    case i2c_state is
                        when IDLE =>
                            busy_i2c <= '0';
                            done_i2c <= '0';
                            scl_t <= '1';
                            sda_en <= '0';
                            if start_i2c = '1' then 
                                i2c_state <= START1;
                                busy_i2c <= '1';
                                byte_sel <= 0;
                            end if;

                        when START1 =>
                            scl_t <= '1';
                            sda_en <= '0';
                            i2c_state <= START2;

                        when START2 =>
                            scl_t <= '1';
                            sda_en <= '1';
                            sda_t <= '0'; -- sda goes low while scl is high
                            i2c_state <= START3;
                        
                        when START3 =>
                            scl_t <= '0';
                            i2c_state <= LOAD_BYTE;

                        when LOAD_BYTE =>
                            if byte_sel = 0 then
                                shift_reg <= slave_address;
                            elsif byte_sel = 1 then
                                shift_reg <= register_address;
                            else
                                shift_reg <= register_data;
                            end if;
                            bit_count <= 7;
                            i2c_state <= WRITE_LOW;
                        
                        when WRITE_LOW =>
                            scl_t <= '0'; 
                            sda_en <= '1';
                            sda_t <= shift_reg(bit_count);
                            i2c_state <= WRITE_HIGH;

                        when WRITE_HIGH =>
                            scl_t <= '1';
                            if bit_count = 0 then
                                i2c_state <= ACK_LOW;
                            else
                                bit_count <= bit_count-1;
                                i2c_state <= WRITE_LOW;
                            end if;
                        
                        when ACK_LOW =>
                            scl_t <= '0';
                            sda_en <= '0';
                            i2c_state <= ACK_HIGH;

                        when ACK_HIGH =>
                            scl_t <= '1';
                            i2c_state <= NEXT_BYTE;

                        when NEXT_BYTE =>
                            if byte_sel = 2 then
                                i2c_state <= STOP1;
                            else
                                byte_sel <= byte_sel + 1;
                                i2c_state <= LOAD_BYTE;
                            end if;

                        when STOP1 =>
                            scl_t <= '0';
                            sda_en <= '1';
                            sda_t <= '0';
                            i2c_state <= STOP2;

                        when STOP2 =>
                            scl_t <= '1';
                            i2c_state <= STOP3;
                        
                        when STOP3 =>
                            sda_en <= '0';
                            i2c_state <= I2C_DONE_STATE;

                        when I2C_DONE_STATE =>
                            done_i2c <= '1';
                            busy_i2c <= '0';
                            i2c_State <= IDLE;
                    end case;
                end if;
            end if;
        end if;     
    end process;


end Behavioral;
