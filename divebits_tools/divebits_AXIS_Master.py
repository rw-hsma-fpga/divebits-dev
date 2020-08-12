import DiveBits_base
from DiveBits_base import HexInt
from bitstring import BitArray
import math

class divebits_AXIS_Master(DiveBits_base.DiveBits_base):

    def num_configbits(self, component) -> int:

        bitcount = super().num_configbits(component)

        db_num_datawords = component["DB_NUM_DATA_WORDS"]
        db_data_width = component["DB_DATA_WIDTH"]
        code_addr_width = math.ceil(math.log2(db_num_datawords))
        bitcount += DiveBits_base.DB_ADDRESS_BITWIDTH
        bitcount += DiveBits_base.DB_CHANNEL_BITWIDTH
        bitcount += (db_num_datawords * (db_data_width + 1))
        bitcount += (code_addr_width + 1)

        return bitcount

    def generate_component_template(self, component) -> dict:

        temp_comp = super().generate_component_template(component)

        temp_comp["READONLY"]["DB_NUM_DATA_WORDS"] = component["DB_NUM_DATA_WORDS"]
        temp_comp["READONLY"]["DB_DATA_WIDTH"] = component["DB_DATA_WIDTH"]

        words: dict = {}

        n = 0
        dataword: dict = {"TDATA": HexInt(0xDEADBEEF), "TLAST": False}
        words[n] = dataword.copy()
        n += 1
        dataword: dict = {"TDATA": HexInt(0xC0FFEE77), "TLAST": False}
        words[n] = dataword.copy()
        n += 1
        dataword: dict = {"TDATA": HexInt(0xBADC0C0A), "TLAST": True}
        words[n] = dataword.copy()
        n += 1
        temp_comp["CONFIGURABLE"]["WORD_COUNT"] = n
        temp_comp["CONFIGURABLE"]["DATA"] = words

        return temp_comp

    def generate_config_bitstring(self, config_data, block_data) -> BitArray:

        configbits = super().generate_config_bitstring(config_data, block_data)

        db_num_datawords = block_data["DB_NUM_DATA_WORDS"]
        db_data_width = block_data["DB_DATA_WIDTH"]
        code_addr_width = math.ceil(math.log2(db_num_datawords))
        payloadbits = ((db_num_datawords * (db_data_width + 1)) + (code_addr_width + 1))

        configbits.prepend(BitArray(uint=0, length=DiveBits_base.DB_CHANNEL_BITWIDTH))
        configbits.prepend(BitArray(uint=self.db_address, length=DiveBits_base.DB_ADDRESS_BITWIDTH))
        configbits.prepend(BitArray(uint=payloadbits, length=DiveBits_base.DB_LENGTH_BITWIDTH))

        word_count = config_data["CONFIGURABLE"]["WORD_COUNT"]
        data = config_data["CONFIGURABLE"]["DATA"]

        for i in range(0, word_count):
            configbits.prepend(BitArray(uint=data[i]["TDATA"], length=db_data_width))
            configbits.prepend(BitArray(bool=data[i]["TLAST"]))
        configbits.prepend(BitArray((db_data_width + 1) * (db_num_datawords - word_count)))

        configbits.prepend(BitArray(uint=word_count, length=code_addr_width + 1))

        return configbits

