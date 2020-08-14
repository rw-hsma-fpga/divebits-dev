import DiveBits_base
from DiveBits_base import db_bitwidths
from DiveBits_base import HexInt
from bitstring import BitArray
import math

class divebits_AXIS_Master(DiveBits_base.DiveBits_base):

    def num_configbits(self) -> int:

        bitcount = super().num_configbits()

        db_num_datawords = self.db_component["DB_NUM_DATA_WORDS"]
        db_data_width = self.db_component["DB_DATA_WIDTH"]
        code_addr_width = math.ceil(math.log2(db_num_datawords))
        bitcount += (db_bitwidths["LENGTH"] + db_bitwidths["ADDRESS"] + db_bitwidths["CHANNEL"])
        bitcount += (db_num_datawords * (db_data_width + 1))
        bitcount += (code_addr_width + 1)

        return bitcount

    def generate_component_template(self) -> dict:

        temp_comp = super().generate_component_template()

        temp_comp["READONLY"]["DB_NUM_DATA_WORDS"] = self.db_component["DB_NUM_DATA_WORDS"]
        temp_comp["READONLY"]["DB_DATA_WIDTH"] = self.db_component["DB_DATA_WIDTH"]

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

    def generate_config_bitstring(self, config_list) -> BitArray:

        configbits = BitArray(0)
        if not super().find_block_config(config_list):
            return configbits

        db_num_datawords = self.db_component["DB_NUM_DATA_WORDS"]
        db_data_width = self.db_component["DB_DATA_WIDTH"]
        code_addr_width = math.ceil(math.log2(db_num_datawords))
        payloadbits = ((db_num_datawords * (db_data_width + 1)) + (code_addr_width + 1))

        configbits.prepend(BitArray(uint=0, length=db_bitwidths["CHANNEL"]))
        configbits.prepend(BitArray(uint=self.db_address, length=db_bitwidths["ADDRESS"]))
        configbits.prepend(BitArray(uint=payloadbits, length=db_bitwidths["LENGTH"]))

        word_count = self.block_config["CONFIGURABLE"]["WORD_COUNT"]
        data = self.block_config["CONFIGURABLE"]["DATA"]

        for j in range(0, word_count):
            # TODO FIXING REQUIRED FOR YAML-JSON COMPATIBILTY
            if j in data:
                i = j
            else:
                i = str(j)

            configbits.prepend(BitArray(uint=data[i]["TDATA"], length=db_data_width))
            configbits.prepend(BitArray(bool=data[i]["TLAST"]))
        configbits.prepend(BitArray((db_data_width + 1) * (db_num_datawords - word_count)))

        configbits.prepend(BitArray(uint=word_count, length=code_addr_width + 1))

        return configbits

