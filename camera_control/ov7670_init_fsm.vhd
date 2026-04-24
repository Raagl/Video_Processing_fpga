library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ov7670_init_fsm is
    generic (
        CAMERA_ADDRESS : std_logic_vector(7 downto 0) := X"42" 
    );
    port (
        i_sys_clk : in std_logic;
        i_rst : in std_logic;

        i_done : in std_logic;

        i_command : in std_logic_vector(15 downto 0);
        i_finished : in std_logic;

        o_valid_data : out std_logic;
        o_slave_addr : out std_logic_vector(7 downto 0);
        o_register_addr : out std_logic_vector(7 downto 0);
        o_register_data : out std_logic_vector(7 downto 0);

        o_advance : out std_logic;
        
        o_init_done : out std_logic
     );
end ov7670_init_fsm;

architecture Behavioral of ov7670_init_fsm is

    type state_type is (IDLE, START, WAIT_FOR_DONE, NEXT_REGISTER, WAIT_FOR_ADVANCE, DONE);
    signal state : state_type := IDLE;
    signal done_d: std_logic;

begin

    INIT_FSM : process(i_sys_clk)
    begin
        if rising_edge(i_sys_clk) then
            if i_rst = '1' then
                state <= IDLE;
                o_valid_data <= '0';
                o_advance <= '0';
                o_init_done <= '0';
            else
                o_valid_data <= '0';
                o_advance <= '0'; 
                done_d <= i_done;
                
                case state is
                    when IDLE =>
                        o_init_done <= '0';
                        state <= START;

                    when START =>
                        -- load data
                        -- MSB first
                        o_slave_addr <= CAMERA_ADDRESS(7 downto 0);
                        o_register_addr <= i_command(15 downto 8);
                        o_register_data <= i_command(7 downto 0);
                        o_valid_data <= '1';
                        state <= WAIT_FOR_DONE;

                    when WAIT_FOR_DONE =>
                        if i_done = '1' and done_d = '0' then -- rising_edge
                            state <= NEXT_REGISTER;
                        else
                            state <= WAIT_FOR_DONE;
                            o_valid_data <= '1';
                        end if;

                    when NEXT_REGISTER =>
                        if i_finished = '1' then
                            state <= DONE;
                        else
                            o_advance <= '1';
                            state <= WAIT_FOR_ADVANCE; -- wait for clock cycle
                        end if;
                    
                    when WAIT_FOR_ADVANCE =>
                        state <= START; -- Load next register

                    when DONE =>
                        -- Stay in DONE until reset
                        o_init_done <= '1';
                        state <= DONE;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
