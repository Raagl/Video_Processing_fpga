## Clock signal
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports i_sys_clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports i_sys_clk]

## Switches
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports i_rst]

##VGA Connector
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports {o_red[0]}]
set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33} [get_ports {o_red[1]}]
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports {o_red[2]}]
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS33} [get_ports {o_red[3]}]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports {o_blue[0]}]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {o_blue[1]}]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {o_blue[2]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {o_blue[3]}]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {o_green[0]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {o_green[1]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {o_green[2]}]
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports {o_green[3]}]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS33} [get_ports o_Hsync]
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports o_Vsync]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_pclk_IBUF]

## LEDs
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports o_config_done]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports o_pixel_valid]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports o_xclk_led]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports o_rgb_valid]


#Pmod Header
# Camera connections
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports o_scl] 
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports o_sda]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports i_pclk]
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports i_vsync]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports o_xclk]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports i_href]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports o_camera_rst]
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports o_pwdn]

set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports {i_data[0]}]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {i_data[1]}]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {i_data[2]}]
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports {i_data[3]}]
set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports {i_data[4]}]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {i_data[5]}]
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS33} [get_ports {i_data[6]}]
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {i_data[7]}]



