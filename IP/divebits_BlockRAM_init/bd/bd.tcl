proc init { cellpath otherInfo } {
	#puts "Entering proc init... Cell path: $cellpath"
}

proc pre_propagate {cellpath otherInfo } {                                                                   
	#puts "Entering proc pre_propagate... Cell path: $cellpath"
}

proc propagate {cellpath otherInfo } {                                                               
	#puts "Entering proc propagate... Cell path: $cellpath"
}

proc post_propagate {cellpath otherInfo } {                                                               
	#puts "Entering proc post_propagate... Cell path: $cellpath"
}

proc post_config_ip {cellName undefined_params} {

  #set ip [get_bd_cells $cellName]
  
  #set db_bram_ctrl_mode [get_property CONFIG.DB_BRAMCTRL_MODE $ip]
  #set db_bram_data_width [get_property CONFIG.DB_BRAM_DATA_WIDTH $ip]
  #set db_bram_num_words_width [get_property CONFIG.DB_BRAM_NUM_WORDS $ip]
  
  #puts "STUFF WAS SET !!"
  
  #set_property CONFIG.DB_ADDRESS 42  [get_bd_cells $ip]
  
  
  
#  set busif [get_bd_intf_pins $cellName/BRAM_PORTA]
  #set busifb [get_bd_intf_pins $cellName/BRAM_PORTB]
  #set value_src [get_property CONFIG.WRITE_DEPTH_A.VALUE_SRC $ip]
#  if { [string match -nocase $value_src "user"] eq 1 } {
#     set_property CONFIG.WRITE_DEPTH_A.VALUE_SRC DEFAULT [get_bd_cells $ip]
#  }
#  set value_src [get_property CONFIG.WRITE_DEPTH_A.VALUE_SRC $ip]
  #set bmg_mode [get_property CONFIG.use_bram_block $ip]
  #set tdp [get_property CONFIG.MEMORY_TYPE $ip]
  #if { $bmg_mode == "BRAM_Controller" } {
   #  set_property CONFIG.MASTER_TYPE "BRAM_CTRL" $busif
    # set port_master_type [get_property CONFIG.MASTER_TYPE $busif]
     #if { $tdp == "True_Dual_Port_RAM" || $tdp == "Dual_Port_ROM"} {
     #   set_property CONFIG.MASTER_TYPE "BRAM_CTRL" $busifb
     #}

  #} else {
   #  set_property CONFIG.MASTER_TYPE "OTHER" $busif
    # set port_master_type [get_property CONFIG.MASTER_TYPE $busif]
     #if { $tdp == "True_Dual_Port_RAM" || $tdp == "Dual_Port_ROM"} {
      #  set_property CONFIG.MASTER_TYPE "OTHER" $busifb
     #}
  #}
} 
