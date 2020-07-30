# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DB_DAISY_CHAIN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_ADDRESS" -parent ${Page_0}
  set DB_NUM_CODE_WORDS [ipgui::add_param $IPINST -name "DB_NUM_CODE_WORDS" -parent ${Page_0} -widget comboBox]
  set_property tooltip {(Size of Code Memory)} ${DB_NUM_CODE_WORDS}
  ipgui::add_param $IPINST -name "DB_REPEAT_WAITCYCLES_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_REPEAT_AFTER_BUS_ERROR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M00_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_M00_AXI_DATA_WIDTH" -parent ${Page_0} -widget comboBox


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

proc update_PARAM_VALUE.DB_NUM_CODE_WORDS { PARAM_VALUE.DB_NUM_CODE_WORDS } {
	# Procedure called to update DB_NUM_CODE_WORDS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_NUM_CODE_WORDS { PARAM_VALUE.DB_NUM_CODE_WORDS } {
	# Procedure called to validate DB_NUM_CODE_WORDS
	return true
}

proc update_PARAM_VALUE.DB_REPEAT_AFTER_BUS_ERROR { PARAM_VALUE.DB_REPEAT_AFTER_BUS_ERROR } {
	# Procedure called to update DB_REPEAT_AFTER_BUS_ERROR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_REPEAT_AFTER_BUS_ERROR { PARAM_VALUE.DB_REPEAT_AFTER_BUS_ERROR } {
	# Procedure called to validate DB_REPEAT_AFTER_BUS_ERROR
	return true
}

proc update_PARAM_VALUE.DB_REPEAT_WAITCYCLES_WIDTH { PARAM_VALUE.DB_REPEAT_WAITCYCLES_WIDTH } {
	# Procedure called to update DB_REPEAT_WAITCYCLES_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_REPEAT_WAITCYCLES_WIDTH { PARAM_VALUE.DB_REPEAT_WAITCYCLES_WIDTH } {
	# Procedure called to validate DB_REPEAT_WAITCYCLES_WIDTH
	return true
}

proc update_PARAM_VALUE.DB_TYPE { PARAM_VALUE.DB_TYPE } {
	# Procedure called to update DB_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_TYPE { PARAM_VALUE.DB_TYPE } {
	# Procedure called to validate DB_TYPE
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_ADDR_WIDTH { PARAM_VALUE.C_M00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_M00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_ADDR_WIDTH { PARAM_VALUE.C_M00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_M00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M00_AXI_DATA_WIDTH { PARAM_VALUE.C_M00_AXI_DATA_WIDTH } {
	# Procedure called to update C_M00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M00_AXI_DATA_WIDTH { PARAM_VALUE.C_M00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_M00_AXI_DATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_M00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_M00_AXI_ADDR_WIDTH PARAM_VALUE.C_M00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_M00_AXI_DATA_WIDTH PARAM_VALUE.C_M00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.DB_ADDRESS { MODELPARAM_VALUE.DB_ADDRESS PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_ADDRESS}] ${MODELPARAM_VALUE.DB_ADDRESS}
}

proc update_MODELPARAM_VALUE.DB_TYPE { MODELPARAM_VALUE.DB_TYPE PARAM_VALUE.DB_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_TYPE}] ${MODELPARAM_VALUE.DB_TYPE}
}

proc update_MODELPARAM_VALUE.DB_NUM_CODE_WORDS { MODELPARAM_VALUE.DB_NUM_CODE_WORDS PARAM_VALUE.DB_NUM_CODE_WORDS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_NUM_CODE_WORDS}] ${MODELPARAM_VALUE.DB_NUM_CODE_WORDS}
}

proc update_MODELPARAM_VALUE.DB_DAISY_CHAIN { MODELPARAM_VALUE.DB_DAISY_CHAIN PARAM_VALUE.DB_DAISY_CHAIN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DAISY_CHAIN}] ${MODELPARAM_VALUE.DB_DAISY_CHAIN}
}

proc update_MODELPARAM_VALUE.DB_REPEAT_AFTER_BUS_ERROR { MODELPARAM_VALUE.DB_REPEAT_AFTER_BUS_ERROR PARAM_VALUE.DB_REPEAT_AFTER_BUS_ERROR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_REPEAT_AFTER_BUS_ERROR}] ${MODELPARAM_VALUE.DB_REPEAT_AFTER_BUS_ERROR}
}

proc update_MODELPARAM_VALUE.DB_REPEAT_WAITCYCLES_WIDTH { MODELPARAM_VALUE.DB_REPEAT_WAITCYCLES_WIDTH PARAM_VALUE.DB_REPEAT_WAITCYCLES_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_REPEAT_WAITCYCLES_WIDTH}] ${MODELPARAM_VALUE.DB_REPEAT_WAITCYCLES_WIDTH}
}

