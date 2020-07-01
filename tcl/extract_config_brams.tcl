#set bmemslist [ get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ BMEM.*.* } ]
#set bmemslist [ lsort $bmemslist ]
#foreach ram $bmemslist { puts $ram }

set bmemlist [ get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ BMEM.*.* } ]
set ram16klist [ lsearch -all -inline $bmemlist *divebits_rom16k_gen_magic1701* ]
set ram32klist [ lsearch -all -inline $bmemlist *divebits_rom32k_gen_magic1701* ]
set ram32klist [ lsort $ram32klist ]
foreach ram16k $ram16klist { puts $ram16k }
foreach ram32k $ram32klist { puts $ram32k }

set loclist []
set loclist_stripped []

foreach ram $ram16klist { lappend loclist [ get_property LOC $ram ] }
foreach loc $loclist { puts $loc }
foreach loc $loclist { lappend loclist_stripped [ string trimleft $loc "BRAM18_" ] }

set loclist []
foreach ram $ram32klist { lappend loclist [ get_property LOC $ram ] }
foreach loc $loclist { puts $loc }
foreach loc $loclist { lappend loclist_stripped [ string trimleft $loc "BRAM36_" ] }
foreach loc $loclist_stripped { puts $loc }


get_parts -of_objects [get_projects]

