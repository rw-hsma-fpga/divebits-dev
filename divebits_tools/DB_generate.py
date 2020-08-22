import os
import sys
import argparse
import glob
import yaml

from DiveBits_base import DiveBits_base
from DiveBits_configstring import DiveBits_configstring


# BEGIN

if len(sys.argv) != 2:
    raise SyntaxError('Arguments missing')
tcl_args = sys.argv[1]
# remove weird tcl argument packaging
tcl_args = tcl_args.replace('{', '')
tcl_args = tcl_args.replace('}', '')
# split tcl arg string into single args
tcl_args = tcl_args.split()

# parse command-line arguments
parser = argparse.ArgumentParser(description='Generate configuration bitstrings and corresponding MEM files')

parser.add_argument('-x', '--excomp_path', action='store', required=True,
                    dest="excomp_path", help='Path to extracted components YAML directory')

parser.add_argument('-c', '--config_path', action='store', required=True,
                    dest="config_files_path", help='Path to config files directory')

parser.add_argument('-m', '--mem_path', action='store', required=True,
                    dest="mem_files_path", help='Path to MEM files directory')

cl_args = parser.parse_args(tcl_args)

# make file paths
excomp_file = cl_args.excomp_path + "/db_components.yaml"
config_files_path = cl_args.config_files_path
mem_files_path = cl_args.mem_files_path

# check path existence
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
config_files = glob.glob(config_files_path+"/*.yaml", recursive=False)
config_files += glob.glob(config_files_path+"/*.json", recursive=False)
os.chdir(current_dir)

# produce configstring objects and generate MEM files for each config data file
for file in config_files:

    configstring = DiveBits_configstring(file, component_objects)
    configstring.generate_configstring()

    if excomp_data["db_config_block"]["DB_DAISY_CHAIN_CRC_CHECK"]:
        configstring.add_crc32()

    configstring.write_memfile(mem_files_path)
