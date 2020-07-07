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

	global config_ram16k
	global project_device

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

	set project_device [ get_parts -of_objects [get_projects] ]

	
	
	foreach ram $ramlist { puts $ram }
	foreach loc $loclist { puts $loc }
#	foreach loc $loclist_stripped { puts $loc }
	
	return $loclist_stripped
}

proc generate_mmi_file { filepath loclist device } {

	global config_ram16k
	global project_device
	
	set bram_count [llength $loclist]

	if { $config_ram16k } {
		set mem_top 2047
		set ram_type "RAMB18"
		set block_words 512
	} else {
		set mem_top [ expr (4096*$bram_count)-1 ]
		set ram_type "RAMB36"
		set block_words 1024
	}
	puts $mem_top

	set mmifile [open $filepath w]
	puts $mmifile "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
	puts $mmifile ""
	puts $mmifile "<MemInfo Version=\"1\" Minor=\"6\">"
	puts $mmifile ""
	puts $mmifile "	<Processor Endianness=\"Little\" InstPath=\"divebits/config\">"
	
	
	puts $mmifile "		<AddressSpace Name=\"divebits.config\" Begin=\"0\" End=\"${mem_top}\">"
	puts $mmifile ""
	
	set first_word 0
	
	for { set i 0 } { $i < $bram_count } { incr i } {
		set loc [ lindex $loclist $i ]
		set last_word [ expr $first_word+$block_words-1 ]
	
		puts $mmifile "			<BusBlock>"
		puts $mmifile "				<BitLane MemType=\"${ram_type}\" Placement=\"${loc}\">"
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


## TODO make sure implementation is open
check_set_db_prj_path
set ram_locs [ extract_brams ]
foreach loc $ram_locs { puts $loc }
puts "config_ram16k = $config_ram16k"
puts "Part: $project_device"
generate_mmi_file "${env(DIVEBITS_PROJECT_PATH)}/3_mmi_files/db_config_rams.mmi" $ram_locs $project_device

