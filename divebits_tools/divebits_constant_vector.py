import DiveBits_base
from bitstring import BitArray


class divebits_constant_vector(DiveBits_base.DiveBits_base):

    def num_configbits(self, component) -> int:

        bitcount = super().num_configbits(component)

        if "DB_VECTOR_WIDTH" not in component:
            raise SyntaxError('DB_VECTOR_WIDTH parameter missing')
        else:
            db_vector_width = component["DB_VECTOR_WIDTH"]
            if db_vector_width != 0:
                bitcount += DiveBits_base.DB_ADDRESS_BITWIDTH
                bitcount += DiveBits_base.DB_CHANNEL_BITWIDTH
                bitcount += DiveBits_base.DB_LENGTH_BITWIDTH
                bitcount += db_vector_width
                return bitcount
            else:
                raise SyntaxError('DB_VECTOR_WIDTH is 0')

        return bitcount

    def generate_component_template(self, component) -> dict:

        temp_comp = super().generate_component_template(component)

        if "DB_VECTOR_WIDTH" not in component:
            raise SyntaxError('DB_VECTOR_WIDTH parameter missing')
        else:
            temp_comp["READONLY"]["DB_VECTOR_WIDTH"] = component["DB_VECTOR_WIDTH"]
            # TODO maybe error checking size of default value?
            temp_comp["CONFIGURABLE"]["VALUE"] = component["DB_DEFAULT_VALUE"]

        return temp_comp

    def generate_config_bitstring(self, config_data, block_data) -> BitArray:

        configbits = super().generate_config_bitstring(config_data, block_data)

        db_vector_width = block_data["DB_VECTOR_WIDTH"]
        value = config_data["CONFIGURABLE"]["VALUE"]
        configbits.prepend(BitArray(uint=0, length=DiveBits_base.DB_CHANNEL_BITWIDTH))
        configbits.prepend(BitArray(uint=self.db_address, length=DiveBits_base.DB_ADDRESS_BITWIDTH))
        configbits.prepend(BitArray(uint=db_vector_width, length=DiveBits_base.DB_LENGTH_BITWIDTH))
        configbits.prepend(BitArray(uint=value, length=db_vector_width))

        return configbits

