import DiveBits_base
from DiveBits_base import db_bitwidths
from bitstring import BitArray


class divebits_AXI_4_constant_registers(DiveBits_base.DiveBits_base):

    def num_configbits(self) -> int:

        bitcount = super().num_configbits()

        db_register_width = 32
        bitcount += (db_bitwidths["LENGTH"] + db_bitwidths["ADDRESS"] + db_bitwidths["CHANNEL"]) * 4
        bitcount += (db_register_width * 4)
        return bitcount

    def generate_component_template(self) -> dict:

        temp_comp = super().generate_component_template()

        db_default_value = self.db_component["DB_DEFAULT_VALUE"]
        for i in range(0, 4):
            temp_comp["CONFIGURABLE"]["REGISTER_" + f'{i:02d}' + "_VALUE"] = db_default_value

        return temp_comp

    def generate_config_bitstring(self, config_list) -> BitArray:

        configbits = BitArray(0)
        if not super().find_block_config(config_list):
            return configbits

        db_register_width = 32
        for i in range(0, 4):
            value = self.block_config["CONFIGURABLE"]["REGISTER_" + f'{i:02d}' + "_VALUE"]
            configbits.prepend(BitArray(uint=i, length=db_bitwidths["CHANNEL"]))
            configbits.prepend(BitArray(uint=self.db_address, length=db_bitwidths["ADDRESS"]))
            configbits.prepend(BitArray(uint=db_register_width, length=db_bitwidths["LENGTH"]))
            configbits.prepend(BitArray(uint=value, length=db_register_width))

        return configbits

