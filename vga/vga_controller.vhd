library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
    generic (
        TOTAL_COLS : integer := 800;
        TOTAL_ROWS : integer := 521;
        HOR_SYNC_TIME : integer := 96;
        HOR_BACK_PORCH : integer := 48;
        HOR_DISPLAY : integer := 640;
        HOR_FRONT_PORCH : integer := 16;
        V_SYNC_TIME : integer := 2;
        V_BACK_PORCH : integer := 29;
        V_DISPLAY : integer := 480;
        V_FRONT_PORCH : integer := 10
    );
    Port (
        i_clk_vga   : in  std_logic;  -- 25 MHz clock
        i_rst       : in  std_logic;
        i_data      : in std_logic_vector(7 downto 0);
        i_data_valid : in std_logic;

        o_Hsync   : out std_logic;
        o_Vsync   : out std_logic;
        o_display_enable : out std_logic;

        o_x       : out std_logic_vector(9 downto 0); -- column (0–639)
        o_y       : out std_logic_vector(9 downto 0);  -- row (0–479)

        o_red : out std_logic_vector(3 downto 0);
        o_green : out std_logic_vector(3 downto 0);
        o_blue : out std_logic_vector(3 downto 0);
        o_rgb_valid : out std_logic
    );
end vga_controller;

architecture vga of vga_controller is

    signal r_col_count : integer range 0 to TOTAL_COLS-1 := 0;
    signal r_row_count : integer range 0 to TOTAL_ROWS-1 := 0;

    signal r_red, r_green, r_blue : std_logic_vector(3 downto 0) := (others => '0');

    signal r_display_enable : STD_LOGIC := '0';

begin

    COUNTER_PROC : process(i_clk_vga, i_rst)
    begin
        if i_rst = '1' then
            r_col_count <= 0;
            r_row_count <= 0;

        elsif rising_edge(i_clk_vga) then

            if r_col_count = TOTAL_COLS - 1 then
                r_col_count <= 0;

                if r_row_count = TOTAL_ROWS - 1 then
                    r_row_count <= 0;
                else
                    r_row_count <= r_row_count + 1;
                end if;

            else
                r_col_count <= r_col_count + 1;
            end if;

        end if;
    end process;

    o_Hsync <= '0' when (r_col_count < HOR_SYNC_TIME) else '1';
    o_Vsync <= '0' when (r_row_count < V_SYNC_TIME) else '1';

    DISP_EN_PROC : process(i_clk_vga) 
    begin
        if rising_edge(i_clk_vga) then
            if (r_col_count >= HOR_SYNC_TIME + HOR_BACK_PORCH) and
            (r_col_count <  HOR_SYNC_TIME + HOR_BACK_PORCH + HOR_DISPLAY) and
            (r_row_count >= V_SYNC_TIME + V_BACK_PORCH) and
            (r_row_count <  V_SYNC_TIME + V_BACK_PORCH + V_DISPLAY) then

                r_display_enable <= '1';
            else
                r_display_enable <= '0';
            end if;
        end if;
    end process;

    o_display_enable <= r_display_enable;

    o_x <= std_logic_vector(to_unsigned(
            r_col_count - (HOR_SYNC_TIME + HOR_BACK_PORCH), 10))
            when r_display_enable = '1' else (others => '0');

    o_y <= std_logic_vector(to_unsigned(
            r_row_count - (V_SYNC_TIME + V_BACK_PORCH), 10))
            when r_display_enable = '1' else (others => '0');

    DRAW_PROC : process(i_clk_vga, i_rst)
    begin
        if i_rst = '1' then
            r_red <= (others => '0');
            r_green <= (others => '0');
            r_blue <= (others => '0');
            o_rgb_valid <= '0';
        elsif rising_edge(i_clk_vga) then
            if r_display_enable = '1' then
                if i_data_valid = '1' then
                    r_red <= i_data(7 downto 4);
                    r_green <= i_data(7 downto 4);
                    r_blue <= i_data(7 downto 4);
                end if;
                o_rgb_valid <= '1';
            else
                o_rgb_valid <= '0';
                r_red <= (others => '0');
                r_green <= (others => '0');
                r_blue <= (others => '0');
            end if;
        end if;
    end process;

    o_red   <= r_red;
    o_green <= r_green;
    o_blue  <= r_blue;
    

end vga;