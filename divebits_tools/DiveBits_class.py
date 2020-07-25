from bitstring import BitArray

DB_CONFIG_LENGTH_BITWIDTH = 20
DB_ADDRESS_BITWIDTH = 12
DB_CHANNEL_BITWIDTH = 4
DB_LENGTH_BITWIDTH = 16

TYPE_DIVEBITS_CONSTANT = 1001
TYPE_DIVEBITS_16_CONSTANTS = 1005


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

            elif db_type == TYPE_DIVEBITS_16_CONSTANTS:
                # TODO add all parameter sanity checks
                db_vector_width = component["DB_VECTOR_WIDTH"]
                if db_vector_width != 0:
                    bitcount += (DB_ADDRESS_BITWIDTH * 16)
                    bitcount += (DB_CHANNEL_BITWIDTH * 16)
                    bitcount += (DB_LENGTH_BITWIDTH * 16)
                    bitcount += (db_vector_width * 16)
                    return bitcount
                else:
                    raise SyntaxError('DB_VECTOR_WIDTH is 0')

            else:
                raise SyntaxError('DB_TYPE unknown')

    @staticmethod
    def generate_component_template(component) -> dict:

        temp_comp: dict = {"BLOCK_PATH": "", "READONLY": {}, "CONFIGURABLE": {}}

        # TODO maybe check existence of all required values
        if "DB_TYPE" not in component:
            raise SyntaxError('No DB_TYPE in component')
        else:
            temp_comp["BLOCK_PATH"] = component["BLOCK_PATH"]
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

            elif db_type == TYPE_DIVEBITS_16_CONSTANTS:
                # TODO add all parameter sanity checks
                temp_comp["READONLY"]["DB_VECTOR_WIDTH"] = component["DB_VECTOR_WIDTH"]
                # TODO maybe error checking size of default values?
                db_default_value = component["DB_DEFAULT_VALUE_ALL"]
                for i in range (0, 16):
                    temp_comp["CONFIGURABLE"]["VALUE_" + f'{i:02d}'] = \
                        component["DB_DEFAULT_VALUE_" + f'{i:02d}'] + db_default_value

            else:
                raise SyntaxError('DB_TYPE unknown')

        return temp_comp

    @staticmethod
    def generate_config_bitstring(config_data, block_data) -> BitArray:

        configbits = BitArray(0)
        db_address = block_data["DB_ADDRESS"]
        db_type = block_data["DB_TYPE"]

        if db_type == TYPE_DIVEBITS_CONSTANT:
            db_vector_width = block_data["DB_VECTOR_WIDTH"]
            value = config_data["CONFIGURABLE"]["VALUE"]
            configbits.prepend(BitArray(uint=0, length=DB_CHANNEL_BITWIDTH))
            configbits.prepend(BitArray(uint=db_address, length=DB_ADDRESS_BITWIDTH))
            configbits.prepend(BitArray(uint=db_vector_width, length=DB_LENGTH_BITWIDTH))
            configbits.prepend(BitArray(uint=value, length=db_vector_width))

        elif db_type == TYPE_DIVEBITS_16_CONSTANTS:
            db_vector_width = block_data["DB_VECTOR_WIDTH"]
            for i in range(0, 16):
                value = config_data["CONFIGURABLE"]["VALUE_" + f'{i:02d}']
                configbits.prepend(BitArray(uint=i, length=DB_CHANNEL_BITWIDTH))
                configbits.prepend(BitArray(uint=db_address, length=DB_ADDRESS_BITWIDTH))
                configbits.prepend(BitArray(uint=db_vector_width, length=DB_LENGTH_BITWIDTH))
                configbits.prepend(BitArray(uint=value, length=db_vector_width))

        else:
            raise SyntaxError('DB_TYPE unknown')

        # TODO remove
        return configbits
