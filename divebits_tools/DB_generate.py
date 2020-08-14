import os
import sys
import argparse
import glob
import yaml
import json

from datetime import datetime
from bitstring import BitArray

from DiveBits_base import db_bitwidths
from DiveBits_base import DiveBits_base

if __name__ == "__main__":

    if len(sys.argv) != 2:
        raise SyntaxError('Arguments missing')
    tcl_args = sys.argv[1]
    tcl_args = tcl_args.replace('{', '')
    tcl_args = tcl_args.replace('}', '')
    tcl_args = tcl_args.split()

    # parse command-line arguments
    parser = argparse.ArgumentParser(description='Generate configuration bitstrings and corresponding MEM files')

    parser.add_argument('-x', '--excomp_path',
                        action='store',
                        required=True,
                        dest="excomp_path",
                        help='Path to extracted components YAML directory')

    parser.add_argument('-c', '--config_path',
                        action='store',
                        required=True,
                        dest="config_files_path",
                        help='Path to config files directory')

    parser.add_argument('-m', '--mem_path',
                        action='store',
                        required=True,
                        dest="mem_files_path",
                        help='Path to MEM files directory')

    cl_args = parser.parse_args(tcl_args)
    excomp_file = cl_args.excomp_path + "/db_components.yaml"
    config_files_path = cl_args.config_files_path
    mem_files_path = cl_args.mem_files_path

    if not os.path.exists(excomp_file):
        raise SyntaxError("Extracted components file doesn't exist")

    if not os.path.exists(config_files_path):
        raise SyntaxError("Path for bitstream config files doesn't exist")

    if not os.path.exists(mem_files_path):
        raise SyntaxError("Path for bitstream update *.mem files doesn't exist")

    # Read extracted components YAML file, build objects
    excomp_data = yaml.safe_load(open(excomp_file))

    component_objects = []
    for component in excomp_data['db_components']:
        component_objects.append(DiveBits_base.DiveBits_factory(component))

    # find config data files
    current_dir = os.getcwd()
    os.chdir(config_files_path)
    config_files = glob.glob("*.yaml", recursive=False)
    config_files += glob.glob("*.json", recursive=False)
    os.chdir(current_dir)

    for file in config_files:

        # open configuration file based on template
        config_data = {}
        print(file[-4:])
        if file[-4:] == "yaml":
            config_data = yaml.safe_load(open(config_files_path + file))
        if file[-4:] == "json":
            config_data = json.load(open(config_files_path + file))
        config_list = config_data['db_components']

        # generate all components' config bits and concatenate
        configbits = BitArray(0)
        for comp in component_objects:
            configbits.prepend(comp.generate_config_bitstring(config_list))

        # insert length into lower end of bitstring
        configbits.append(BitArray(uint=configbits.length, length=db_bitwidths["CONFIG_LENGTH"]))

        if excomp_data["db_config_block"]["DB_DAISY_CHAIN_CRC_CHECK"]:
            print("CRC check activated")
            configbits = DiveBits_base.attach_crc32(configbits)

        # extend bitstring to multiple of 8
        if (configbits.length % 8) != 0:
            missing_bits = 8 - (configbits.length % 8)
            configbits.prepend(BitArray(missing_bits))

        # generate mem output file
        memfile = open(mem_files_path + file[:-5] + ".mem", "w")
        memfile.write("// \n")
        memfile.write("// " + file[:-5] + ".mem\n")
        memfile.write("// generated " + datetime.now().strftime("%b %d, %Y - %H:%M:%S") + "\n")
        memfile.write("// from DiveBits configuration data in " + file + "\n")
        memfile.write("// required to make bitstream " + file[:-5] + ".bit\n")
        memfile.write("// \n")
        memfile.write("@0000\n")

        xpos = 0
        while configbits.length > 0:
            memfile.write(configbits[-8:].hex.upper() + " ")
            del configbits[-8:]
            xpos = (xpos + 1) % 16
            if xpos == 0:
                memfile.write("\n")
        memfile.write("\n")
        memfile.close()
