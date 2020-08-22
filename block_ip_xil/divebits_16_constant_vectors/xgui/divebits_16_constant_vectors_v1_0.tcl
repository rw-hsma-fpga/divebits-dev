# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DB_DAISY_CHAIN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_ADDRESS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_VECTOR_WIDTH" -parent ${Page_0}
  set DB_DEFAULT_VALUE_ALL [ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_ALL" -parent ${Page_0}]
  set_property tooltip {Keep zero if you want set individual defaults, otherwise this is added} ${DB_DEFAULT_VALUE_ALL}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_00" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_01" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_02" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_03" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_04" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_05" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_06" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_07" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_08" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_09" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_10" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_11" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_12" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_13" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_14" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_15" -parent ${Page_0}


}

proc update_PARAM_VALUE.DB_ADDRESS { PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to update DB_ADDRESS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_ADDRESS { PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to validate DB_ADDRESS
	return true
}

proc update_PARAM_VALUE.DB_DAISY_CHAIN { PARAM_VALUE.DB_DAISY_CHAIN } {
	# Procedure called to update DB_DAISY_CHAIN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DAISY_CHAIN { PARAM_VALUE.DB_DAISY_CHAIN } {
	# Procedure called to validate DB_DAISY_CHAIN
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_00 { PARAM_VALUE.DB_DEFAULT_VALUE_00 } {
	# Procedure called to update DB_DEFAULT_VALUE_00 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_00 { PARAM_VALUE.DB_DEFAULT_VALUE_00 } {
	# Procedure called to validate DB_DEFAULT_VALUE_00
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_01 { PARAM_VALUE.DB_DEFAULT_VALUE_01 } {
	# Procedure called to update DB_DEFAULT_VALUE_01 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_01 { PARAM_VALUE.DB_DEFAULT_VALUE_01 } {
	# Procedure called to validate DB_DEFAULT_VALUE_01
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_02 { PARAM_VALUE.DB_DEFAULT_VALUE_02 } {
	# Procedure called to update DB_DEFAULT_VALUE_02 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_02 { PARAM_VALUE.DB_DEFAULT_VALUE_02 } {
	# Procedure called to validate DB_DEFAULT_VALUE_02
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_03 { PARAM_VALUE.DB_DEFAULT_VALUE_03 } {
	# Procedure called to update DB_DEFAULT_VALUE_03 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_03 { PARAM_VALUE.DB_DEFAULT_VALUE_03 } {
	# Procedure called to validate DB_DEFAULT_VALUE_03
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_04 { PARAM_VALUE.DB_DEFAULT_VALUE_04 } {
	# Procedure called to update DB_DEFAULT_VALUE_04 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_04 { PARAM_VALUE.DB_DEFAULT_VALUE_04 } {
	# Procedure called to validate DB_DEFAULT_VALUE_04
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_05 { PARAM_VALUE.DB_DEFAULT_VALUE_05 } {
	# Procedure called to update DB_DEFAULT_VALUE_05 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_05 { PARAM_VALUE.DB_DEFAULT_VALUE_05 } {
	# Procedure called to validate DB_DEFAULT_VALUE_05
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_06 { PARAM_VALUE.DB_DEFAULT_VALUE_06 } {
	# Procedure called to update DB_DEFAULT_VALUE_06 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_06 { PARAM_VALUE.DB_DEFAULT_VALUE_06 } {
	# Procedure called to validate DB_DEFAULT_VALUE_06
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_07 { PARAM_VALUE.DB_DEFAULT_VALUE_07 } {
	# Procedure called to update DB_DEFAULT_VALUE_07 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_07 { PARAM_VALUE.DB_DEFAULT_VALUE_07 } {
	# Procedure called to validate DB_DEFAULT_VALUE_07
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_08 { PARAM_VALUE.DB_DEFAULT_VALUE_08 } {
	# Procedure called to update DB_DEFAULT_VALUE_08 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_08 { PARAM_VALUE.DB_DEFAULT_VALUE_08 } {
	# Procedure called to validate DB_DEFAULT_VALUE_08
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_09 { PARAM_VALUE.DB_DEFAULT_VALUE_09 } {
	# Procedure called to update DB_DEFAULT_VALUE_09 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_09 { PARAM_VALUE.DB_DEFAULT_VALUE_09 } {
	# Procedure called to validate DB_DEFAULT_VALUE_09
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_10 { PARAM_VALUE.DB_DEFAULT_VALUE_10 } {
	# Procedure called to update DB_DEFAULT_VALUE_10 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_10 { PARAM_VALUE.DB_DEFAULT_VALUE_10 } {
	# Procedure called to validate DB_DEFAULT_VALUE_10
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_11 { PARAM_VALUE.DB_DEFAULT_VALUE_11 } {
	# Procedure called to update DB_DEFAULT_VALUE_11 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_11 { PARAM_VALUE.DB_DEFAULT_VALUE_11 } {
	# Procedure called to validate DB_DEFAULT_VALUE_11
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_12 { PARAM_VALUE.DB_DEFAULT_VALUE_12 } {
	# Procedure called to update DB_DEFAULT_VALUE_12 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_12 { PARAM_VALUE.DB_DEFAULT_VALUE_12 } {
	# Procedure called to validate DB_DEFAULT_VALUE_12
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_13 { PARAM_VALUE.DB_DEFAULT_VALUE_13 } {
	# Procedure called to update DB_DEFAULT_VALUE_13 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_13 { PARAM_VALUE.DB_DEFAULT_VALUE_13 } {
	# Procedure called to validate DB_DEFAULT_VALUE_13
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_14 { PARAM_VALUE.DB_DEFAULT_VALUE_14 } {
	# Procedure called to update DB_DEFAULT_VALUE_14 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_14 { PARAM_VALUE.DB_DEFAULT_VALUE_14 } {
	# Procedure called to validate DB_DEFAULT_VALUE_14
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_15 { PARAM_VALUE.DB_DEFAULT_VALUE_15 } {
	# Procedure called to update DB_DEFAULT_VALUE_15 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_15 { PARAM_VALUE.DB_DEFAULT_VALUE_15 } {
	# Procedure called to validate DB_DEFAULT_VALUE_15
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_ALL { PARAM_VALUE.DB_DEFAULT_VALUE_ALL } {
	# Procedure called to update DB_DEFAULT_VALUE_ALL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_ALL { PARAM_VALUE.DB_DEFAULT_VALUE_ALL } {
	# Procedure called to validate DB_DEFAULT_VALUE_ALL
	return true
}

proc update_PARAM_VALUE.DB_TYPE { PARAM_VALUE.DB_TYPE } {
	# Procedure called to update DB_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_TYPE { PARAM_VALUE.DB_TYPE } {
	# Procedure called to validate DB_TYPE
	return true
}

proc update_PARAM_VALUE.DB_VECTOR_WIDTH { PARAM_VALUE.DB_VECTOR_WIDTH } {
	# Procedure called to update DB_VECTOR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_VECTOR_WIDTH { PARAM_VALUE.DB_VECTOR_WIDTH } {
	# Procedure called to validate DB_VECTOR_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.DB_ADDRESS { MODELPARAM_VALUE.DB_ADDRESS PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_ADDRESS}] ${MODELPARAM_VALUE.DB_ADDRESS}
}

proc update_MODELPARAM_VALUE.DB_TYPE { MODELPARAM_VALUE.DB_TYPE PARAM_VALUE.DB_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_TYPE}] ${MODELPARAM_VALUE.DB_TYPE}
}

proc update_MODELPARAM_VALUE.DB_VECTOR_WIDTH { MODELPARAM_VALUE.DB_VECTOR_WIDTH PARAM_VALUE.DB_VECTOR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_VECTOR_WIDTH}] ${MODELPARAM_VALUE.DB_VECTOR_WIDTH}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_ALL { MODELPARAM_VALUE.DB_DEFAULT_VALUE_ALL PARAM_VALUE.DB_DEFAULT_VALUE_ALL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_ALL}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_ALL}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_00 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_00 PARAM_VALUE.DB_DEFAULT_VALUE_00 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_00}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_00}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_01 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_01 PARAM_VALUE.DB_DEFAULT_VALUE_01 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_01}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_01}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_02 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_02 PARAM_VALUE.DB_DEFAULT_VALUE_02 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_02}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_02}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_03 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_03 PARAM_VALUE.DB_DEFAULT_VALUE_03 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_03}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_03}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_04 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_04 PARAM_VALUE.DB_DEFAULT_VALUE_04 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_04}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_04}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_05 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_05 PARAM_VALUE.DB_DEFAULT_VALUE_05 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_05}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_05}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_06 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_06 PARAM_VALUE.DB_DEFAULT_VALUE_06 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_06}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_06}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_07 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_07 PARAM_VALUE.DB_DEFAULT_VALUE_07 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_07}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_07}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_08 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_08 PARAM_VALUE.DB_DEFAULT_VALUE_08 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_08}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_08}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_09 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_09 PARAM_VALUE.DB_DEFAULT_VALUE_09 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_09}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_09}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_10 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_10 PARAM_VALUE.DB_DEFAULT_VALUE_10 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_10}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_10}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_11 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_11 PARAM_VALUE.DB_DEFAULT_VALUE_11 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_11}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_11}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_12 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_12 PARAM_VALUE.DB_DEFAULT_VALUE_12 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_12}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_12}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_13 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_13 PARAM_VALUE.DB_DEFAULT_VALUE_13 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_13}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_13}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_14 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_14 PARAM_VALUE.DB_DEFAULT_VALUE_14 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_14}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_14}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_15 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_15 PARAM_VALUE.DB_DEFAULT_VALUE_15 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_15}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_15}
}

proc update_MODELPARAM_VALUE.DB_DAISY_CHAIN { MODELPARAM_VALUE.DB_DAISY_CHAIN PARAM_VALUE.DB_DAISY_CHAIN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DAISY_CHAIN}] ${MODELPARAM_VALUE.DB_DAISY_CHAIN}
}

