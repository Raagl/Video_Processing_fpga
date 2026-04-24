library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity vga_tb is
end vga_tb;

architecture rtl of vga_tb is

    constant DIVISOR : integer := 4;
    constant ACTIVE_ROWS : integer := 480;
    constant ACTIVE_COLS : integer := 640;
    constant TOTAL_ROWS : integer := 525;
    constant TOTAL_COLS : integer := 800;
    constant VIDEO_WIDTH : integer := 4;
    constant FRONT_PORCH_COLS : integer := 16;
    constant BACK_PORCH_COLS : integer := 48;
    constant FRONT_PORCH_ROWS : integer := 10;
    constant BACK_PORCH_ROWS : integer := 33;

    signal r_clk : std_logic := '0';
    signal r_rst : std_logic := '0';

    signal w_clk_vga : std_logic;

    signal w_h_sync, w_v_sync : std_logic;
    signal w_h_sync_tp, w_v_sync_tp : std_logic;
    signal r_h_sync_porch, r_v_sync_porch : std_logic := '0';

    signal pattern_sel_r : std_logic_vector(2 downto 0) := "000";

    signal w_red_tp, w_green_tp, w_blue_tp : std_logic_vector(VIDEO_WIDTH-1 downto 0);
    signal r_red_porch, r_green_porch, r_blue_porch : std_logic_vector(VIDEO_WIDTH-1 downto 0) := (others => '0');

begin    
    process
    begin
        r_clk <= '1';
        wait for 5 ns;
        r_clk <= '0';
        wait for 5 ns;
    end process;
    
    process
    begin
        r_rst <= '1';
        wait for 10ns;
        r_rst <= '0';
        wait for 10ns;

        pattern_sel_r <= "001";
        wait;
    end process;

    UUT_CLOCK_DIVIDER : entity work.clock_divider
        generic map ( DIVISOR => DIVISOR)
        port map (
            clk_in => r_clk,
            rst => r_rst,
            clk_vga => w_clk_vga
        );


    UUT_SYNC_PULSE_GEN : entity work.sync_pulse_gen
        generic map (
            ACTIVE_ROWS => ACTIVE_ROWS,
            ACTIVE_COLS => ACTIVE_COLS,
            TOTAL_ROWS  => TOTAL_ROWS,
            TOTAL_COLS  => TOTAL_COLS
        )
        port map (
            clk_vga => w_clk_vga,

            h_sync  => w_h_sync,
            v_sync  => w_v_sync
        );
  
    UUT_TEST_PATTERN : entity work.test_pattern
        generic map (
            ACTIVE_ROWS => ACTIVE_ROWS,
            ACTIVE_COLS => ACTIVE_COLS,
            TOTAL_ROWS => TOTAL_ROWS,
            TOTAL_COLS => TOTAL_COLS,
            VIDEO_WIDTH => VIDEO_WIDTH
        )
        port map (
            clk_vga => w_clk_vga,
            i_h_sync => w_h_sync,
            i_v_sync => w_v_sync,
            pattern_sel => pattern_sel_r,

            red => w_red_tp,
            green => w_green_tp,
            blue => w_blue_tp,
            o_h_sync => w_h_sync_tp,
            o_v_sync => w_v_sync_tp
        );
    
end architecture;