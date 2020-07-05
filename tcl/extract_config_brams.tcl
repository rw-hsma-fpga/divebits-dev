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


### TODO lots of crap
proc extract_brams {} {

	# get all BRAMs
	set bmemlist [ get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ BMEM.*.* } ]
	
	# get our 16kb BRAM if there is one
	set ramlist [ lsearch -all -inline $bmemlist *divebits_rom16k_gen_magic1701* ]
	if {  [ llength $ramlist ] != 0 } {
		set config_ram16k 1
	} else { 
		set config_ram16k 0
		# get 32kb BRAMs
		set ramlist [ lsearch -all -inline $bmemlist *divebits_rom32k_gen_magic1701* ]
		if {  [ llength $ramlist ] == 0 } {
			puts "ERROR: No DiveBits config BRAMs found";
			return 0
		}
		set ramlist [ lsort $ramlist ]
	}
	
	set loclist []
	set loclist_stripped []

	foreach ram $ramlist { lappend loclist [ get_property LOC $ram ] }
	foreach loc $loclist { lappend loclist_stripped [ string range $loc 7 [ string length $loc ]-1 ] }

	set PART [ get_parts -of_objects [get_projects] ]

	
	
	foreach ram $ramlist { puts $ram }
	foreach loc $loclist { puts $loc }
	foreach loc $loclist_stripped { puts $loc }
	puts "config_ram16k = $config_ram16k"
	puts "Part: $PART"

	
	
}

## TODO make sure implementation is open
check_set_db_prj_path
extract_brams

