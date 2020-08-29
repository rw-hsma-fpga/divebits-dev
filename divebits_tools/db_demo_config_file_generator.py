import sys
import os
import argparse

import yaml

from DiveBits_base import DiveBits_base
from DiveBits_configstring import DiveBits_configstring


class HexInt(int):  # subtype definition to allow Hex YAML output
    pass


# BEGIN

if len(sys.argv) != 2:
    raise SyntaxError('Arguments missing')
tcl_args = sys.argv[1]
tcl_args = tcl_args.replace('{', '')
tcl_args = tcl_args.replace('}', '')
tcl_args = tcl_args.split()

# parse command-line arguments
parser = argparse.ArgumentParser(description='An example config file generator')

parser.add_argument('-t', '--tmpl_path', action='store', required=True,
                    dest="template_path", help='Path to template file directory')

parser.add_argument('-c', '--config_path', action='store', required=True,
                    dest="config_files_path", help='Output path for config files')

cl_args = parser.parse_args(tcl_args)

config_files_path = cl_args.config_files_path
# USING THE YAML TEMPLATE. JSON WOULD BE POSSIBLE TOO
template_file_yaml = cl_args.template_path + "/db_template.yaml"

if not os.path.exists(template_file_yaml):
    raise SyntaxError("YAML Template file doesn't exist")

if not os.path.exists(config_files_path):
    raise SyntaxError("Output path for bitstream config files doesn't exist")

#
# generation of example config files for DiveBits demo project
yaml.add_representer(HexInt, lambda dumper, repdata: yaml.ScalarNode('tag:yaml.org,2002:int', hex(repdata)))
for i in range(0, 8):

    template_data = yaml.safe_load(open(template_file_yaml))
    components = template_data['db_components']
    # print(components)

    for component in components:
        component.pop("READONLY", None)
        block_path = component["BLOCK_PATH"]
        configurable = component["CONFIGURABLE"]

        if block_path == "/divebits_AXI_4_constant_registers_0":
            configurable["REGISTER_00_VALUE"] = HexInt(0xDB00000A + i*0x00000100)
            configurable["REGISTER_01_VALUE"] = HexInt(0xDB00000B + i*0x00000100)
            configurable["REGISTER_02_VALUE"] = HexInt(0xDB00000C + i*0x00000100)
            configurable["REGISTER_03_VALUE"] = HexInt(0xDB00000D + i*0x00000100)

        elif block_path == "/divebits_AXI_Master_WriteOnly_0":
            code: dict = {}
            codeword: dict = {}
            opcode_count = 0
            uartlite_addr = 0x40600000
            tx_fifo_offset = 0x4

            codeword = {"OPCODE":"SET_BASE_ADDR", "ADDR":uartlite_addr}
            code[opcode_count] = codeword.copy();
            opcode_count += 1

            to_print: str = "--- Hi from DiveBits AXI Master, Config #0" + str(i) + " ---\r\n"
            for char in to_print:
                codeword = {"OPCODE": "WRITE_FROM_CODE", "ADDR": tx_fifo_offset, "DATA": ord(char)}
                code[opcode_count] = codeword.copy();
                opcode_count += 1

            configurable["OPCODE_COUNT"] = opcode_count
            configurable["CODE"] = code

        elif block_path == "/divebits_BlockRAM_init_0":
            configurable["default_value"] = HexInt(0xDB0000DB)

            words: dict = {}
            for addr in range(0, 8):
                words[addr] = HexInt(0xDB000000 + i*0x00010000 + addr)
            for addr in range(504, 512):
                words[addr] = HexInt(0xDB000000 + i*0x00010000 + addr)
            configurable["words"] = words

            range_1: dict = {"from":   8, "to":  15, "value": HexInt(0xDBDBDBDB)}
            range_2: dict = {"from": 496, "to": 503, "value": HexInt(0xDBDBDBDB)}
            configurable["ranges"] = [range_1, range_2]

        elif block_path == "/divebits_constant_vector_0":
            configurable["VALUE"] = i

        elif block_path == "/divebits_constant_vector_1":
            configurable["VALUE"] = 8+i

        else:  # other blocks, keep template data, or drop to loose configuration?
            components.remove(component)
            pass

    output_file_yaml = config_files_path + "/config_" + str(i) + ".yaml"
    output_file = open(output_file_yaml, 'w')
    yaml.dump(template_data, output_file, sort_keys=False)

    print("DiveBits demo configurations written.")
