# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "RELEASE_HIGH_ACTIVE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RELEASE_DELAY_CYCLES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INCLUDE_CRC_CHECK" -parent ${Page_0}


}

proc update_PARAM_VALUE.INCLUDE_CRC_CHECK { PARAM_VALUE.INCLUDE_CRC_CHECK } {
	# Procedure called to update INCLUDE_CRC_CHECK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INCLUDE_CRC_CHECK { PARAM_VALUE.INCLUDE_CRC_CHECK } {
	# Procedure called to validate INCLUDE_CRC_CHECK
	return true
}

proc update_PARAM_VALUE.NUM_OF_32K_ROMS { PARAM_VALUE.NUM_OF_32K_ROMS } {
	# Procedure called to update NUM_OF_32K_ROMS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_OF_32K_ROMS { PARAM_VALUE.NUM_OF_32K_ROMS } {
	# Procedure called to validate NUM_OF_32K_ROMS
	return true
}

proc update_PARAM_VALUE.RELEASE_DELAY_CYCLES { PARAM_VALUE.RELEASE_DELAY_CYCLES } {
	# Procedure called to update RELEASE_DELAY_CYCLES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RELEASE_DELAY_CYCLES { PARAM_VALUE.RELEASE_DELAY_CYCLES } {
	# Procedure called to validate RELEASE_DELAY_CYCLES
	return true
}

proc update_PARAM_VALUE.RELEASE_HIGH_ACTIVE { PARAM_VALUE.RELEASE_HIGH_ACTIVE } {
	# Procedure called to update RELEASE_HIGH_ACTIVE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RELEASE_HIGH_ACTIVE { PARAM_VALUE.RELEASE_HIGH_ACTIVE } {
	# Procedure called to validate RELEASE_HIGH_ACTIVE
	return true
}


proc update_MODELPARAM_VALUE.RELEASE_HIGH_ACTIVE { MODELPARAM_VALUE.RELEASE_HIGH_ACTIVE PARAM_VALUE.RELEASE_HIGH_ACTIVE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RELEASE_HIGH_ACTIVE}] ${MODELPARAM_VALUE.RELEASE_HIGH_ACTIVE}
}

proc update_MODELPARAM_VALUE.INCLUDE_CRC_CHECK { MODELPARAM_VALUE.INCLUDE_CRC_CHECK PARAM_VALUE.INCLUDE_CRC_CHECK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INCLUDE_CRC_CHECK}] ${MODELPARAM_VALUE.INCLUDE_CRC_CHECK}
}

proc update_MODELPARAM_VALUE.RELEASE_DELAY_CYCLES { MODELPARAM_VALUE.RELEASE_DELAY_CYCLES PARAM_VALUE.RELEASE_DELAY_CYCLES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RELEASE_DELAY_CYCLES}] ${MODELPARAM_VALUE.RELEASE_DELAY_CYCLES}
}

proc update_MODELPARAM_VALUE.NUM_OF_32K_ROMS { MODELPARAM_VALUE.NUM_OF_32K_ROMS PARAM_VALUE.NUM_OF_32K_ROMS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_OF_32K_ROMS}] ${MODELPARAM_VALUE.NUM_OF_32K_ROMS}
}

