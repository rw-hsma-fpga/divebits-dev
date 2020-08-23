# ----------------------------------------------------------------------------
# Clock Source - Bank 13
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN Y9 [get_ports {sys_clock}];  # "GCLK"
set_property IOSTANDARD LVCMOS33 [get_ports sys_clock];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports sys_clock]; 

# ----------------------------------------------------------------------------
# JA Pmod - Bank 13
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN AA11 [get_ports {tx}];  # "JA2"
set_property IOSTANDARD LVCMOS33 [get_ports tx];
set_property PACKAGE_PIN Y10  [get_ports {rx}];  # "JA3"
set_property IOSTANDARD LVCMOS33 [get_ports rx];

# ----------------------------------------------------------------------------
# User Push Buttons - Bank 34
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN P16 [get_ports {reset_rtl}];  # "BTNC"
set_property IOSTANDARD LVCMOS33 [get_ports reset_rtl];

# ----------------------------------------------------------------------------
# User LEDs - Bank 33
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN T22 [get_ports {LED[0]}]
set_property PACKAGE_PIN T21 [get_ports {LED[1]}]
set_property PACKAGE_PIN U22 [get_ports {LED[2]}]
set_property PACKAGE_PIN U21 [get_ports {LED[3]}]
set_property PACKAGE_PIN V22 [get_ports {LED[4]}]
set_property PACKAGE_PIN W22 [get_ports {LED[5]}]
set_property PACKAGE_PIN U19 [get_ports {LED[6]}]
set_property PACKAGE_PIN U14 [get_ports {LED[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]]
