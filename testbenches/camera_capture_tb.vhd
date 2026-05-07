library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library STD; 
use STD.ENV.ALL;

entity camera_capture_tb is
end camera_capture_tb;

architecture Behavioral of camera_capture_tb is

    constant clock_period : time := 40 ns; -- roughly 24mhz

    signal pclk : std_logic := '0';
    signal rst : std_logic := '0';

    signal vsync, href : std_logic := '0';
    signal config_done : std_logic := '0';
    signal data : std_logic_vector(7 downto 0) := (others => '0');

    signal pixel : std_logic_vector(7 downto 0) := (others => '0');
    signal pixel_valid : std_logic := '0';
    signal half_pclk : std_logic;

begin

    UUT_OV7670_CAPTURE : entity work.ov7670_capture
        port map (
            i_pclk => pclk,
            i_rst => rst,
            i_vsync => vsync,
            i_href => href,
            i_data => data,
            i_config_done => config_done,

            o_pixel => pixel,
            o_pixel_valid => pixel_valid,
            o_half_pclk => half_pclk
        );

    CLOCK_GENERATION_PROC : process
    begin
        while true loop
            pclk <= '1';
            wait for clock_period / 2;
            pclk <= '0';
            wait for clock_period / 2;
        end loop;
    end process;

    TEST_PROC : process
        variable data_integer : integer := 0;
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        
        config_done <= '1';

        -- Vertical frame
        vsync <= '1';
        wait for 5*clock_period;
        vsync <= '0'; --vertical blanking
        wait for 20*clock_period;
        
        -- Horizontal frame
        -- send 3 rows (instead of 480)
        for row in 0 to 499 loop 

            href <= '0'; --horizontal blanking
            wait for 10*clock_period;
            href <=  '1';
            -- Send 32 pixels (instead of 640)
            for col in 0 to 639 loop
                data <= std_logic_vector (to_unsigned(data_integer,8));
                data_integer := data_integer + 1;
                wait for clock_period;
            end loop;
            href <= '0';
        end loop;
        wait for 50 * clock_period;
        assert false report "Capture done" severity note;
        finish;
    end process;

end Behavioral;


