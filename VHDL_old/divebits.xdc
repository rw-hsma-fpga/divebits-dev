# ----------------------------------------------------------------------------
# Clock Source - Bank 13
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN Y9 [get_ports sys_clock]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clock]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports sys_clock]

# ----------------------------------------------------------------------------
# JA Pmod - Bank 13
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN AA11 [get_ports {tx}];  # "JA2"
#set_property IOSTANDARD LVCMOS33 [get_ports tx];
#set_property PACKAGE_PIN Y10  [get_ports {rx}];  # "JA3"
#set_property IOSTANDARD LVCMOS33 [get_ports rx];

# ----------------------------------------------------------------------------
# User Push Buttons - Bank 34
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN P16 [get_ports reset_rtl]
set_property IOSTANDARD LVCMOS33 [get_ports reset_rtl]



# ----------------------------------------------------------------------------
# User LEDs - Bank 33
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN T22 [get_ports {Vector_out_0[0]}]
#set_property PACKAGE_PIN T21 [get_ports {Vector_out_0[1]}]
#set_property PACKAGE_PIN U22 [get_ports {Vector_out_0[2]}]
#set_property PACKAGE_PIN U21 [get_ports {Vector_out_0[3]}]
#set_property PACKAGE_PIN V22 [get_ports {Vector_out_1[0]}]
#set_property PACKAGE_PIN W22 [get_ports {Vector_out_1[1]}]
#set_property PACKAGE_PIN U19 [get_ports {Vector_out_1[2]}]
#set_property PACKAGE_PIN U14 [get_ports {Vector_out_1[3]}]
set_property PACKAGE_PIN T22 [get_ports {LED0[0]}]
set_property PACKAGE_PIN T21 [get_ports {LED1[0]}]
set_property PACKAGE_PIN U22 [get_ports {LED2[0]}]
set_property PACKAGE_PIN U21 [get_ports {LED3[0]}]
set_property PACKAGE_PIN V22 [get_ports {LED4[0]}]
set_property PACKAGE_PIN W22 [get_ports {LED5[0]}]
set_property PACKAGE_PIN U19 [get_ports {LED6[0]}]
set_property PACKAGE_PIN U14 [get_ports {LED7[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]]


