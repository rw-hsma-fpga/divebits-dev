call C:\Xilinx\SDK\2019.1\settings64.bat

updatemem -force -meminfo DiveBits_16Kb.mmi -bit  C:\user\WIB\DiveBits2\XPR\XPR.runs\impl_1/demo_block_wrapper.bit -data dbdata.mem -proc divebits/config -out download.bit

timeout 15
