from bitstring import BitArray
import importlib


class HexInt(int):  # subtype definition to allow Hex YAML output
    pass


db_bitwidths = {
    "CONFIG_LENGTH": 20,
    "ADDRESS": 12,
    "CHANNEL": 4,
    "LENGTH": 16
}


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

    db_component: dict  # dictionary of YAML block parameters extracted by tcl
    db_address: int
    db_type: int
    block_path: str
    block_config: dict

    def __init__(self, comp: dict):
        self.db_component = comp
        self.db_type = self.db_component["DB_TYPE"]

        if "DB_ADDRESS" not in self.db_component:
            raise KeyError('DiveBits ERROR: No DB_ADDRESS in component data')
        else:
            self.db_address = self.db_component["DB_ADDRESS"]

        if "BLOCK_PATH" not in self.db_component:
            raise KeyError('DiveBits ERROR: No BLOCK_PATH in component data')
        else:
            self.block_path = self.db_component["BLOCK_PATH"]

    # common base function
    def num_configbits(self) -> int:

        bitcount = 0
        return bitcount

    # common base function
    def generate_component_template(self) -> dict:

        temp_comp: dict = {"BLOCK_PATH": self.block_path,
                           "READONLY": {"DB_TYPE": self.db_type},
                           "CONFIGURABLE": {}
                           }

        return temp_comp

    # common base function
    def find_block_config(self, config_list) -> bool:

        for block in config_list:
            if "BLOCK_PATH" not in block:
                raise KeyError('DiveBits ERROR: No BLOCK_PATH in component data')
            if block["BLOCK_PATH"] == self.block_path:
                self.block_config = block
                return True

        return False

    def generate_config_bitstring(self, config_list) -> BitArray:

        configbits = BitArray(0)

        return configbits

    # STATIC METHODS
    @staticmethod
    def DiveBits_factory(component: dict):  # return correct subclass

        if "DB_TYPE" not in component:
            raise KeyError('DiveBits ERROR: No DB_TYPE in component data')

        db_type = component["DB_TYPE"]
        if db_type not in db_types:
            raise SyntaxError('DiveBits ERROR: Unknown DB_TYPE')

        classname = db_types[db_type]
        classtype = getattr(importlib.import_module(classname), classname)
        inst = classtype(component)  # constructor of DiveBits subclass

        return inst

