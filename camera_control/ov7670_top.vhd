library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ov7670_top is
    port ( 
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_pclk : in std_logic;
        i_vsync : in std_logic;
        i_href : in std_logic;
        i_data : in std_logic_vector(7 downto 0);

        o_scl : out std_logic;
        o_sda : out std_logic;
        o_pixel_data : out std_logic_vector(7 downto 0);
        o_pixel_valid : out std_logic
    );
end ov7670_top;

architecture Behavioral of ov7670_top is

    signal w_config_done : std_logic; 
    signal config_done_sync1, config_done_sync2 : std_logic;
    
begin

    -- Camera register configuration
    ov7670_config_inst : entity work.ov7670_config
        port map (
            i_sys_clk => i_clk, -- 100mhz
            i_rst => i_rst,

            o_sioc => o_scl,
            o_siod => o_sda,
            o_config_done => w_config_done
        );

    SYNCHRONIZING_PROC: process(i_pclk)
    begin
        if rising_edge(i_pclk) then
            config_done_sync1 <= w_config_done;
            config_done_sync2 <= config_done_sync1;
        end if;
    end process;

    -- Camera capture
    ov7670_capture_inst : entity work.ov7670_capture
        port map (
            i_pclk => i_pclk, -- 24mhz
            i_rst => i_rst,
            i_vsync => i_vsync,
            i_href => i_href,
            i_data => i_data,
            i_config_done => config_done_sync2,

            o_pixel => o_pixel_data,
            o_pixel_valid => o_pixel_valid,
            o_half_pclk => open
        );

end Behavioral;
