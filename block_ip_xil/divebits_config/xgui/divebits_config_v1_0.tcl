# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  ipgui::add_param $IPINST -name "DB_RELEASE_DELAY_CYCLES"
  ipgui::add_param $IPINST -name "DB_RELEASE_HIGH_ACTIVE"
  ipgui::add_param $IPINST -name "DB_DAISY_CHAIN_CRC_CHECK"

}

proc update_PARAM_VALUE.DB_ADDRESS { PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to update DB_ADDRESS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_ADDRESS { PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to validate DB_ADDRESS
	return true
}

proc update_PARAM_VALUE.DB_DAISY_CHAIN_CRC_CHECK { PARAM_VALUE.DB_DAISY_CHAIN_CRC_CHECK } {
	# Procedure called to update DB_DAISY_CHAIN_CRC_CHECK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DAISY_CHAIN_CRC_CHECK { PARAM_VALUE.DB_DAISY_CHAIN_CRC_CHECK } {
	# Procedure called to validate DB_DAISY_CHAIN_CRC_CHECK
	return true
}

proc update_PARAM_VALUE.DB_NUM_OF_32K_ROMS { PARAM_VALUE.DB_NUM_OF_32K_ROMS } {
	# Procedure called to update DB_NUM_OF_32K_ROMS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_NUM_OF_32K_ROMS { PARAM_VALUE.DB_NUM_OF_32K_ROMS } {
	# Procedure called to validate DB_NUM_OF_32K_ROMS
	return true
}

proc update_PARAM_VALUE.DB_RELEASE_DELAY_CYCLES { PARAM_VALUE.DB_RELEASE_DELAY_CYCLES } {
	# Procedure called to update DB_RELEASE_DELAY_CYCLES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_RELEASE_DELAY_CYCLES { PARAM_VALUE.DB_RELEASE_DELAY_CYCLES } {
	# Procedure called to validate DB_RELEASE_DELAY_CYCLES
	return true
}

proc update_PARAM_VALUE.DB_RELEASE_HIGH_ACTIVE { PARAM_VALUE.DB_RELEASE_HIGH_ACTIVE } {
	# Procedure called to update DB_RELEASE_HIGH_ACTIVE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_RELEASE_HIGH_ACTIVE { PARAM_VALUE.DB_RELEASE_HIGH_ACTIVE } {
	# Procedure called to validate DB_RELEASE_HIGH_ACTIVE
	return true
}

proc update_PARAM_VALUE.DB_TYPE { PARAM_VALUE.DB_TYPE } {
	# Procedure called to update DB_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_TYPE { PARAM_VALUE.DB_TYPE } {
	# Procedure called to validate DB_TYPE
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

proc update_MODELPARAM_VALUE.DB_NUM_OF_32K_ROMS { MODELPARAM_VALUE.DB_NUM_OF_32K_ROMS PARAM_VALUE.DB_NUM_OF_32K_ROMS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_NUM_OF_32K_ROMS}] ${MODELPARAM_VALUE.DB_NUM_OF_32K_ROMS}
}

proc update_MODELPARAM_VALUE.DB_RELEASE_DELAY_CYCLES { MODELPARAM_VALUE.DB_RELEASE_DELAY_CYCLES PARAM_VALUE.DB_RELEASE_DELAY_CYCLES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_RELEASE_DELAY_CYCLES}] ${MODELPARAM_VALUE.DB_RELEASE_DELAY_CYCLES}
}

proc update_MODELPARAM_VALUE.DB_RELEASE_HIGH_ACTIVE { MODELPARAM_VALUE.DB_RELEASE_HIGH_ACTIVE PARAM_VALUE.DB_RELEASE_HIGH_ACTIVE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_RELEASE_HIGH_ACTIVE}] ${MODELPARAM_VALUE.DB_RELEASE_HIGH_ACTIVE}
}

proc update_MODELPARAM_VALUE.DB_DAISY_CHAIN_CRC_CHECK { MODELPARAM_VALUE.DB_DAISY_CHAIN_CRC_CHECK PARAM_VALUE.DB_DAISY_CHAIN_CRC_CHECK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DAISY_CHAIN_CRC_CHECK}] ${MODELPARAM_VALUE.DB_DAISY_CHAIN_CRC_CHECK}
}

