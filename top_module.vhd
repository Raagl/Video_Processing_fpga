library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity top_module is
    port (
        i_sys_clk : in std_logic;
        i_rst : in std_logic;

        i_pclk : in std_logic;
        i_vsync : in std_logic;
        i_href : in std_logic;
        i_data : in std_logic_vector(7 downto 0);

        o_xclk : out std_logic;        
        o_scl : out std_logic;
        o_sda : out std_logic;
        o_camera_rst : out std_logic;
        o_pwdn : out std_logic;

        o_Hsync : out std_logic;
        o_Vsync : out std_logic;
        o_red : out std_logic_vector(3 downto 0);
        o_green : out std_logic_vector(3 downto 0);
        o_blue : out std_logic_vector(3 downto 0)
     );
end top_module;

architecture Behavioral of top_module is

    attribute CLOCK_BUFFER_TYPE : string;
    attribute CLOCK_BUFFER_TYPE of i_pclk : signal is "NONE";

    signal rst, n_rst : std_logic;
    signal w_clk_25mhz, w_clk_24mhz : std_logic;
    signal w_locked : std_logic;

    signal w_pixel_data : std_logic_vector(7 downto 0);
    signal w_pixel_data_valid : std_logic;

    signal w_display_enable : std_logic;
    signal w_rgb_valid : std_logic;
    signal w_fifo_valid : std_logic;
    signal w_fifo_data : std_logic_vector(7 downto 0);


    COMPONENT axis_data_fifo_0
    PORT (
        s_axis_aresetn : IN STD_LOGIC;
        s_axis_aclk : IN STD_LOGIC;
        s_axis_tvalid : IN STD_LOGIC;
        s_axis_tready : OUT STD_LOGIC;
        s_axis_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        m_axis_aclk : IN STD_LOGIC;
        m_axis_tvalid : OUT STD_LOGIC;
        m_axis_tready : IN STD_LOGIC;
        m_axis_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) 
    );
    END COMPONENT;

    component clk_wiz_0
    port
    (-- Clock in ports
    -- Clock out ports
    clk_out1          : out    std_logic;
    clk_out2          : out    std_logic;
    -- Status and control signals
    reset             : in     std_logic;
    locked            : out    std_logic;
    clk_in1           : in     std_logic
    );
    end component;

begin

    o_xclk <= w_clk_24mhz;
    n_rst <= not (i_rst or not w_locked);
    rst <= not (n_rst);

    o_camera_rst <= '0'; -- keep it on
    o_pwdn <= '0'; -- normal mode

    clock_gen_inst : clk_wiz_0
        port map ( 
            -- Clock out ports  
            clk_out1 => w_clk_24mhz,
            clk_out2 => w_clk_25mhz,
            -- Status and control signals                
            reset => i_rst,
            locked => w_locked,
            -- Clock in ports
            clk_in1 => i_sys_clk
        );

    -- axis master
    vga_controller_inst : entity work.vga_controller
        generic map (
            TOTAL_COLS => 800,
            TOTAL_ROWS => 521,
            HOR_SYNC_TIME => 96,
            HOR_BACK_PORCH => 48,
            HOR_DISPLAY => 640,
            HOR_FRONT_PORCH => 16,
            V_SYNC_TIME => 2,
            V_BACK_PORCH => 29,
            V_DISPLAY => 480,
            V_FRONT_PORCH => 10
        )
        port map (
            i_clk_vga   => w_clk_25mhz,  -- 25 MHz clock
            i_rst       => rst,
            i_data      => X"FF", --w_fifo_data,
            i_data_valid => '1', --w_fifo_valid,

            o_Hsync   => o_Hsync,
            o_Vsync   => o_Vsync,
            o_display_enable => w_display_enable,

            o_x       => open, -- column (0–639)
            o_y       => open, -- row (0–479)

            o_red => o_red,
            o_green => o_green,
            o_blue => o_blue,
            o_rgb_valid => w_rgb_valid
        );

    -- axis slave
    ov7670_top_inst : entity work.ov7670_top
        port map (
            i_clk => i_sys_clk,
            i_rst => rst,
            i_pclk => i_pclk,
            i_vsync => i_vsync,
            i_href => i_href,
            i_data => i_data,

            o_scl => o_scl,
            o_sda => o_sda,
            o_pixel_data => w_pixel_data,
            o_pixel_valid => w_pixel_data_valid
        );
    
    axis_fifo_inst : axis_data_fifo_0
    PORT MAP (
        --write side (camera)
        s_axis_aresetn => n_rst,
        s_axis_aclk => i_pclk, -- 24mhz
        s_axis_tvalid => w_pixel_data_valid,
        s_axis_tready => open,
        s_axis_tdata => w_pixel_data,
        -- read side (vga) 
        m_axis_aclk => w_clk_25mhz, -- 25mhz
        m_axis_tvalid => w_fifo_valid,
        m_axis_tready => w_display_enable,
        m_axis_tdata => w_fifo_data
    );

    

end Behavioral;
