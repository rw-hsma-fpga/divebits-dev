open_hw_manager

connect_hw_server -allow_non_jtag

open_hw_target

set_property PROGRAM.FILE {./download.bit} [get_hw_devices xc7z020_1]

program_hw_devices [get_hw_devices xc7z020_1]

close_hw_target

close_hw_manager

exit
