namespace eval subDB {

proc _get_script_dir {} {
	
	set script_path [file normalize [info script]]
	set script_folder [file dirname $script_path]
	return $script_folder
}


### TODO: Account for Non-Project Batch mode!
### TODO: Allow to set path by parameter
proc _establish_data_path {} {

	global env

	if { [ info exists env(DIVEBITS_PROJECT_PATH) ] } {
		set db_prj_path $env(DIVEBITS_PROJECT_PATH)
	} else {
		set db_prj_path [ get_property DIRECTORY [current_project] ]
		set db_prj_path "${db_prj_path}/divebits"
		set env(DIVEBITS_PROJECT_PATH) $db_prj_path
	}
	
	file mkdir $db_prj_path
	file mkdir "${db_prj_path}/1_extracted_components"
	file mkdir "${db_prj_path}/2_mmi_files"
	file mkdir "${db_prj_path}/3_input_bitstream"
	file mkdir "${db_prj_path}/4_config_file_template"
	file mkdir "${db_prj_path}/5_bitstream_config_files"
	file mkdir "${db_prj_path}/6_output_bitstreams"
}


proc _open_block_diagram {} {

	### TODO allow specifying BD path

	set design_fileset [ lindex [ get_filesets -filter { FILESET_TYPE == DesignSrcs } ] 0 ]
	set block_design_path [ get_files -of_objects $design_fileset -filter { FILE_TYPE == "Block Designs" } ]
	open_bd_design $block_design_path
}


proc _extract_block_diagram_components {} {

	global env

	set blocklist [ get_bd_cells -hierarchical ]

	## identify and remove divebits config block
	foreach block $blocklist {
			set DB_ADDRESS [ get_property CONFIG.DB_ADDRESS [ get_bd_cells $block ] ]
			if { $DB_ADDRESS == 0 } {
				set config_block $block
				set blocklist [ lsearch -all -inline -not -exact $blocklist $config_block ]
				set configname [ get_property NAME [ get_bd_cells $block ] ]
				set configpath [ get_property PATH [ get_bd_cells $block ] ]
			}
		}
	### TODO check that there's exactly 1 config block

	set yamlpath "${env(DIVEBITS_PROJECT_PATH)}/1_extracted_components/db_components.yaml"
	set yamlfile [open $yamlpath w]

	# extract config block data
	puts $yamlfile "db_config_block:"
	puts $yamlfile "  NAME: $configname"
	puts $yamlfile "  PATH: $configpath"

	## output all DB_* properties
	set PROPLIST [ list_property $config_block ]
	set PROPLIST [ lsearch -all -inline -glob $PROPLIST "CONFIG.DB*" ]
	foreach prop $PROPLIST {
			set propval [ get_property $prop [ get_bd_cells $config_block ] ]
			set prop [ string range $prop 7 [ string length $prop ] ]
			puts $yamlfile "  $prop: $propval"
		}
	puts $yamlfile ""

	
	
	## remove non-divebits components
	foreach block $blocklist {
			set DB_ADDRESS [ get_property CONFIG.DB_ADDRESS [ get_bd_cells $block ] ]
			if { [ string length $DB_ADDRESS ] == 0 } {
				set blocklist [ lsearch -all -inline -not -exact $blocklist $block ]
			}
		}


		
	## Make sure each DB_ADDRESS is only used once
	# Get DB addresses into list
	set db_addr_list []
	foreach block $blocklist { lappend db_addr_list [ get_property CONFIG.DB_ADDRESS $block ] }

	if { [ llength $db_addr_list ] != [ llength $blocklist ] } {
		puts "ERROR: Incorrect number of Divebits component addresses"
		return 0
	}
	
	
	set new_addr_iterator 1
	
	for {set i 0} {$i < [ llength $db_addr_list ] } {incr i} {
		
		set db_addr [ lindex $db_addr_list $i ]
		set curr_pos [ lsearch $db_addr_list $db_addr ]
		set next_pos [ lsearch -start $curr_pos+1   $db_addr_list $db_addr ]
		
		# if number turns up again change second iteration
		if { $next_pos != -1} {
			# find new number not in the list yet
			while { [ lsearch $db_addr_list $new_addr_iterator ] != -1} { incr new_addr_iterator }
			# change in block properties
			set_property CONFIG.DB_ADDRESS $new_addr_iterator [ lindex $blocklist $next_pos ]
			# change in address list			
			lset db_addr_list $next_pos $new_addr_iterator
		}
		
	}
	### TODO check user authorization? Validate? Only do when double numbers are there?
	save_bd_design
		

	# start component list
	puts $yamlfile "db_components:"

	## output all DB_* properties
	foreach block $blocklist {
			set compname [ get_property NAME [ get_bd_cells $block ] ]
			set comppath [ get_property PATH [ get_bd_cells $block ] ]
			puts $yamlfile "  - component:"
			puts $yamlfile "    NAME: $compname"
			puts $yamlfile "    PATH: $comppath"
			
			set PROPLIST [ list_property  $block ]
			set PROPLIST [ lsearch -all -inline -glob $PROPLIST "CONFIG.DB*" ]
			foreach prop $PROPLIST {
					set propval [ get_property $prop [ get_bd_cells $block ] ]
					set prop [ string range $prop 7 [ string length $prop ] ]
					puts $yamlfile "    $prop: $propval"
				}
			puts $yamlfile ""
		}
		
	# close and check-print YAML file
	close $yamlfile
	#set yamltext [read [open $yamlpath r]]
#	puts "" ; puts "" ; puts $yamltext
}


proc _call_python3_script { py_script_path args } {

	global env

	## save and clear Python path variables, so Python 2.x is out
	if { [ info exists env(PYTHONPATH) ] } {
		set PYTHONPATH_bak $env(PYTHONPATH)
		unset env(PYTHONPATH)
	}
	if { [ info exists env(PYTHONHOME) ] } {
		set PYTHONHOME_bak $env(PYTHONHOME)
		unset env(PYTHONHOME)
	}
	
	## run script
	set py_output [ exec python3 $py_script_path $args ]
	puts $py_output

	## restore path variables
	if { [ info exists env(PYTHONPATH_bak) ] } {
		set env(PYTHONPATH) $PYTHONPATH_bak 
	}

	if { [ info exists env(PYTHONHOME_bak) ] } {
		set env(PYTHONHOME) $PYTHONHOME_bak
	}
	
	return

}


proc _open_implementation {} {

	### TODO allow specifying implementation run - this takes first one
	set design_fileset [ lindex [ get_filesets -filter { FILESET_TYPE == DesignSrcs } ] 0 ]
	set implementation_run [ lindex [ get_runs -filter " IS_IMPLEMENTATION == true && SRCSET == ${design_fileset}" ] 0 ]
	### TODO check if there is one left
	set progress [ get_property PROGRESS [ get_runs $implementation_run ] ]
	if { $progress != "100%" } {
		puts "ERROR: Unfinished implementation run."
		return -code error
	}
	
	set needs_refresh [ get_property NEEDS_REFRESH [ get_runs $implementation_run ] ]
	if { $needs_refresh == 1 } {
		puts "ERROR: Implementation run not up-to-date."
		return -code error
	}
	
	open_run $implementation_run
	
	set impl_run_dir [ get_property DIRECTORY [ get_runs $implementation_run ] ]
	return $impl_run_dir
	
}


proc _extract_brams {} {

	# get all BRAMs in implementation
	set bmemlist [ get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ BMEM.*.* } ]
	
	set ramlist [ lsearch -all -inline $bmemlist *divebits_rom32k_gen_magic1701* ]
	if {  [ llength $ramlist ] == 0 } {
		puts "ERROR: No DiveBits config BRAMs found";
		return 0
	}
	set ramlist [ lsort $ramlist ]
	
	set loclist []
	set loclist_stripped []

	foreach ram $ramlist { lappend loclist [ get_property LOC $ram ] }
	foreach loc $loclist { lappend loclist_stripped [ string range $loc 7 [ string length $loc ]-1 ] }

	return $loclist_stripped
}


proc _generate_mmi_file { filepath loclist device } {

	set bram_count [llength $loclist]
	set mem_top [ expr (4096*$bram_count)-1 ]

	set mmifile [open $filepath w]
	puts $mmifile "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
	puts $mmifile ""
	puts $mmifile "<MemInfo Version=\"1\" Minor=\"6\">"
	puts $mmifile ""
	puts $mmifile "	<Processor Endianness=\"Little\" InstPath=\"divebits/config\">"
	
	
	puts $mmifile "		<AddressSpace Name=\"db_config_BRAMs\" Begin=\"0\" End=\"${mem_top}\">"
	puts $mmifile ""
	
	set first_word 0
	
	for { set i 0 } { $i < $bram_count } { incr i } {
		set loc [ lindex $loclist $i ]
		set last_word [ expr $first_word+1023 ]
	
		puts $mmifile "			<BusBlock>"
		puts $mmifile "				<BitLane MemType=\"RAMB36\" Placement=\"${loc}\">"
		puts $mmifile "					<DataWidth MSB=\"31\" LSB=\"0\"/>"
		puts $mmifile "						<AddressRange Begin=\"${first_word}\" End=\"${last_word}\"/>"
		puts $mmifile "					<Parity ON=\"false\" NumBits=\"0\"/>"
		puts $mmifile "				</BitLane>"
		puts $mmifile "			</BusBlock>"
		puts $mmifile ""
		set first_word [ expr $last_word+1 ]
		
	}
	
	puts $mmifile "		</AddressSpace>"
	puts $mmifile "	</Processor>"
	puts $mmifile ""
	puts $mmifile "	<Config>"
	puts $mmifile "		<Option Name=\"Part\" Val=\"${device}\"/>"
	puts $mmifile "	</Config>"

	puts $mmifile ""
	puts $mmifile "	<DRC>"
	puts $mmifile "		<Rule Name=\"RDADDRCHANGE\" Val=\"false\"/>"
	puts $mmifile "	</DRC>"
	puts $mmifile ""
	puts $mmifile "</MemInfo>"

	close $mmifile
}

}
# end of subDB namespace




proc DB_component_extraction { args } {

	::subDB::_establish_data_path
	::subDB::_open_block_diagram
	::subDB::_extract_block_diagram_components
	
	::subDB::_call_python3_script  "/home/willenbe/Projekte/divebits-dev/divebits_tools/make_template_file.py"  $args
	### TODO check success of each, add success/failure message
}


proc DB_get_memory_data_and_bitstream {} {

	global env
	
	::subDB::_establish_data_path
	set impl_run_dir [ ::subDB::_open_implementation ]
	
	set ram_locs [ ::subDB::_extract_brams ]
	set project_device [ get_parts -of_objects [get_projects] ]
	
	::subDB::_generate_mmi_file "${env(DIVEBITS_PROJECT_PATH)}/2_mmi_files/db_config_rams.mmi" $ram_locs $project_device

	set bitstream_path [ glob -nocomplain $impl_run_dir/*.bit ]
	if { 0 == [ llength $bitstream_path ] } {
		puts "INFO: No bitstream available yet, therefore not copied"
	} else {
		file copy -force $bitstream_path "${env(DIVEBITS_PROJECT_PATH)}/3_input_bitstream/input.bit"
		puts "INFO: Copied $bitstream_path to  /3_input_bitstream/  folder."
	}
	
}


proc DB_get_other_input_bitstream { args } {

	global env
	global divebits_external_bitstream
	
	::subDB::_establish_data_path
	
	if { [ llength $args ] < 1 } {
		
		if { [ info exists divebits_external_bitstream ] == 0 } {
			puts "ERROR: No bitstream specified, no previous specification."
			return -code error
		} elseif { [ file exists $divebits_external_bitstream ] == 0 } {
			puts "ERROR: No bitstream specified and previous bitstream path doesn't exist anymore."
			return -code error
		}
	} else {
	
		set bitstream_path [ lindex $args 0 ]
		if { [ string length $bitstream_path ] != 0 } {
			if { [ file exists $bitstream_path ] == 0 } {
				puts "ERROR: Specified bitstream doesn't exist."
				return -code error
			} else {
				set divebits_external_bitstream $bitstream_path
			}
		} else {
			puts "ERROR: Specified bitstream doesn't exist."
			return -code error
		}
	}
		
	file copy -force $divebits_external_bitstream "${env(DIVEBITS_PROJECT_PATH)}/3_input_bitstream/input.bit"
	puts "INFO: Copied $divebits_external_bitstream to  /3_input_bitstream/  folder."
}


proc DB_generate_bitstreams {} {
}



set message "\n" ; append message "\n" ; append message "\n" ; append message "\n"
append message "***************************************************************************" ; append message "\n"
append message " call  DB_component_extraction              after block design is finished " ; append message "\n"
append message "" ; append message "\n"
append message " call  DB_get_memory_data_and_bitstream     after implementation           " ; append message "\n"
append message "" ; append message "\n"
append message " call  DB_get_other_input_bitstream \$path   if other bitstream (e.g. SDK)  " ; append message "\n"
append message "" ; append message "\n"
append message " call  DB_generate_bitstreams               to make diversified bitstreams " ; append message "\n"
append message "***************************************************************************" ; append message "\n"