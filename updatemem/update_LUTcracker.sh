#!/bin/bash

echo
date
echo

## set Xilinx environment
. ~/Xilinx/Vivado/2020.1/settings64.sh


BITSTREAM_IN="/home/willenbe/Projekte/DB_PROJECT_2020.1a/DB_PROJECT_2020.1a.runs/impl_1/demo_block_wrapper.bit"

updatemem -force -meminfo divebits_32kb.mmi -bit $BITSTREAM_IN -data dbdata.mem -proc divebits/config -out download.bit

echo
date
echo
