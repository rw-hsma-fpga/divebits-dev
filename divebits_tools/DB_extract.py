import sys
import os
import argparse

import yaml
import json

from DiveBits_base import HexInt
from DiveBits_base import db_bitwidths
from DiveBits_base import DiveBits_base


def representer(dumper, repdata):
    return yaml.ScalarNode('tag:yaml.org,2002:int', hex(repdata))


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
template_file = cl_args.template_path + "/db_template.yaml"
template_json = cl_args.template_path + "/db_template.json"

if not os.path.exists(excomp_file):
    raise SyntaxError("Extracted components file doesn't exist")

if not os.path.exists(cl_args.template_path):
    raise SyntaxError("Template path doesn't exist")


# read extracted components file
yaml.add_representer(HexInt, representer)
excomp_data = yaml.safe_load(open(excomp_file))

# parse extracted component data to make objects
component_objects = []
for component in excomp_data['db_components']:
    component_objects.append(DiveBits_base.DiveBits_factory(component))

# accumulate length of configuration bitstring for storage requirements
bitcount = db_bitwidths["CONFIG_LENGTH"]
for comp in component_objects:
    bitcount += comp.num_configbits()

if excomp_data["db_config_block"]["DB_DAISY_CHAIN_CRC_CHECK"]:
    bitcount += (db_bitwidths["ADDRESS"] + db_bitwidths["CHANNEL"] + db_bitwidths["LENGTH"] + 32)

bram32cnt = bitcount // 32768
if (bitcount % 32768) != 0:
    bram32cnt += 1

print()
print("Complete number of DB config bits:", bitcount)
print("Number of RAMB36 required:", bram32cnt)

# Generate Tcl command to set required number of BRAMs
tcl_file = open(bram_tcl_file, 'w')
tcl_file.write("global REQUIRED_BRAMS\n")
tcl_file.write("set REQUIRED_BRAMS " + str(bram32cnt) + "\n")
tcl_file.close()

# generate template data structure by component
db_template_components = []
for comp in component_objects:
    db_template_components.append(comp.generate_component_template())

# write template file in YAML
template = open(template_file, 'w')
# TODO integrate Hosttime_ID differently
yaml.dump({"Hosttime_ID": excomp_data["Hosttime_ID"]}, template, sort_keys=False)
template.write("# READONLY branches can be dropped in bitstream config files;\n")
template.write("# the corresponding data is matched through the BLOCK_PATH\n")
yaml.dump({"db_components": db_template_components}, template, sort_keys=False)
template.close()

# write template file in JSON - TODO make optional/choice?
jtemplate = open(template_json, 'w')
# TODO integrate Hosttime_ID differently
# json.dump({"Hosttime_ID": excomp_data["Hosttime_ID"]}, jtemplate, sort_keys=False, indent=2, separators=(',\n', ':'))
# jtemplate.write("\n")  # TODO check if correct separation
json.dump({"db_components": db_template_components}, jtemplate, sort_keys=False, indent=2, separators=(',\n', ':'))
jtemplate.close()
