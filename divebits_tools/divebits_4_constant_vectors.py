import DiveBits_base
from bitstring import BitArray


class divebits_4_constant_vectors(DiveBits_base.DiveBits_base):

    def num_configbits(self, component) -> int:

        bitcount = super().num_configbits(component)

        db_vector_width = component["DB_VECTOR_WIDTH"]
        if db_vector_width != 0:
            bitcount += (DiveBits_base.DB_ADDRESS_BITWIDTH * 4)
            bitcount += (DiveBits_base.DB_CHANNEL_BITWIDTH * 4)
            bitcount += (DiveBits_base.DB_LENGTH_BITWIDTH * 4)
            bitcount += (db_vector_width * 4)
            return bitcount
        else:
            raise SyntaxError('DB_VECTOR_WIDTH is 0')

    def generate_component_template(self, component) -> dict:

        temp_comp = super().generate_component_template(component)

        temp_comp["READONLY"]["DB_VECTOR_WIDTH"] = component["DB_VECTOR_WIDTH"]
        db_default_value = component["DB_DEFAULT_VALUE_ALL"]
        for i in range(0, 4):
            temp_comp["CONFIGURABLE"]["VALUE_" + f'{i:02d}'] = \
                component["DB_DEFAULT_VALUE_" + f'{i:02d}'] + db_default_value

        return temp_comp

    def generate_config_bitstring(self, config_data, block_data) -> BitArray:

        configbits = super().generate_config_bitstring(config_data, block_data)

        db_vector_width = block_data["DB_VECTOR_WIDTH"]
        for i in range(0, 4):
            value = config_data["CONFIGURABLE"]["VALUE_" + f'{i:02d}']
            configbits.prepend(BitArray(uint=i, length=DiveBits_base.DB_CHANNEL_BITWIDTH))
            configbits.prepend(BitArray(uint=self.db_address, length=DiveBits_base.DB_ADDRESS_BITWIDTH))
            configbits.prepend(BitArray(uint=db_vector_width, length=DiveBits_base.DB_LENGTH_BITWIDTH))
            configbits.prepend(BitArray(uint=value, length=db_vector_width))

        return configbits

