
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/divebits_BlockRAM_init_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DB_DAISY_CHAIN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_ADDRESS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_BRAMCTRL_MODE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_BRAM_DATA_WIDTH" -parent ${Page_0}
  set DB_BRAM_ADDR_WIDTH [ipgui::add_param $IPINST -name "DB_BRAM_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {BRAM Port Address Width (log2(num_words))} ${DB_BRAM_ADDR_WIDTH}


}

proc update_PARAM_VALUE.FULL_ADDR_WIDTH { PARAM_VALUE.FULL_ADDR_WIDTH PARAM_VALUE.DB_BRAMCTRL_MODE PARAM_VALUE.DB_BRAM_ADDR_WIDTH } {
	# Procedure called to update FULL_ADDR_WIDTH when any of the dependent parameters in the arguments change
	
	set FULL_ADDR_WIDTH ${PARAM_VALUE.FULL_ADDR_WIDTH}
	set DB_BRAMCTRL_MODE ${PARAM_VALUE.DB_BRAMCTRL_MODE}
	set DB_BRAM_ADDR_WIDTH ${PARAM_VALUE.DB_BRAM_ADDR_WIDTH}
	set values(DB_BRAMCTRL_MODE) [get_property value $DB_BRAMCTRL_MODE]
	set values(DB_BRAM_ADDR_WIDTH) [get_property value $DB_BRAM_ADDR_WIDTH]
	set_property value [gen_USERPARAMETER_FULL_ADDR_WIDTH_VALUE $values(DB_BRAMCTRL_MODE) $values(DB_BRAM_ADDR_WIDTH)] $FULL_ADDR_WIDTH
}

proc validate_PARAM_VALUE.FULL_ADDR_WIDTH { PARAM_VALUE.FULL_ADDR_WIDTH } {
	# Procedure called to validate FULL_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.FULL_DATA_WIDTH { PARAM_VALUE.FULL_DATA_WIDTH PARAM_VALUE.DB_BRAMCTRL_MODE PARAM_VALUE.DB_BRAM_DATA_WIDTH } {
	# Procedure called to update FULL_DATA_WIDTH when any of the dependent parameters in the arguments change
	
	set FULL_DATA_WIDTH ${PARAM_VALUE.FULL_DATA_WIDTH}
	set DB_BRAMCTRL_MODE ${PARAM_VALUE.DB_BRAMCTRL_MODE}
	set DB_BRAM_DATA_WIDTH ${PARAM_VALUE.DB_BRAM_DATA_WIDTH}
	set values(DB_BRAMCTRL_MODE) [get_property value $DB_BRAMCTRL_MODE]
	set values(DB_BRAM_DATA_WIDTH) [get_property value $DB_BRAM_DATA_WIDTH]
	set_property value [gen_USERPARAMETER_FULL_DATA_WIDTH_VALUE $values(DB_BRAMCTRL_MODE) $values(DB_BRAM_DATA_WIDTH)] $FULL_DATA_WIDTH
}

proc validate_PARAM_VALUE.FULL_DATA_WIDTH { PARAM_VALUE.FULL_DATA_WIDTH } {
	# Procedure called to validate FULL_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.FULL_WEN_WIDTH { PARAM_VALUE.FULL_WEN_WIDTH PARAM_VALUE.DB_BRAMCTRL_MODE PARAM_VALUE.FULL_DATA_WIDTH } {
	# Procedure called to update FULL_WEN_WIDTH when any of the dependent parameters in the arguments change
	
	set FULL_WEN_WIDTH ${PARAM_VALUE.FULL_WEN_WIDTH}
	set DB_BRAMCTRL_MODE ${PARAM_VALUE.DB_BRAMCTRL_MODE}
	set FULL_DATA_WIDTH ${PARAM_VALUE.FULL_DATA_WIDTH}
	set values(DB_BRAMCTRL_MODE) [get_property value $DB_BRAMCTRL_MODE]
	set values(FULL_DATA_WIDTH) [get_property value $FULL_DATA_WIDTH]
	set_property value [gen_USERPARAMETER_FULL_WEN_WIDTH_VALUE $values(DB_BRAMCTRL_MODE) $values(FULL_DATA_WIDTH)] $FULL_WEN_WIDTH
}

proc validate_PARAM_VALUE.FULL_WEN_WIDTH { PARAM_VALUE.FULL_WEN_WIDTH } {
	# Procedure called to validate FULL_WEN_WIDTH
	return true
}

proc update_PARAM_VALUE.DB_ADDRESS { PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to update DB_ADDRESS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_ADDRESS { PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to validate DB_ADDRESS
	return true
}

proc update_PARAM_VALUE.DB_BRAMCTRL_MODE { PARAM_VALUE.DB_BRAMCTRL_MODE } {
	# Procedure called to update DB_BRAMCTRL_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_BRAMCTRL_MODE { PARAM_VALUE.DB_BRAMCTRL_MODE } {
	# Procedure called to validate DB_BRAMCTRL_MODE
	return true
}

proc update_PARAM_VALUE.DB_BRAM_ADDR_WIDTH { PARAM_VALUE.DB_BRAM_ADDR_WIDTH } {
	# Procedure called to update DB_BRAM_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_BRAM_ADDR_WIDTH { PARAM_VALUE.DB_BRAM_ADDR_WIDTH } {
	# Procedure called to validate DB_BRAM_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.DB_BRAM_DATA_WIDTH { PARAM_VALUE.DB_BRAM_DATA_WIDTH } {
	# Procedure called to update DB_BRAM_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_BRAM_DATA_WIDTH { PARAM_VALUE.DB_BRAM_DATA_WIDTH } {
	# Procedure called to validate DB_BRAM_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.DB_DAISY_CHAIN { PARAM_VALUE.DB_DAISY_CHAIN } {
	# Procedure called to update DB_DAISY_CHAIN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DAISY_CHAIN { PARAM_VALUE.DB_DAISY_CHAIN } {
	# Procedure called to validate DB_DAISY_CHAIN
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

proc update_MODELPARAM_VALUE.DB_BRAM_DATA_WIDTH { MODELPARAM_VALUE.DB_BRAM_DATA_WIDTH PARAM_VALUE.DB_BRAM_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_BRAM_DATA_WIDTH}] ${MODELPARAM_VALUE.DB_BRAM_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.DB_BRAM_ADDR_WIDTH { MODELPARAM_VALUE.DB_BRAM_ADDR_WIDTH PARAM_VALUE.DB_BRAM_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_BRAM_ADDR_WIDTH}] ${MODELPARAM_VALUE.DB_BRAM_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.DB_BRAMCTRL_MODE { MODELPARAM_VALUE.DB_BRAMCTRL_MODE PARAM_VALUE.DB_BRAMCTRL_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_BRAMCTRL_MODE}] ${MODELPARAM_VALUE.DB_BRAMCTRL_MODE}
}

proc update_MODELPARAM_VALUE.FULL_ADDR_WIDTH { MODELPARAM_VALUE.FULL_ADDR_WIDTH PARAM_VALUE.FULL_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FULL_ADDR_WIDTH}] ${MODELPARAM_VALUE.FULL_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.FULL_DATA_WIDTH { MODELPARAM_VALUE.FULL_DATA_WIDTH PARAM_VALUE.FULL_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FULL_DATA_WIDTH}] ${MODELPARAM_VALUE.FULL_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.FULL_WEN_WIDTH { MODELPARAM_VALUE.FULL_WEN_WIDTH PARAM_VALUE.FULL_WEN_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FULL_WEN_WIDTH}] ${MODELPARAM_VALUE.FULL_WEN_WIDTH}
}

proc update_MODELPARAM_VALUE.DB_DAISY_CHAIN { MODELPARAM_VALUE.DB_DAISY_CHAIN PARAM_VALUE.DB_DAISY_CHAIN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DAISY_CHAIN}] ${MODELPARAM_VALUE.DB_DAISY_CHAIN}
}

