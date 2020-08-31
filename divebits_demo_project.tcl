namespace eval build_functions {

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -type rst SYS_Rst

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:* dlmb_bram_if_cntlr ]
  set_property -dict [ list \
						CONFIG.C_ECC {0} \
						] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:* dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:* ilmb_bram_if_cntlr ]
  set_property -dict [ list \
						CONFIG.C_ECC {0} \
						] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:* ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:* lmb_bram ]
  set_property -dict [ list \
						CONFIG.Memory_Type {True_Dual_Port_RAM} \
						CONFIG.use_bram_block {BRAM_Controller} \
						] $lmb_bram

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set LED [ create_bd_port -dir O -from 7 -to 0 LED ]
  set reset_rtl [ create_bd_port -dir I -type rst reset_rtl ]
  set_property -dict [ list \
						CONFIG.POLARITY {ACTIVE_HIGH} \
						] $reset_rtl
  set rx [ create_bd_port -dir I rx ]
  set sys_clock [ create_bd_port -dir I -type clk sys_clock ]
  set_property -dict [ list \
						CONFIG.FREQ_HZ {100000000} \
						CONFIG.PHASE {0.000} \
						] $sys_clock
  set tx [ create_bd_port -dir O tx ]

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:* axi_bram_ctrl_0 ]
						set_property -dict [ list \
						CONFIG.SINGLE_PORT_BRAM {1} \
						] $axi_bram_ctrl_0

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:* axi_uartlite_0 ]
						set_property -dict [ list \
						CONFIG.C_BAUDRATE {115200} \
						] $axi_uartlite_0

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:* blk_mem_gen_0 ]
  set_property -dict [ list \
						CONFIG.Byte_Size {8} \
						CONFIG.Enable_32bit_Address {true} \
						CONFIG.Enable_A {Always_Enabled} \
						CONFIG.Enable_B {Use_ENB_Pin} \
						CONFIG.Memory_Type {True_Dual_Port_RAM} \
						CONFIG.Port_B_Clock {100} \
						CONFIG.Port_B_Enable_Rate {100} \
						CONFIG.Port_B_Write_Rate {50} \
						CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
						CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
						CONFIG.Use_Byte_Write_Enable {true} \
						CONFIG.Use_RSTA_Pin {true} \
						CONFIG.Use_RSTB_Pin {true} \
						CONFIG.use_bram_block {BRAM_Controller} \
						] $blk_mem_gen_0

  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:* clk_wiz_1 ]
  set_property -dict [ list \
						CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
						CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
						CONFIG.USE_BOARD_FLOW {true} \
						] $clk_wiz_1

  # Create instance: divebits_AXI_4_constant_registers_0, and set properties
  set divebits_AXI_4_constant_registers_0 [ create_bd_cell -type ip -vlnv hs-mannheim.de:divebits:divebits_AXI_4_constant_registers:* divebits_AXI_4_constant_registers_0 ]
  set_property -dict [ list \
						CONFIG.DB_DEFAULT_VALUE {42} \
						] $divebits_AXI_4_constant_registers_0

  # Create instance: divebits_AXI_Master_WriteOnly_0, and set properties
  set divebits_AXI_Master_WriteOnly_0 [ create_bd_cell -type ip -vlnv hs-mannheim.de:divebits:divebits_AXI_Master_WriteOnly:* divebits_AXI_Master_WriteOnly_0 ]
  set_property -dict [ list \
						CONFIG.DB_ADDRESS {2} \
						CONFIG.DB_NUM_CODE_WORDS {128} \
						] $divebits_AXI_Master_WriteOnly_0

  # Create instance: divebits_BlockRAM_init_0, and set properties
  set divebits_BlockRAM_init_0 [ create_bd_cell -type ip -vlnv hs-mannheim.de:divebits:divebits_BlockRAM_init:* divebits_BlockRAM_init_0 ]
  set_property -dict [ list \
						CONFIG.DB_ADDRESS {3} \
						CONFIG.DB_BRAMCTRL_MODE {true} \
						CONFIG.DB_BRAM_ADDR_WIDTH {9} \
						CONFIG.FULL_ADDR_WIDTH {32} \
						CONFIG.FULL_WEN_WIDTH {4} \
						] $divebits_BlockRAM_init_0

  # Create instance: divebits_config_0, and set properties
  set divebits_config_0 [ create_bd_cell -type ip -vlnv hs-mannheim.de:divebits:divebits_config:* divebits_config_0 ]
  set_property -dict [ list \
						CONFIG.DB_DAISY_CHAIN_CRC_CHECK {true} \
						] $divebits_config_0

  # Create instance: divebits_constant_vector_0, and set properties
  set divebits_constant_vector_0 [ create_bd_cell -type ip -vlnv hs-mannheim.de:divebits:divebits_constant_vector:* divebits_constant_vector_0 ]
  set_property -dict [ list \
						CONFIG.DB_ADDRESS {4} \
						CONFIG.DB_DEFAULT_VALUE {3} \
						CONFIG.DB_VECTOR_WIDTH {4} \
						] $divebits_constant_vector_0

  # Create instance: divebits_constant_vector_1, and set properties
  set divebits_constant_vector_1 [ create_bd_cell -type ip -vlnv hs-mannheim.de:divebits:divebits_constant_vector:* divebits_constant_vector_1 ]
  set_property -dict [ list \
						CONFIG.DB_ADDRESS {5} \
						CONFIG.DB_DEFAULT_VALUE {7} \
						CONFIG.DB_VECTOR_WIDTH {4} \
						] $divebits_constant_vector_1

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:* microblaze_0 ]
  set_property -dict [ list \
						CONFIG.C_DEBUG_ENABLED {0} \
						CONFIG.C_D_AXI {1} \
						CONFIG.C_D_LMB {1} \
						CONFIG.C_I_LMB {1} \
						] $microblaze_0

  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:* microblaze_0_axi_periph ]
  set_property -dict [ list \
						CONFIG.NUM_MI {3} \
						CONFIG.NUM_SI {2} \
						] $microblaze_0_axi_periph

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory [current_bd_instance .] microblaze_0_local_memory

  # Create instance: rst_clk_wiz_1_100M, and set properties
  set rst_clk_wiz_1_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:* rst_clk_wiz_1_100M ]

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:* xlconcat_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTB]
  connect_bd_intf_net -intf_net divebits_AXI_4_constant_registers_0_DiveBits_out [get_bd_intf_pins divebits_AXI_4_constant_registers_0/DiveBits_out] [get_bd_intf_pins divebits_BlockRAM_init_0/DiveBits_in]
  connect_bd_intf_net -intf_net divebits_AXI_Master_WriteOnly_0_DiveBits_out [get_bd_intf_pins divebits_AXI_Master_WriteOnly_0/DiveBits_out] [get_bd_intf_pins divebits_config_0/DiveBits_Feedback]
  connect_bd_intf_net -intf_net divebits_AXI_Master_WriteOnly_0_M00_AXI [get_bd_intf_pins divebits_AXI_Master_WriteOnly_0/M00_AXI] [get_bd_intf_pins microblaze_0_axi_periph/S01_AXI]
  connect_bd_intf_net -intf_net divebits_BlockRAM_init_0_BRAM_INIT [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA] [get_bd_intf_pins divebits_BlockRAM_init_0/BRAM_INIT]
  connect_bd_intf_net -intf_net divebits_BlockRAM_init_0_DiveBits_out [get_bd_intf_pins divebits_AXI_Master_WriteOnly_0/DiveBits_in] [get_bd_intf_pins divebits_BlockRAM_init_0/DiveBits_out]
  connect_bd_intf_net -intf_net divebits_config_0_DiveBits_Out [get_bd_intf_pins divebits_config_0/DiveBits_Out] [get_bd_intf_pins divebits_constant_vector_0/DiveBits_in]
  connect_bd_intf_net -intf_net divebits_constant_vector_0_DiveBits_out [get_bd_intf_pins divebits_constant_vector_0/DiveBits_out] [get_bd_intf_pins divebits_constant_vector_1/DiveBits_in]
  connect_bd_intf_net -intf_net divebits_constant_vector_1_DiveBits_out [get_bd_intf_pins divebits_AXI_4_constant_registers_0/DiveBits_in] [get_bd_intf_pins divebits_constant_vector_1/DiveBits_out]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DP [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M00_AXI [get_bd_intf_pins divebits_AXI_4_constant_registers_0/S00_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]

  # Create port connections
  connect_bd_net -net axi_uartlite_0_tx [get_bd_ports tx] [get_bd_pins axi_uartlite_0/tx]
  connect_bd_net -net clk_wiz_1_locked [get_bd_pins clk_wiz_1/locked] [get_bd_pins divebits_config_0/sys_release_in]
  connect_bd_net -net divebits_config_0_sys_release_out [get_bd_pins divebits_config_0/sys_release_out] [get_bd_pins rst_clk_wiz_1_100M/dcm_locked]
  connect_bd_net -net divebits_constant_vector_0_Vector_out [get_bd_pins divebits_constant_vector_0/Vector_out] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net divebits_constant_vector_1_Vector_out [get_bd_pins divebits_constant_vector_1/Vector_out] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins divebits_AXI_4_constant_registers_0/s00_axi_aclk] [get_bd_pins divebits_AXI_Master_WriteOnly_0/m00_axi_aclk] [get_bd_pins divebits_config_0/sys_clock_in] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins microblaze_0_axi_periph/S01_ACLK] [get_bd_pins microblaze_0_local_memory/LMB_Clk] [get_bd_pins rst_clk_wiz_1_100M/slowest_sync_clk]
  connect_bd_net -net reset_rtl_1 [get_bd_ports reset_rtl] [get_bd_pins clk_wiz_1/reset] [get_bd_pins rst_clk_wiz_1_100M/ext_reset_in]
  connect_bd_net -net rst_clk_wiz_1_100M_bus_struct_reset [get_bd_pins microblaze_0_local_memory/SYS_Rst] [get_bd_pins rst_clk_wiz_1_100M/bus_struct_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_interconnect_aresetn [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins rst_clk_wiz_1_100M/interconnect_aresetn]
  connect_bd_net -net rst_clk_wiz_1_100M_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins rst_clk_wiz_1_100M/mb_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins divebits_AXI_4_constant_registers_0/s00_axi_aresetn] [get_bd_pins divebits_AXI_Master_WriteOnly_0/m00_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins microblaze_0_axi_periph/S01_ARESETN] [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn]
  connect_bd_net -net rx_1 [get_bd_ports rx] [get_bd_pins axi_uartlite_0/rx]
  connect_bd_net -net sys_clock_1 [get_bd_ports sys_clock] [get_bd_pins clk_wiz_1/clk_in1]
  connect_bd_net -net xlconcat_0_dout [get_bd_ports LED] [get_bd_pins xlconcat_0/dout]

  # Create address segments
  create_bd_addr_seg -range 0x00002000 -offset 0xC0000000 [get_bd_addr_spaces divebits_AXI_Master_WriteOnly_0/M00_AXI] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0x40600000 [get_bd_addr_spaces divebits_AXI_Master_WriteOnly_0/M00_AXI] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces divebits_AXI_Master_WriteOnly_0/M00_AXI] [get_bd_addr_segs divebits_AXI_4_constant_registers_0/S00_AXI/S00_AXI_reg] SEG_divebits_AXI_4_constant_registers_0_S00_AXI_reg
  create_bd_addr_seg -range 0x00002000 -offset 0xC0000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0x40600000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs divebits_AXI_4_constant_registers_0/S00_AXI/S00_AXI_reg] SEG_divebits_AXI_4_constant_registers_0_S00_AXI_reg
  create_bd_addr_seg -range 0x00004000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00004000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs microblaze_0_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()

proc sleep {N} {
   after [expr {int($N * 1000)}]
}

}
# End of namespace build_functions


##################################################################
# MAIN FLOW
##################################################################

proc demo_1_create_project_and_block_design { {specified_project_path ""} } {

	global DEMOBUILD_SCRIPT_FOLDER
	global DEMOBUILD_OLD_FOLDER
	global DEMO_PROJECT_PATH
	global ELF_BIT_PATH
	
	set list_projs [get_projects -quiet]
	if { $list_projs ne "" } {
		puts "DIVEBITS DEMO ERROR: Please close all open Vivado projects first."
		return 1
	}

	if { $specified_project_path == "" } {
		set DEMO_PROJECT_PATH "${DEMOBUILD_SCRIPT_FOLDER}/demo_project_files/default_project_path"
	} else {
		set DEMO_PROJECT_PATH [ file join [pwd] $specified_project_path ]
	}

	# TODO: catch error if it exists as file, not dir
	file mkdir $DEMO_PROJECT_PATH

	if { [ glob -nocomplain -dir $DEMO_PROJECT_PATH * ] ne "" } {
		puts "DIVEBITS DEMO ERROR: Specified project path $DEMO_PROJECT_PATH ist not empty. Please clear out first."
		return 1
	}

	puts ""
	puts "-------------------------------------------------------------------"
	puts "DIVEBITS DEMO PROJECT: Starting to create project and block design."
	puts "-------------------------------------------------------------------"
	puts ""
	build_functions::sleep 2

	set ELF_BIT_PATH "${DEMO_PROJECT_PATH}/elf_prebuilt/download.bit"

	## CHANGE IF YOU WANT TO USE A DIFFERENT CHIP
	set device_used "xc7z020clg484-1"

	file mkdir $DEMO_PROJECT_PATH/bd
	file mkdir $DEMO_PROJECT_PATH/constraints
	file mkdir $DEMO_PROJECT_PATH/csrc
	file mkdir $DEMO_PROJECT_PATH/elf_prebuilt

	file copy $DEMOBUILD_SCRIPT_FOLDER/demo_project_files/db_demo_zedboard.xdc  $DEMO_PROJECT_PATH/constraints
	file copy $DEMOBUILD_SCRIPT_FOLDER/demo_project_files/db_demo.c             $DEMO_PROJECT_PATH/csrc
	file copy $DEMOBUILD_SCRIPT_FOLDER/demo_project_files/divebits_demo.elf     $DEMO_PROJECT_PATH/elf_prebuilt

	cd $DEMO_PROJECT_PATH


	# create project	
	create_project db_demo_prj db_demo_prj -part $device_used
	set_property TARGET_LANGUAGE vhdl [current_project]


	# Create block design
	set design_name db_demo_block

	set bd_origin_dir ./bd
	set str_bd_folder [file normalize ${bd_origin_dir}]
	set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

	create_bd_design -dir $str_bd_folder $design_name
	current_bd_design $design_name



	set DB_REPO "${DEMOBUILD_SCRIPT_FOLDER}/block_ip_xil"
	set IP_REPO_LIST {}
	lappend IP_REPO_LIST $DB_REPO
	set_property  ip_repo_paths  $IP_REPO_LIST [current_project]
	update_ip_catalog

	build_functions::create_root_design ""
	make_wrapper -files [get_files ${str_bd_filepath}] -top
	add_files -norecurse ${str_bd_folder}/db_demo_block/hdl/db_demo_block_wrapper.vhd
	update_compile_order -fileset sources_1
	update_compile_order -fileset sim_1

	add_files -fileset constrs_1 -norecurse ${DEMO_PROJECT_PATH}/constraints/db_demo_zedboard.xdc
	
	cd $DEMOBUILD_OLD_FOLDER
	
}


proc demo_2_build_bitstream {} {

	puts ""
	puts "------------------------------------------------------------"
	puts "DIVEBITS DEMO PROJECT: Starting implementation to bitstream;"
	puts "                       please wait for completion."
	puts "------------------------------------------------------------"
	puts ""
	build_functions::sleep 2

	global DEMOBUILD_SCRIPT_FOLDER
	global DEMOBUILD_OLD_FOLDER
	global DEMO_PROJECT_PATH

	cd $DEMO_PROJECT_PATH

	launch_runs impl_1 -quiet -to_step write_bitstream -jobs 8

	cd $DEMOBUILD_OLD_FOLDER
	
	puts ""
	puts "-------------------------------------------------------"
	puts "DIVEBITS DEMO PROJECT: Finished implementing bitstream."
	puts "-------------------------------------------------------"
	puts ""
	
}


proc demo_3_add_microblaze_binary {} {

	puts ""
	puts "-------------------------------------------------------------"
	puts "DIVEBITS DEMO PROJECT: Adding MicroBlaze binary to bitstream."
	puts "-------------------------------------------------------------"
	puts ""
	build_functions::sleep 1


	global DEMOBUILD_SCRIPT_FOLDER
	global DEMOBUILD_OLD_FOLDER
	global DEMO_PROJECT_PATH

	cd $DEMO_PROJECT_PATH
	
	open_run impl_1
	write_mem_info -force -quiet -verbose ./elf_prebuilt/bram_locs.mmi
	exec updatemem -force -meminfo ./elf_prebuilt/bram_locs.mmi -data ./elf_prebuilt/divebits_demo.elf \
				-bit ./db_demo_prj/db_demo_prj.runs/impl_1/db_demo_block_wrapper.bit \
				-proc db_demo_block_i/microblaze_0 -out ./elf_prebuilt/download.bit
				
	cd $DEMOBUILD_OLD_FOLDER
	
	puts ""
	puts "------------------------------------------------------------"
	puts "DIVEBITS DEMO PROJECT: MicroBlaze binary added to bitstream."
	puts "------------------------------------------------------------"
	puts ""
	
}


proc demo_4_delete_project {} {

	global DEMOBUILD_SCRIPT_FOLDER
	global DEMOBUILD_OLD_FOLDER
	global DEMO_PROJECT_PATH
	
	set list_projs [get_projects -quiet]
	if { $list_projs ne "" } {
		close_project
	}
	
	file delete -force -- $DEMO_PROJECT_PATH
	
	cd $DEMOBUILD_OLD_FOLDER
	
	puts ""
	puts "---------------------------------------"
	puts "DIVEBITS DEMO PROJECT: Project deleted."
	puts "---------------------------------------"
	puts ""	
}



# set script path
global DEMOBUILD_SCRIPT_FOLDER
global DEMOBUILD_OLD_FOLDER

set script_path [file normalize [info script]]
set DEMOBUILD_SCRIPT_FOLDER [file dirname $script_path]
set DEMOBUILD_OLD_FOLDER [ pwd ]
puts "\n\n\n\n\n\n\n\n\n\n\n\n"
