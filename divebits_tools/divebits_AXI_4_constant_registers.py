import DiveBits_base
from bitstring import BitArray


class divebits_AXI_4_constant_registers(DiveBits_base.DiveBits_base):

    def num_configbits(self, component) -> int:

        bitcount = super().num_configbits(component)

        db_register_width = 32
        bitcount += (DiveBits_base.DB_ADDRESS_BITWIDTH * 4)
        bitcount += (DiveBits_base.DB_CHANNEL_BITWIDTH * 4)
        bitcount += (DiveBits_base.DB_LENGTH_BITWIDTH * 4)
        bitcount += (db_register_width * 4)
        return bitcount

    def generate_component_template(self, component) -> dict:

        temp_comp = super().generate_component_template(component)

        db_default_value = component["DB_DEFAULT_VALUE"]
        for i in range(0, 4):
            temp_comp["CONFIGURABLE"]["REGISTER_" + f'{i:02d}' + "_VALUE"] = db_default_value

        return temp_comp

    def generate_config_bitstring(self, config_data, block_data) -> BitArray:

        configbits = super().generate_config_bitstring(config_data, block_data)

        db_register_width = 32
        for i in range(0, 4):
            value = config_data["CONFIGURABLE"]["REGISTER_" + f'{i:02d}' + "_VALUE"]
            configbits.prepend(BitArray(uint=i, length=DiveBits_base.DB_CHANNEL_BITWIDTH))
            configbits.prepend(BitArray(uint=self.db_address, length=DiveBits_base.DB_ADDRESS_BITWIDTH))
            configbits.prepend(BitArray(uint=db_register_width, length=DiveBits_base.DB_LENGTH_BITWIDTH))
            configbits.prepend(BitArray(uint=value, length=db_register_width))

        return configbits

