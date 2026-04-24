## Clock signal
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports i_sys_clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports i_sys_clk]

## Switches
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {i_rst}]

##VGA Connector
set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS33 } [get_ports {o_red[0]}]
set_property -dict { PACKAGE_PIN H19   IOSTANDARD LVCMOS33 } [get_ports {o_red[1]}]
set_property -dict { PACKAGE_PIN J19   IOSTANDARD LVCMOS33 } [get_ports {o_red[2]}]
set_property -dict { PACKAGE_PIN N19   IOSTANDARD LVCMOS33 } [get_ports {o_red[3]}]
set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports {o_blue[0]}]
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports {o_blue[1]}]
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports {o_blue[2]}]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports {o_blue[3]}]
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports {o_green[0]}]
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports {o_green[1]}]
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports {o_green[2]}]
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports {o_green[3]}]
set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports o_Hsync]
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports o_Vsync]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets i_pclk_IBUF]

#Pmod Header 
# Camera connections
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports {o_scl}];#Sch name = JC4
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports {o_sda}];#Sch name = JC10
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports {i_pclk}];#Sch name = JC2
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports {i_vsync}];#Sch name = JC3
set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports {o_xclk}];#Sch name = JC8
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports {i_href}];#Sch name = JC9
set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports {o_camera_rst}];#Sch name = JB1
set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33 } [get_ports {o_pwdn}];#Sch name = JB7

set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports {i_data[0]}];#Sch name = JB8
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports {i_data[1]}];#Sch name = JB2
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports {i_data[2]}];#Sch name = JB9
set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33 } [get_ports {i_data[3]}];#Sch name = JB3
set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports {i_data[4]}];#Sch name = JB10
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports {i_data[5]}];#Sch name = JB4
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports {i_data[6]}];#Sch name = JC7
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports {i_data[7]}];#Sch name = JC1


 