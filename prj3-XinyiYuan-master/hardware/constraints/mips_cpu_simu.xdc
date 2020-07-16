create_clock -period 10 -name clk -waveform {0 5} [get_ports sys_clk]

set_property IOSTANDARD LVCMOS18 [get_ports sys_clk]
set_property package_pin C4 [get_ports sys_clk]

set_property IOSTANDARD LVCMOS18 [get_ports sys_reset_n]
set_property package_pin B8 [get_ports sys_reset_n]

