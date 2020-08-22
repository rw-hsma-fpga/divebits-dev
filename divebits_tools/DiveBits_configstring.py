import os
import yaml
import json

from datetime import datetime
from bitstring import BitArray

from DiveBits_base import db_bitwidths


class DiveBits_configstring:

    configbits: BitArray
    config_data: dict
    config_file: str
    config_name: str
    components: list
    block_configs: list

    def __init__(self, config_file: str, components: list):

        self.configbits = BitArray(0)
        self.config_file = os.path.basename(config_file)
        self.components = components
        self.config_name = os.path.basename(config_file[:-5])

        # open configuration file based on template
        if config_file[-4:].lower() == "yaml":
            self.config_data = yaml.safe_load(open(config_file))
        if config_file[-4:].lower() == "json":
            self.config_data = json.load(open(config_file))

        self.block_configs = self.config_data['db_components']

    def generate_configstring(self):

        # iterate of blocks
        for comp in self.components:
            self.configbits.prepend(comp.generate_config_bitstring(self.block_configs))

        # insert length into lower end of bitstring
        self.configbits.append(BitArray(uint=self.configbits.length, length=db_bitwidths["CONFIG_LENGTH"]))

    def add_crc32(self):

        # 1 + x + x2 + x4 + x5 +x7 + x8 + x10 + x11 + x12 + x16 + x22 + x23 + x26 + x32.
        polynomial = BitArray(bin='1110 1101 1011 1000 1000 0011 0010 0000 1')

        # enter corrected length with CRC32 packet
        current_length = self.configbits.length
        len_w_crc32 = current_length + db_bitwidths["ADDRESS"] + db_bitwidths["CHANNEL"] + db_bitwidths["LENGTH"] + 32
        self.configbits.overwrite(BitArray(uint=len_w_crc32, length=db_bitwidths["CONFIG_LENGTH"]),
                                -db_bitwidths["CONFIG_LENGTH"])

        # attach DB_ADDRESS 0, Channel 0 for CRC32 receiver, length 32 of checksum
        self.configbits.prepend(BitArray(uint=0, length=db_bitwidths["ADDRESS"]+db_bitwidths["CHANNEL"]))
        self.configbits.prepend(BitArray(uint=32, length=db_bitwidths["LENGTH"]))

        # actual CRC32 calculation
        divstring = self.configbits[:-db_bitwidths["CONFIG_LENGTH"]] # without config length (doesn't leave db_config)
        divstring.prepend(BitArray(32))  # prepend empty CRC32
        divstring.append(BitArray(1))  # attach a 0 to make indexing from LSB side easier
        for j in range(1, divstring.length-32):
            if divstring[-(j+1)] == 1:
                divstring[-(j+33):-j] ^= polynomial
        remainder = divstring[0:32]

        self.configbits.prepend(remainder)

    def write_memfile(self, mem_files_path: str):

        # extend bitstring to multiple of 8
        if (self.configbits.length % 8) != 0:
            missing_bits = 8 - (self.configbits.length % 8)
            self.configbits.prepend(BitArray(missing_bits))

        # generate mem output file
        memfile = open(mem_files_path + self.config_name + ".mem", "w")
        memfile.write("// \n")
        memfile.write("// " + self.config_name + ".mem\n")
        memfile.write("// generated " + datetime.now().strftime("%b %d, %Y - %H:%M:%S") + "\n")
        memfile.write("// from DiveBits configuration data in " + self.config_file + "\n")
        memfile.write("// required to make bitstream " + self.config_name + ".bit\n")
        memfile.write("// \n")
        memfile.write("@0000\n")

        xpos = 0
        while self.configbits.length > 0:
            memfile.write(self.configbits[-8:].hex.upper() + " ")
            del self.configbits[-8:]
            xpos = (xpos + 1) % 16
            if xpos == 0:
                memfile.write("\n")
        memfile.write("\n")
        memfile.close()
        # configbits is empty after this!

    # STATIC METHODS
    @staticmethod
    def calculate_configlength(components: list, crc: bool, bram_tcl_file: str):

        bitcount = db_bitwidths["CONFIG_LENGTH"]
        for comp in components:
            bitcount += comp.num_configbits()

        if crc:
            bitcount += (db_bitwidths["ADDRESS"] + db_bitwidths["CHANNEL"] + db_bitwidths["LENGTH"] + 32)

        bram32cnt = bitcount // 32768  # integer division (floor)
        if (bitcount % 32768) != 0:
            bram32cnt += 1  # ceiling

        print("DiveBits component extraction:")
        print("  Complete number of DB config bits:", bitcount)
        print("  Number of RAMB36 required:", bram32cnt)

        # Generate Tcl command to set required number of BRAMs
        tcl_file = open(bram_tcl_file, 'w')
        tcl_file.write("global REQUIRED_BRAMS\n")
        tcl_file.write("set REQUIRED_BRAMS " + str(bram32cnt) + "\n")
        tcl_file.close()
