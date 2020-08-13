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

    excomp_path = tcl_args[0]
    excomp_file = excomp_path + "/db_components.yaml"
    # template_path     = tcl_args[1]
    # template_file     = template_path + "/db_template.yaml"
    config_files_path = tcl_args[2]
    mem_files_path = tcl_args[3]

    if not os.path.exists(excomp_file):
        raise SyntaxError("Extracted components file doesn't exist")

    # if not os.path.exists(template_file):
    #   raise SyntaxError("Template file doesn't exist")

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
    os.chdir(current_dir)

    # remove *.yaml
    config_files = [file[:-5] for file in config_files]

    # TODO lots of error checking between extracted components and these files...
    for file in config_files:

        # open configuration file based on template
        config_data = yaml.safe_load(open(config_files_path + file + ".yaml"))
        config_list = config_data['db_components']
        # TODO support JSON load

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
        memfile = open(mem_files_path + file + ".mem", "w")
        memfile.write("// \n")
        memfile.write("// " + file + ".mem\n")
        memfile.write("// generated " + datetime.now().strftime("%b %d, %Y - %H:%M:%S") + "\n")
        memfile.write("// from DiveBits configuration data in " + file + ".yaml\n")
        memfile.write("// required to make bitstream " + file + ".bit\n")
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
