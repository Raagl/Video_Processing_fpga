library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ov7670_capture is
    port (
        i_pclk : in std_logic;
        i_rst : in std_logic;
        i_vsync : in std_logic;
        i_href : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        i_config_done : in std_logic;

        o_pixel : out std_logic_vector(7 downto 0);
        o_pixel_valid : out std_logic;
        o_half_pclk : out std_logic
    );
end ov7670_capture;


architecture rtl of ov7670_capture is

    signal half_pclk : std_logic := '0';
    signal data_reg : std_logic_vector(7 downto 0) := (others => '0');

begin

    o_half_pclk <= half_pclk;
    o_pixel <= data_reg;

    -- Captures YCbCr 1 byte per pixel. 
    -- For RGB565, you would need to capture two bytes per pixel and combine them accordingly.
    DATA_CAPTURE_PROC : process(i_pclk, i_rst)
    begin
        if i_rst = '1' then
            data_reg <= (others => '0');
            o_pixel_valid <= '0';
            half_pclk <= '0';
        elsif rising_edge(i_pclk) then
            if i_config_done = '1' then
                half_pclk <= not half_pclk; -- pclk / 2
                if i_vsync = '0' then 
                    if i_href = '1' and half_pclk = '1' then
                        data_reg <= i_data;
                        o_pixel_valid <= '1';
                    else
                        o_pixel_valid <= '0';
                    end if;
                else
                    o_pixel_valid <= '0';
                end if;
            else
                o_pixel_valid <= '0';
            end if;
        end if;
    end process;

end architecture;