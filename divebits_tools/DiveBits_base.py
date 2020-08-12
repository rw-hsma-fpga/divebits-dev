from bitstring import BitArray
import math


class HexInt(int):  # subtype definition to allow Hex YAML output
    pass


DB_CONFIG_LENGTH_BITWIDTH = 20
DB_ADDRESS_BITWIDTH = 12
DB_CHANNEL_BITWIDTH = 4
DB_LENGTH_BITWIDTH = 16


TYPE_DIVEBITS_CONSTANT = 1001
TYPE_DIVEBITS_4_CONSTANTS = 1003
TYPE_DIVEBITS_16_CONSTANTS = 1005

TYPE_DIVEBITS_AXI_4_CONSTANT_REGS = 2002
TYPE_DIVEBITS_AXI4_MASTER_RDWR = 2010
TYPE_DIVEBITS_AXI4_MASTER_WRONLY = 2011
TYPE_DIVEBITS_AXI4S_MASTER = 2020

TYPE_DIVEBITS_BLOCKRAM_INIT = 3000

db_types = {
    1001: "divebits_constant_vector",
    1003: "divebits_4_constant_vectors",
    1005: "divebits_16_constant_vectors",

    2002: "divebits_AXI_4_constant_registers",
    2010: "divebits_AXI_Master_ReadWrite",
    2011: "divebits_AXI_Master_WriteOnly",
    2020: "divebits_AXIS_Master",

    3000: "divebits_BlockRAM_init"
}


class DiveBits_base:

    db_address: int
    db_type: int

    def __init__(self):
        pass

    # common base function
    def num_configbits(self, component) -> int:

        bitcount = 0
        if "DB_TYPE" not in component:
            raise SyntaxError('No DB_TYPE in component')
        else:
            self.db_type = component["DB_TYPE"]

        return bitcount

    # common base function
    def generate_component_template(self, component) -> dict:

        temp_comp: dict = {"BLOCK_PATH": "", "READONLY": {}, "CONFIGURABLE": {}}

        # TODO maybe check existence of all required values
        if "DB_TYPE" not in component:
            raise SyntaxError('No DB_TYPE in component')
        else:
            temp_comp["BLOCK_PATH"] = component["BLOCK_PATH"]
            self.db_type = component["DB_TYPE"]
            temp_comp["READONLY"]["DB_TYPE"] = self.db_type

        return temp_comp

    # common base function
    def generate_config_bitstring(self, config_data, block_data) -> BitArray:
        # TODO check config blocks against block data availability... really all kinds of integrity checking...

        configbits = BitArray(0)
        self.db_address = block_data["DB_ADDRESS"]
        self.db_type = block_data["DB_TYPE"]

        return configbits
