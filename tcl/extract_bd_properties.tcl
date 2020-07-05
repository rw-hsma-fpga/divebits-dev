proc goto_script_path {} {
	## go to local project path
	global script_folder
	global old_folder
	
	set script_path [file normalize [info script]]
	set script_folder [file dirname $script_path]
	set old_folder [ pwd ]
	cd $script_folder
	return 1
}



### TODO: Account for Non-Project Batch mode!
### TODO: Allow to set path by parameter
proc check_set_db_prj_path {} {
	global env
	global db_prj_path

	if { [ info exists env(DIVEBITS_PROJECT_PATH) ] } {
		set db_prj_path $env(DIVEBITS_PROJECT_PATH)
	} else {
		set db_prj_path [ get_property DIRECTORY [current_project] ]
		set db_prj_path "${db_prj_path}/divebits"
		set env(DIVEBITS_PROJECT_PATH) $db_prj_path
	}
	
	file mkdir $db_prj_path
	file mkdir "${db_prj_path}/1_extracted_components"
	file mkdir "${db_prj_path}/2_bram_locations"
	file mkdir "${db_prj_path}/3_mmi_files"
	file mkdir "${db_prj_path}/4_data_template"
	file mkdir "${db_prj_path}/5_bitstream_config_files"
	file mkdir "${db_prj_path}/6_bitstreams"
	
	return 1
}


proc make_db_components_yaml_file {} {
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
	set yamltext [read [open $yamlpath r]]
#	puts "" ; puts "" ; puts $yamltext
	
	return 1
}

proc call_python3_script { py_script_name } {

	## save and clear Python path variables, so Python 2.x is out
	if { [ info exists env(PYTHONPATH) ] } {
		set PYTHONPATH_bak $env(PYTHONPATH)
		unset env(PYTHONPATH)
	} else {
		unset PYTHONPATH_bak
	}

	if { [ info exists env(PYTHONHOME) ] } {
		set PYTHONHOME_bak $env(PYTHONHOME)
		unset env(PYTHONHOME)
	} else {
		unset PYTHONHOME_bak
	}
	
	## run script
	exec python3 $py_script_name

	## restore path variables
	if { [ info exists env(PYTHONPATH_bak) ] } {
		set env(PYTHONPATH) $PYTHONPATH_bak
	}

	if { [ info exists env(PYTHONHOME_bak) ] } {
		set env(PYTHONHOME) $PYTHONHOME_bak
	}
	
	return 1

}


#goto_script_path
check_set_db_prj_path
make_db_components_yaml_file

## return to original path
#cd $old_folder
