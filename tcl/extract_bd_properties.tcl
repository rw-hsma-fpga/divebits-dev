## go to local project path
set script_path [file normalize [info script]]
set script_folder [file dirname $script_path]
set old_folder [ pwd ]
cd $script_folder

## save and clear Python path variables
set PYTHONPATHbak $env(PYTHONPATH)
set PYTHONHOMEbak $env(PYTHONHOME)
unset env(PYTHONPATH)
unset env(PYTHONHOME)


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

	
set yamlfile [open "db_components.yaml" w]

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

	

	
	
	
## Get DB addresses into list
set db_addr_list []
foreach block $blocklist { lappend db_addr_list [ get_property CONFIG.DB_ADDRESS $block ] }

if { [ llength $db_addr_list ] == [ llength $blocklist ] } {

		## output 
		foreach block $blocklist { puts $block }
		foreach addr $db_addr_list { puts $addr }

		##
		
		
		
		
} else {
	puts "ERROR: Incorrect number of Divebits component addresses"
}

# close and check-print YAML file
close $yamlfile
puts [read [open db_components.yaml r]]




#exec python3 test.py

## restore Python path variables
set env(PYTHONPATH) $PYTHONPATHbak 
set env(PYTHONHOME) $PYTHONHOMEbak 

## return to original path
#puts [ pwd ]
cd $old_folder
#puts [ pwd ]
