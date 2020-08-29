import DiveBits_base
from DiveBits_base import db_bitwidths
from bitstring import BitArray


class divebits_BlockRAM_init(DiveBits_base.DiveBits_base):

    def num_configbits(self) -> int:

        bitcount = super().num_configbits()

        db_bram_addr_width = self.db_component["DB_BRAM_ADDR_WIDTH"]
        db_bram_data_width = self.db_component["DB_BRAM_DATA_WIDTH"]
        bitcount += (db_bitwidths["LENGTH"] + db_bitwidths["ADDRESS"] + db_bitwidths["CHANNEL"])
        bitcount += (db_bram_data_width * pow(2, db_bram_addr_width))

        return bitcount

    def generate_component_template(self) -> dict:

        temp_comp = super().generate_component_template()

        temp_comp["READONLY"]["DB_BRAM_ADDR_WIDTH"] = self.db_component["DB_BRAM_ADDR_WIDTH"]
        temp_comp["READONLY"]["DB_BRAM_DATA_WIDTH"] = self.db_component["DB_BRAM_DATA_WIDTH"]
        temp_comp["CONFIGURABLE"]["default_value"] = 0

        return temp_comp

    def generate_config_bitstring(self, config_list) -> BitArray:

        configbits = BitArray(0)
        if not super().find_block_config(config_list):
            return configbits

        db_bram_addr_width = self.db_component["DB_BRAM_ADDR_WIDTH"]
        db_bram_data_width = self.db_component["DB_BRAM_DATA_WIDTH"]
        bram_num_words = pow(2, db_bram_addr_width)
        bram_data_length = (db_bram_data_width * bram_num_words)

        configbits.prepend(BitArray(uint=0, length=db_bitwidths["CHANNEL"]))
        configbits.prepend(BitArray(uint=self.db_address, length=db_bitwidths["ADDRESS"]))
        configbits.prepend(BitArray(uint=bram_data_length, length=db_bitwidths["LENGTH"]))

        bram_config_data = self.block_config["CONFIGURABLE"]
        for addr in range(0, bram_num_words):

            # TODO FIXING REQUIRED FOR YAML-JSON COMPATIBILTY
            addr_found = False
            if "words" in bram_config_data:

                if addr in bram_config_data["words"]:
                    value = bram_config_data["words"][addr]
                    addr_found = True

                elif str(addr) in bram_config_data["words"]:
                    value = bram_config_data["words"][str(addr)]
                    addr_found = True

                elif "ranges" in bram_config_data:
                    for addr_range in bram_config_data["ranges"]:
                        if addr_range["from"] <= addr <= addr_range["to"]:
                            value = addr_range["value"]
                            addr_found = True

            if not addr_found:
                value = bram_config_data["default_value"]
            configbits.prepend(BitArray(uint=value, length=db_bram_data_width))

        return configbits
