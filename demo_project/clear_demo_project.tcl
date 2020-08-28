namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}

variable script_folder
set script_folder [_tcl::get_script_folder]
set old_folder [ pwd ]

cd $script_folder
file delete -force -- "./.Xil"
file delete -force -- "./divebits_demo_prj"
file delete -force -- "./bd/db_demo_block"
set del_files { "./elf_prebuilt/bram_locs.mmi" "./elf_prebuilt/download.bit"}
lappend del_files [glob -nocomplain *.jou]
lappend del_files [glob -nocomplain *.log]
foreach del_file $del_files {
	file delete $del_file
}
cd $old_folder

catch {
	close_project
	cd $script_folder
	file delete -force -- "./.Xil"
	file delete -force -- "./divebits_demo_prj"
	file delete -force -- "./bd/db_demo_block"
	set del_files { "./elf_prebuilt/bram_locs.mmi" "./elf_prebuilt/download.bit"}
	lappend del_files [glob -nocomplain *.jou]
	lappend del_files [glob -nocomplain *.log]
	foreach del_file $del_files {
		file delete $del_file
	}
	cd $old_folder
}
