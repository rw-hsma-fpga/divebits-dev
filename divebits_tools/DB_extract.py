import sys
import os
import argparse

import yaml

from DiveBits_base import DiveBits_base
from DiveBits_configstring import DiveBits_configstring


# BEGIN

if len(sys.argv) != 2:
    raise SyntaxError('Arguments missing')
tcl_args = sys.argv[1]
tcl_args = tcl_args.replace('{', '')
tcl_args = tcl_args.replace('}', '')
tcl_args = tcl_args.split()

# parse command-line arguments
parser = argparse.ArgumentParser(description='Extract DiveBits component data from FPGA design top-level')

parser.add_argument('-x', '--excomp_path',
                    action='store',
                    required=True,
                    dest="excomp_path",
                    help='Path to extracted components YAML directory')

parser.add_argument('-t', '--tmpl_path',
                    action='store',
                    required=True,
                    dest="template_path",
                    help='Path to template data directory')

cl_args = parser.parse_args(tcl_args)
excomp_file = cl_args.excomp_path + "/db_components.yaml"
bram_tcl_file = cl_args.excomp_path + "/set_bram_count.tcl"


if not os.path.exists(excomp_file):
    raise SyntaxError("Extracted components file doesn't exist")

if not os.path.exists(cl_args.template_path):
    raise SyntaxError("Template path doesn't exist")


# read extracted components file
excomp_data = yaml.safe_load(open(excomp_file))

# parse extracted component data to make objects
component_objects = []
for component in excomp_data['db_components']:
    component_objects.append(DiveBits_base.DiveBits_factory(component))


# calculate length of configuration bitstring and number of required BRAMs, write Tcl file to set BRAMs
DiveBits_configstring.calculate_configlength(component_objects,
                                             excomp_data["db_config_block"]["DB_DAISY_CHAIN_CRC_CHECK"],
                                             bram_tcl_file)

# generate template data structure by component
DiveBits_base.DiveBits_generate_templates(component_objects,
                                          excomp_data["Hosttime_ID"],
                                          cl_args.template_path)

