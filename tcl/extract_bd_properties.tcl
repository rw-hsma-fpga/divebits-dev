set blocklist [ get_bd_cells -hierarchical ]

#foreach block $blocklist { puts "" ; puts $block ; puts "" ; report_property $block }

foreach block $blocklist {
#		puts $block ;
		set DB_ADDRESS [ get_property CONFIG.DB_ADDRESS [ get_bd_cells $block ] ]
#		puts $DB_ADDRESS ;
		if { [ string length $DB_ADDRESS ] == 0 } {
			set blocklist [ lsearch -all -inline -not -exact $blocklist $block ]
		};
#		puts "" ;
	}

if { 1 == 1 } {

puts ""
puts ""

foreach block $blocklist {
		puts $block ;
		set PROPLIST [ list_property  $block ]
		puts "" ;
		set PROPLIST [ lsearch -all -inline -glob $PROPLIST "CONFIG.DB*" ]
		foreach prop $PROPLIST {
				set propval [ get_property $prop [ get_bd_cells $block ] ]
				puts "$prop $propval" 
			}
		#puts $PROPLIST ;
		puts "" ;

#		set CONFIGS [ get_property $block ]
#		set CONFIGS [ lsearch -all -inline -glob $CONFIGS "CONFIG.DB*" ]
#		puts $CONFIGS ;
#		puts "" ;
	}
}
