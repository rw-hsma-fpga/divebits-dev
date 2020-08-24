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

catch {
	close_project
	file delete -force -- "./.Xil"
	file delete -force -- "./divebits_demo_prj"
	file delete -force -- "./bd/db_demo_block"
	file delete -force -- "./elf_prebuilt/bram_locs.mmi"
	file delete -force -- "./elf_prebuilt/download.bit"
	file delete -force {*}[glob *.jou]
	file delete -force {*}[glob *.log]
}
cd $old_folder
