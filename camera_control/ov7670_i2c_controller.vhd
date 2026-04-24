library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 

entity ov7670_i2c_controller is
    generic (
        -- Add any generic parameters if needed
        I2C_CLK_FREQ : integer := 100_000; -- I2C clock frequency in Hz
        SYS_CLK_FREQ : integer := 100_000_000 -- System clock frequency in Hz
    );
    port (
        i_sys_clk : in std_logic; -- System clock
        i_rst   : in std_logic;
        i_data_valid : in std_logic;
        i_slave_addr : in std_logic_vector(7 downto 0);
        i_reg_addr   : in std_logic_vector(7 downto 0);
        i_reg_data   : in std_logic_vector(7 downto 0);
        
        o_scl   : out std_logic; 
        o_sda  : out std_logic;
        o_busy  : out std_logic;
        o_done  : out std_logic

     );
end ov7670_i2c_controller;

architecture rtl of ov7670_i2c_controller is

    type state_type is (IDLE, LOAD_DATA, START_STATE, WRITE_SLAVE_ADDR, ACK1, WRITE_REG_ADDR, ACK2, WRITE_REG_DATA, ACK3, STOP_STATE);
    signal state : state_type;

    signal scl_t : std_logic := '1'; -- SCL line state
    signal sda_t : std_logic := '1'; -- SDA line state
    signal sda_en : std_logic := '0'; -- SDA line enable

    signal data_valid_d : std_logic := '0';
    signal load_done : std_logic := '0';
    signal slave_addr :std_logic_vector(7 downto 0) := (others => '0');
    signal reg_addr : std_logic_vector(7 downto 0) := (others => '0');
    signal reg_data : std_logic_vector(7 downto 0) := (others => '0');

    signal busy : std_logic := '0';
    signal done : std_logic := '0';
    signal ack_err : std_logic := '0';
    
    constant clk_count4 : integer := SYS_CLK_FREQ / (I2C_CLK_FREQ);
    constant clk_count1 : integer :=  clk_count4 / 4;
    signal pulse : integer range 0 to 3 := 0;
    signal pulse_counter : integer range 0 to clk_count4 := 0;

    signal bit_count : integer range 0 to 7 := 0;

begin

    -- Output assignments
    o_scl <= scl_t;
    o_sda <= sda_t when sda_en = '1' else '1';
    o_busy <= busy;
    o_done <= done;

    -- register data
    slave_addr <= i_slave_addr;
    reg_addr <= i_reg_addr;
    reg_data <= i_reg_data;

    PULSE_GEN_PROC : process(i_sys_clk, i_rst)
    begin
        if i_rst = '1' then
            pulse <= 0;
            pulse_counter <= 0;
        elsif rising_edge(i_sys_clk) then
            if busy = '0' then
                pulse <= 0;
                pulse_counter <= 0;
            else
                if pulse_counter = clk_count1 - 1 then
                    pulse <= 1;
                    pulse_counter <= pulse_counter + 1;
                elsif pulse_counter = clk_count1 * 2 - 1 then
                    pulse <= 2;
                    pulse_counter <= pulse_counter + 1;
                elsif pulse_counter = clk_count1 * 3 - 1 then
                    pulse <= 3;
                    pulse_counter <= pulse_counter + 1;
                elsif pulse_counter = clk_count4 - 1 then
                    pulse <= 0;
                    pulse_counter <= 0;
                else
                    pulse_counter <= pulse_counter + 1; 
                end if;
            end if;
        end if;
    end process;

    -- State machine process
    I2C_FSM_PROC : process(i_sys_clk, i_rst)
    begin
        if i_rst = '1' then
            state <= IDLE;
            scl_t <= '1';
            sda_t <= '1';
            sda_en <= '0';
            busy <= '0';
            done <= '0';
            bit_count <= 0;
            ack_err <= '0';

        elsif rising_edge(i_sys_clk) then

            data_valid_d <= i_data_valid;

            case state is
                when IDLE =>
                    busy <= '0';
                    done <= '0';
                    if i_data_valid = '1' and data_valid_d = '0' then
                        busy <= '1';
                        state <= START_STATE;
                    end if;

                when START_STATE =>
                    sda_en <= '1'; -- drive sda
                    case pulse is
                        when 0 => 
                            sda_t <= '1';
                            scl_t <= '1';
                        when 1 =>
                            sda_t <= '1'; 
                            scl_t <= '1';
                        when 2 =>
                            sda_t <= '0'; -- start condition: sda goes low while scl is high
                            scl_t <= '1'; 
                        when 3 =>
                            sda_t <= '0';
                            scl_t <= '1'; 
                    end case;
                    if pulse_counter = clk_count4 - 1 then
                        state <= WRITE_SLAVE_ADDR; 
                        bit_count <= 0;
                    else
                        state <= START_STATE;
                    end if;

                when WRITE_SLAVE_ADDR =>
                    sda_en <= '1'; -- drive sda to send address
                    if bit_count < 8 then
                        case pulse is
                            when 0 =>
                                scl_t <= '0';
                                -- write address bit on falling edge of scl
                                sda_t <= slave_addr(7 - bit_count); -- send MSB first
                            when 1 =>
                                scl_t <= '0'; 
                            when 2 =>
                                -- sda remains stable while scl is high
                                scl_t <= '1';
                            when 3 =>
                                scl_t <= '1'; 
                        end case;
                        if pulse_counter = clk_count4 - 1 then
                            state <= WRITE_SLAVE_ADDR;
                            bit_count <= bit_count + 1;
                        end if;
                    else
                        state <= ACK1;
                        bit_count <= 0;
                    end if;

                when ACK1 =>
                    sda_en <= '0'; -- release sda to read ACK
                    case pulse is
                        when 0 => 
                            scl_t <= '0';
                            sda_t <= '0'; 
                        when 1 =>
                            scl_t <= '0'; 
                            sda_t <= '0';
                        when 2 =>
                            scl_t <= '1';
                            -- Force sda high, blind transmission
                            sda_t <= '1'; -- sda = 1 means NACK, sda = 0 means ACK
                            ack_err <= '0';
                        when 3 =>
                            scl_t <= '1';
                    end case;
                    if pulse_counter = clk_count4 - 1 then
                        if ack_err = '0' then
                            state <= WRITE_REG_ADDR;
                        else
                            state <= STOP_STATE; -- if NACK, go to stop condition
                        end if;
                    else
                        state <= ACK1; 
                    end if;

                when WRITE_REG_ADDR =>
                    sda_en <= '1'; 
                    if bit_count < 8 then
                        case pulse is
                            when 0 =>
                                scl_t <= '0';
                                sda_t <= reg_addr(7 - bit_count); -- send MSB first
                            when 1 =>
                                scl_t <= '0'; 
                            when 2 =>
                                scl_t <= '1';
                            when 3 =>
                                scl_t <= '1'; 
                        end case;
                        if pulse_counter = clk_count4 - 1 then
                            state <= WRITE_REG_ADDR;
                            bit_count <= bit_count + 1;
                        end if;
                    else
                        state <= ACK2;
                        bit_count <= 0;
                    end if;

                when ACK2 => 
                    sda_en <= '0';
                    case pulse is
                        when 0 =>
                            scl_t <= '0';
                            sda_t <= '0'; 
                        when 1 =>
                            scl_t <= '0'; 
                            sda_t <= '0';
                        when 2 =>
                            scl_t <= '1';
                            -- Force sda high, blind transmission
                            sda_t <= '1'; -- sda = 1 means NACK, sda = 0 means ACK
                            ack_err <= '0';
                        when 3 =>
                            scl_t <= '1';
                    end case;
                    if pulse_counter = clk_count4 - 1 then
                        if ack_err = '0' then
                            state <= WRITE_REG_DATA;
                        else
                            state <= STOP_STATE; -- if NACK, go to stop condition
                        end if;
                    else
                        state <= ACK2; 
                    end if;
 
                when WRITE_REG_DATA =>
                    sda_en <= '1'; 
                    if bit_count <= 7 then
                        case pulse is
                            when 0 =>
                                scl_t <= '0';
                                sda_t <= reg_data(7 - bit_count); -- send MSB first
                            when 1 =>
                                scl_t <= '0'; 
                            when 2 =>
                                scl_t <= '1';
                            when 3 =>
                                scl_t <= '1'; 
                        end case;
                        if pulse_counter = clk_count4 - 1 then
                            state <= WRITE_REG_DATA;
                            bit_count <= bit_count + 1;
                        end if;
                    else
                        state <= ACK3;
                        bit_count <= 0;
                    end if;

                when ACK3 =>
                    sda_en <= '0'; 
                    case pulse is
                        when 0 =>
                            scl_t <= '0';
                            sda_t <= '0'; 
                        when 1 =>
                            scl_t <= '0'; 
                            sda_t <= '0';
                        when 2 =>
                            scl_t <= '1';
                            -- Force sda high, blind transmission
                            sda_t <= '1'; -- sda = 1 means NACK, sda = 0 means ACK
                            ack_err <= '0';
                        when 3 =>
                            scl_t <= '1';
                    end case;
                    if pulse_counter = clk_count4 - 1 then
                        if ack_err = '0' then
                            state <= STOP_STATE;
                        else
                            state <= STOP_STATE;
                        end if;
                    else
                        state <= ACK3; 
                    end if;

                when STOP_STATE =>
                    bit_count <= 0;
                    sda_en <= '1'; -- drive sda to send stop condition
                    case pulse is
                        when 0 =>
                            scl_t <= '1';
                            sda_t <= '0';
                        when 1 =>
                            scl_t <= '1';
                            sda_t <= '0';
                        when 2 =>
                            scl_t <= '1';
                            sda_t <= '1';
                        when 3 =>
                            scl_t <= '1';
                            sda_t <= '1'; -- stop condition: sda goes high while scl is high
                    end case;
                    if pulse_counter = clk_count4 - 1 then
                        state <= IDLE; 
                        busy <= '0';
                        done <= '1';
                    else
                        state <= STOP_STATE;
                    end if;
                
                when others =>
                    state <= IDLE; 
            end case;
        end if;
    end process;                    
end rtl;
