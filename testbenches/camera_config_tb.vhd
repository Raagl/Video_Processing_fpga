library IEEE;
library STD; 
use STD.ENV.ALL;
use IEEE.STD_LOGIC_1164.ALL;

entity camera_config_tb is
end camera_config_tb;

architecture Behavioral of camera_config_tb is

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal sioc, siod : std_logic;
    signal config_done : std_logic;

begin

    UUT : entity work.ov7670_config
        port map (
            i_sys_clk => clk,
            i_rst => rst,

            o_scl => sioc,
            o_sda => siod,
            o_config_done => config_done
        );

    clk <= not clk after 10 ns; -- 100 MHz clock
    
    TEST_PROC : process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        
        wait until config_done = '1'; 
        
        if config_done = '1' then
            report "Configuration SUCCESSFUL" severity note;
        else
            report "Configuration TIMED OUT - FSM is stuck!" severity note;
        end if;
        finish;
    end process;

end Behavioral;
