library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ov7670_config is
    port (
        i_sys_clk : in std_logic;
        i_rst : in std_logic;

        o_sioc : out std_logic;
        o_siod : out std_logic;
        o_config_done : out std_logic 
     );
end ov7670_config;

architecture rtl of ov7670_config is

    constant I2C_CLK_FREQ : integer := 100_000; -- 100 kHz I2C clock
    constant SYS_CLK_FREQ : integer := 100_000_000; -- 100 MHz system clock
    constant CAMERA_ADDRESS : std_logic_vector(7 downto 0) := X"42";

    signal w_advance : std_logic;
    signal w_command : std_logic_vector(15 downto 0) := (others => '0');
    signal w_finished : std_logic;

    signal w_done : std_logic := '0';
    signal w_busy : std_logic := '0';
    signal w_data_valid : std_logic := '0';
    signal w_slave_address : std_logic_vector(7 downto 0) := X"42"; 
    signal w_register_address, w_register_data : std_logic_vector(7 downto 0);

    signal w_init_done : std_logic;

begin

    o_config_done <= w_init_done;

    ov7670_registers_inst : entity work.ov7670_registers
        port map (
            clk         => i_sys_clk,
            rst         => i_rst,
            advance     => w_advance, 

            command     => w_command,
            finished    => w_finished
        );

    ov7670_i2c_controller_inst : entity work.ov7670_i2c_controller
        generic map (
            SYS_CLK_FREQ => SYS_CLK_FREQ,
            I2C_CLK_FREQ => I2C_CLK_FREQ
        )
        port map (
            i_sys_clk           => i_sys_clk,
            i_rst               => i_rst,
            i_data_valid        => w_data_valid,
            i_slave_addr     => w_slave_address,
            i_reg_addr  => w_register_address,
            i_reg_data     => w_register_data,

            o_done => w_done,
            o_busy => w_busy,
            o_scl => o_sioc,
            o_sda => o_siod
        );

    ov7670_init_fsm_inst : entity work.ov7670_init_fsm
        generic map (
            CAMERA_ADDRESS => CAMERA_ADDRESS
        )
        port map (
            i_sys_clk => i_sys_clk,
            i_rst => i_rst,
            i_done => w_done,
            i_command => w_command,
            i_finished => w_finished,

            o_valid_data => w_data_valid,
            o_slave_addr => w_slave_address,
            o_register_addr => w_register_address,
            o_register_data => w_register_data,

            o_advance => w_advance,
            o_init_done => w_init_done
        );

end rtl;
