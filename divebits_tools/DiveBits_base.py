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

    db_address: int
    db_type: int
    block_path: str

    db_component: dict  # dictionary of YAML block parameters extracted by tcl

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
    def generate_config_bitstring(self, config_data, block_data) -> BitArray:
        # TODO check config blocks against block data availability... really all kinds of integrity checking...

        configbits = BitArray(0)
        self.db_address = block_data["DB_ADDRESS"]
        self.db_type = block_data["DB_TYPE"]

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

    @staticmethod
    def attach_crc32(config_string: BitArray) -> BitArray:

        # 1 + x + x2 + x4 + x5 +x7 + x8 + x10 + x11 + x12 + x16 + x22 + x23 + x26 + x32.
        polynomial = BitArray(bin='1110 1101 1011 1000 1000 0011 0010 0000 1')

        # enter corrected length with CRC32 packet
        current_length = config_string.length
        len_w_crc32 = current_length + db_bitwidths["ADDRESS"] + db_bitwidths["CHANNEL"] + db_bitwidths["LENGTH"] + 32
        config_string.overwrite(BitArray(uint=len_w_crc32, length=db_bitwidths["CONFIG_LENGTH"]),
                                -db_bitwidths["CONFIG_LENGTH"])

        # attach DB_ADDRESS 0, Channel 0 for CRC32 receiver, length 32 of checksum
        config_string.prepend(BitArray(uint=0, length=db_bitwidths["ADDRESS"]+db_bitwidths["CHANNEL"]))
        config_string.prepend(BitArray(uint=32, length=db_bitwidths["LENGTH"]))

        # actual CRC32 calculation
        divstring = config_string[:-db_bitwidths["CONFIG_LENGTH"]] # without config length (doesn't leave db_config)
        divstring.prepend(BitArray(32))  # prepend empty CRC32
        divstring.append(BitArray(1))  # attach a 0 to make indexing from LSB side easier
        for j in range(1, divstring.length-32):
            if divstring[-(j+1)] == 1:
                divstring[-(j+33):-j] ^= polynomial
        remainder = divstring[0:32]

        config_string.prepend(remainder)
        return config_string
