import sys
from bitstring import BitArray
import yaml

DB_CONFIG_LENGTH_BITWIDTH = 20
DB_ADDRESS_BITWIDTH = 12
DB_CHANNEL_BITWIDTH = 4
DB_LENGTH_BITWIDTH = 16

TYPE_DIVEBITS_CONSTANT = 1001


class DiveBits:

    @staticmethod
    def num_configbits(component) -> int:
        bitcount = 0
        if "DB_TYPE" not in component:
            raise SyntaxError('No DB_TYPE in component')
        else:
            db_type = component["DB_TYPE"]

            # TODO seek best equivalent of case structure
            if db_type == TYPE_DIVEBITS_CONSTANT:
                if "DB_VECTOR_WIDTH" not in component:
                    raise SyntaxError('DB_VECTOR_WIDTH parameter missing')
                else:
                    db_vector_width = component["DB_VECTOR_WIDTH"]
                    if db_vector_width != 0:
                        bitcount += DB_ADDRESS_BITWIDTH
                        bitcount += DB_CHANNEL_BITWIDTH
                        bitcount += DB_LENGTH_BITWIDTH
                        bitcount += db_vector_width
                        return bitcount
                    else:
                        raise SyntaxError('DB_VECTOR_WIDTH is 0')
            # TODO... elseif other types...
            #
            else:
                raise SyntaxError('DB_TYPE unknown')

    @staticmethod
    def generate_component_template(component) -> dict:
        temp_comp: dict = {"PATH": "", "READONLY": {}, "CONFIGURABLE": {}}

        # TODO maybe check existence of all required values
        if "DB_TYPE" not in component:
            raise SyntaxError('No DB_TYPE in component')
        else:
            temp_comp["PATH"] = component["PATH"]
            db_type = component["DB_TYPE"]
            temp_comp["READONLY"]["DB_TYPE"] = db_type

            # TODO seek best equivalent of case structure
            if db_type == TYPE_DIVEBITS_CONSTANT:
                if "DB_VECTOR_WIDTH" not in component:
                    raise SyntaxError('DB_VECTOR_WIDTH parameter missing')
                else:
                    temp_comp["READONLY"]["DB_VECTOR_WIDTH"] = component["DB_VECTOR_WIDTH"]
                    # TODO maybe error checking size of default value?
                    temp_comp["CONFIGURABLE"]["VALUE"] = component["DB_DEFAULT_VALUE"]

            # TODO ... elseif other types...
            #
            else:
                raise SyntaxError('DB_TYPE unknown')

        return temp_comp

    @staticmethod
    def generate_config_bitstring(component, address) -> BitArray:
        # TODO db_type should not come from config yaml either, but from extracted or template yaml
        db_type = component["READONLY"]["DB_TYPE"]
        if db_type == TYPE_DIVEBITS_CONSTANT:
            # TODO should DB_VECTOR_WIDTH come from config.yaml? Instance-specific but unprotected read-only
            db_vector_width = component["READONLY"]["DB_VECTOR_WIDTH"]
            value = component["CONFIGURABLE"]["VALUE"]
            configbits = BitArray(uint=0, length=DB_CHANNEL_BITWIDTH)
            configbits.prepend(BitArray(uint=address, length=DB_ADDRESS_BITWIDTH))
            configbits.prepend(BitArray(uint=db_vector_width, length=DB_LENGTH_BITWIDTH))
            configbits.prepend(BitArray(uint=value, length=db_vector_width))

        # TODO ... elseif other types...
        #
        else:
            raise SyntaxError('DB_TYPE unknown')

        # TODO remove
        return configbits
