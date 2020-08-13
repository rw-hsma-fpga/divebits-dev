import DiveBits_base
from DiveBits_base import db_bitwidths
from bitstring import BitArray


class divebits_constant_vector(DiveBits_base.DiveBits_base):

    def num_configbits(self) -> int:

        bitcount = super().num_configbits()

        if "DB_VECTOR_WIDTH" not in self.db_component:
            raise SyntaxError('DB_VECTOR_WIDTH parameter missing')
        else:
            db_vector_width = self.db_component["DB_VECTOR_WIDTH"]
            if db_vector_width != 0:
                bitcount += (db_bitwidths["LENGTH"] + db_bitwidths["ADDRESS"] + db_bitwidths["CHANNEL"])
                bitcount += db_vector_width
                return bitcount
            else:
                raise SyntaxError('DB_VECTOR_WIDTH is 0')

    def generate_component_template(self) -> dict:

        temp_comp = super().generate_component_template()

        if "DB_VECTOR_WIDTH" not in self.db_component:
            raise SyntaxError('DB_VECTOR_WIDTH parameter missing')
        else:
            temp_comp["READONLY"]["DB_VECTOR_WIDTH"] = self.db_component["DB_VECTOR_WIDTH"]
            # TODO maybe error checking size of default value?
            temp_comp["CONFIGURABLE"]["VALUE"] = self.db_component["DB_DEFAULT_VALUE"]

        return temp_comp

    def generate_config_bitstring(self, config_list) -> BitArray:

        configbits = BitArray(0)
        if not super().find_block_config(config_list):
            return configbits

        db_vector_width = self.db_component["DB_VECTOR_WIDTH"]
        value = self.block_config["CONFIGURABLE"]["VALUE"]
        configbits.prepend(BitArray(uint=0, length=db_bitwidths["CHANNEL"]))
        configbits.prepend(BitArray(uint=self.db_address, length=db_bitwidths["ADDRESS"]))
        configbits.prepend(BitArray(uint=db_vector_width, length=db_bitwidths["LENGTH"]))
        configbits.prepend(BitArray(uint=value, length=db_vector_width))

        return configbits

