# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DAISY_CHAIN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_ADDRESS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEFAULT_VALUE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "VECTOR_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.DAISY_CHAIN { PARAM_VALUE.DAISY_CHAIN } {
	# Procedure called to update DAISY_CHAIN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DAISY_CHAIN { PARAM_VALUE.DAISY_CHAIN } {
	# Procedure called to validate DAISY_CHAIN
	return true
}

proc update_PARAM_VALUE.DB_ADDRESS { PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to update DB_ADDRESS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_ADDRESS { PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to validate DB_ADDRESS
	return true
}

proc update_PARAM_VALUE.DEFAULT_VALUE { PARAM_VALUE.DEFAULT_VALUE } {
	# Procedure called to update DEFAULT_VALUE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_VALUE { PARAM_VALUE.DEFAULT_VALUE } {
	# Procedure called to validate DEFAULT_VALUE
	return true
}

proc update_PARAM_VALUE.VECTOR_WIDTH { PARAM_VALUE.VECTOR_WIDTH } {
	# Procedure called to update VECTOR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VECTOR_WIDTH { PARAM_VALUE.VECTOR_WIDTH } {
	# Procedure called to validate VECTOR_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.DB_ADDRESS { MODELPARAM_VALUE.DB_ADDRESS PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_ADDRESS}] ${MODELPARAM_VALUE.DB_ADDRESS}
}

proc update_MODELPARAM_VALUE.VECTOR_WIDTH { MODELPARAM_VALUE.VECTOR_WIDTH PARAM_VALUE.VECTOR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VECTOR_WIDTH}] ${MODELPARAM_VALUE.VECTOR_WIDTH}
}

proc update_MODELPARAM_VALUE.DEFAULT_VALUE { MODELPARAM_VALUE.DEFAULT_VALUE PARAM_VALUE.DEFAULT_VALUE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_VALUE}] ${MODELPARAM_VALUE.DEFAULT_VALUE}
}

proc update_MODELPARAM_VALUE.DAISY_CHAIN { MODELPARAM_VALUE.DAISY_CHAIN PARAM_VALUE.DAISY_CHAIN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DAISY_CHAIN}] ${MODELPARAM_VALUE.DAISY_CHAIN}
}

