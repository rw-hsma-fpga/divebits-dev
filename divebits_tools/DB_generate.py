import os
import sys
import glob
import yaml
from datetime import datetime
from bitstring import BitArray

from DiveBits_base import db_bitwidths
from DiveBits_base import DiveBits_base


if __name__ == "__main__":

    if len(sys.argv) != 2:
        print(len(sys.argv))
        raise SyntaxError('Wrong number of arguments')
    tcl_args = str(sys.argv[1]).split()
    if len(tcl_args) != 4:
        print(len(tcl_args))
        raise SyntaxError('Wrong number of arguments')

    excomp_path       = tcl_args[0]
    excomp_file       = excomp_path + "/db_components.yaml"
    template_path     = tcl_args[1]
    template_file     = template_path + "/db_template.yaml"
    config_files_path = tcl_args[2]
    mem_files_path    = tcl_args[3]

    if not os.path.exists(excomp_file):
        raise SyntaxError("Extracted components file doesn't exist")

    if not os.path.exists(template_file):
        raise SyntaxError("Template file doesn't exist")

    if not os.path.exists(config_files_path):
        raise SyntaxError("Path for bitstream config files doesn't exist")

    if not os.path.exists(mem_files_path):
        raise SyntaxError("Path for bitstream update *.mem files doesn't exist")

    # Read YAML files
    excomp_data = yaml.safe_load(open(excomp_file))
    block_list: list = excomp_data['db_components']
    template_data = yaml.safe_load(open(template_file))

    # ADDRESS-PATH matching
    path_addr_dict = {}
    for component in excomp_data['db_components']:
        path_addr_dict[component["BLOCK_PATH"]] = component["DB_ADDRESS"]

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
        configbits = BitArray(db_bitwidths["CONFIG_LENGTH"])

        # open configuration file based on template
        config_data = yaml.safe_load(open(config_files_path+file+".yaml"))
        # TODO support JSON load

        # generate all components' config bits and concatenate
        for config_component in config_data['db_components']:
            # get template data with matching BLOCK_PATH
            for i in block_list:
                if i["BLOCK_PATH"] == config_component["BLOCK_PATH"]:
                    block_component: dict = i
                    break
            comp_object = DiveBits_base.DiveBits_factory(block_component)
            configbits.prepend(comp_object.generate_config_bitstring(config_component, block_component))

        # insert length into lower end of bitstring
        configbits.overwrite(BitArray(uint=configbits.length, length=db_bitwidths["CONFIG_LENGTH"]),
                             -db_bitwidths["CONFIG_LENGTH"])

        if excomp_data["db_config_block"]["DB_DAISY_CHAIN_CRC_CHECK"]:
            print("CRC check activated")
            configbits = DiveBits_base.attach_crc32(configbits)

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
        while configbits.length > 0:
            memfile.write(configbits[-8:].hex.upper() + " ")
            del configbits[-8:]
            xpos = (xpos + 1) % 16
            if xpos == 0:
                memfile.write("\n")
        memfile.write("\n")
        memfile.close()
