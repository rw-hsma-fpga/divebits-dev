import sys
import os
import yaml
import json
from DiveBits_class import HexInt
from DiveBits_class import DiveBits
from DiveBits_class import DB_CONFIG_LENGTH_BITWIDTH


def representer(dumper, data):
    return yaml.ScalarNode('tag:yaml.org,2002:int', hex(data))


db_project_path = ""

if __name__ == "__main__":

    yaml.add_representer(HexInt, representer)

    if len(sys.argv) != 2:
        raise SyntaxError('Wrong number of arguments')
    tcl_args = str(sys.argv[1]).split()
    if len(tcl_args) != 2:
        raise SyntaxError('Wrong number of arguments')
    excomp_path = tcl_args[0]
    template_path = tcl_args[1]

    excomp_file = excomp_path + "/db_components.yaml"
    bram_tcl_file = excomp_path + "/set_bram_count.tcl"

    if not os.path.exists(excomp_file):
        raise SyntaxError("Extracted components file doesn't exist")

    if not os.path.exists(template_path):
        raise SyntaxError("Template path doesn't exist")

    template_file = template_path + "/db_template.yaml"
    template_json = template_path + "/db_template.json"

    # read extracted components file
    data = yaml.safe_load(open(excomp_file))

    # parse extracted component data TODO error checks?
    bitcount = DB_CONFIG_LENGTH_BITWIDTH
    db_template_components = []

    for component in data['db_components']:
        # accumulate length of configuration bitstring for storage requirements
        bitcount += DiveBits.num_configbits(component)
        # generate template data structure by component
        db_template_components.append(DiveBits.generate_component_template(component))

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

    # write template file in YAML
    template = open(template_file, 'w')
    yaml.dump({"Hosttime_ID": data["Hosttime_ID"]}, template, sort_keys=False)
    template.write("# READONLY branches can be dropped in bitstream config files;\n")
    template.write("# the corresponding data is matched through the BLOCK_PATH\n")
    yaml.dump({"db_components": db_template_components}, template, sort_keys=False)
    template.close()

    # write template file in JSON - TODO make optional/choice?
    jtemplate = open(template_json, 'w')
    json.dump({"Hosttime_ID": data["Hosttime_ID"]}, jtemplate, sort_keys=False, indent=2, separators=(',\n', ':'))
    jtemplate.write("\n") # TODO check if correct separation
    json.dump({"db_components": db_template_components}, jtemplate, sort_keys=False, indent=2, separators=(',\n', ':'))
    jtemplate.close()
