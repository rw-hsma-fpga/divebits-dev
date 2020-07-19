import os
import sys
from datetime import datetime
import glob
from bitstring import BitArray
import yaml
from DiveBits_class import DiveBits

DB_CONFIG_LENGTH_BITWIDTH = 20

db_project_path = ""

if __name__ == "__main__":

    if len(sys.argv) != 2:
        print(len(sys.argv))
        exit()
        raise SyntaxError('Wrong number of arguments')
    tcl_args = str(sys.argv[1]).split()
    if len(tcl_args) != 4:
        print(len(tcl_args))
        exit()
        raise SyntaxError('Wrong number of arguments')

    excomp_path       = tcl_args[0]
    excomp_file       = excomp_path + "/db_components.yaml"
    template_path     = tcl_args[1]
    template_file     = template_path + "/db_template.yaml"
    config_files_path = tcl_args[2]
    mem_files_path    = tcl_args[3]

    if os.path.exists(excomp_file):
        raise SyntaxError("Extracted components file doesn't exist")

    if os.path.exists(template_file):
        raise SyntaxError("Template file doesn't exist")

    if os.path.exists(config_files_path):
        raise SyntaxError("Path for bitstream config files doesn't exist")

    if os.path.exists(mem_files_path):
        raise SyntaxError("Path for bitstream update *.mem files doesn't exist")

    # Read YAML files
    excomp_data = yaml.safe_load(open(excomp_file))
    template_data = yaml.safe_load(open(template_file))

    # ADDRESS-PATH matching
    path_addr_dict = {}
    for component in excomp_data['db_components']:
        path_addr_dict[component["PATH"]] = component["DB_ADDRESS"]

    # find config data files
    current_dir = os.getcwd()
    os.chdir(config_files_path)
    config_files = glob.glob("*.yaml", recursive=False)
    os.chdir(current_dir)

    # remove *.yaml
    config_files = [file[:-5] for file in config_files]

    # TODO lots of error checking between extracted components and these files...
    for file in config_files:

        # start configbits string with 20 reserved bits for complete bitstring length
        configbits = BitArray(DB_CONFIG_LENGTH_BITWIDTH)

        # open configuration file based on template
        config_data = yaml.safe_load(open(config_files_path+file+".yaml"))
        # TODO support JSON load

        # generate all components' config bits and concatenate
        for component in config_data['db_components']:
            db_address = path_addr_dict[component["READONLY"]["PATH"]]
            configbits.prepend(DiveBits.generate_config_bitstring(component, db_address))

        # insert length into lower end of bitstring
        configbits.overwrite(BitArray(uint=configbits.length,length=DB_CONFIG_LENGTH_BITWIDTH),-DB_CONFIG_LENGTH_BITWIDTH)

        # extend bitstring to multiple of 8
        if (configbits.length % 8) != 0:
            missing_bits = 8-(configbits.length % 8)
            configbits.prepend(BitArray(missing_bits))

        # generate mem output file
        memfile = open(mem_files_path+file+".mem", "w")
        memfile.write("// \n")
        memfile.write("// "+file+".mem\n")
        memfile.write("// generated " + datetime.now().strftime("%b %d, %Y - %H:%M:%S") + "\n")
        memfile.write("// from DiveBits configuration data in "+file+".yaml\n")
        memfile.write("// required to make bitstream "+file+".bit\n")
        memfile.write("// \n")
        memfile.write("@0000\n")

        xpos = 0
        while (configbits.length) > 0:
            memfile.write(configbits[-8:].hex.upper() + " ")
            del configbits[-8:]
            xpos = (xpos + 1) % 17
            if xpos == 0:
                memfile.write("\n")
        memfile.write("\n")
        memfile.close()
