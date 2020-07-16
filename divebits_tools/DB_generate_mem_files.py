import os
import sys
import glob
from os import path
from bitstring import BitArray
import yaml
from DiveBits_class import DiveBits

DB_CONFIG_LENGTH_BITWIDTH = 20

db_project_path = ""

if __name__ == "__main__":

    if (len(sys.argv) > 1):
        db_project_path = str(sys.argv[1])
    else: # TODO remove below
        db_project_path = "/home/willenbe/Projekte/DB_PROJECT_2020.1a/divebits/"

    excomp_file       = db_project_path + "/1_extracted_components/db_components.yaml"
    template_file     = db_project_path + "/2_config_file_template/db_template.yaml"
    config_files_path = db_project_path + "/3_bitstream_config_files/"
    mem_files_path    = db_project_path + "/6_mem_config_files/"
    bitstreams_out_path    = db_project_path + "/7_output_bitstreams/"

    # Read YAML files
    if (path.exists(excomp_file)):
        excomp_data = yaml.safe_load(open(excomp_file))
    else:
        raise SyntaxError('No file with extracted block diagram components')

    if (path.exists(template_file)):
        template_data = yaml.safe_load(open(template_file))
    else:
        raise SyntaxError('No template file')

    # ADDRESS-PATH matching
    path_addr_dict = {}
    for component in excomp_data['db_components']:
        path_addr_dict[component["PATH"]] = component["DB_ADDRESS"]

    print(path_addr_dict)

    # find config data files
    current_dir = os.getcwd()
    os.chdir(config_files_path)
    config_files = glob.glob("*.yaml", recursive=False)
    os.chdir(current_dir)

    # remove *.yaml
    config_files = [file[:-5] for file in config_files]

    for file in config_files:
        print()
        print(config_files_path+file+".yaml")
        print("  ->", mem_files_path+file+".mem")
        print("    ->", bitstreams_out_path+file+".bit")



    exit()



    bitcount = 0
    db_template_components = []

    for component in excomp_data['db_components']:
        print()
        print(component["NAME"], "is type", component["DB_TYPE"], "and has address", hex(component["DB_ADDRESS"]))
        print(component)

        bitcount += DiveBits.num_configbits(component)
        db_template_components.append(DiveBits.generate_component_template(component))

    bitcount += DB_CONFIG_LENGTH_BITWIDTH
    bram32cnt = bitcount // 32768
    if ((bitcount % 32768) != 0):
        bram32cnt += 1

