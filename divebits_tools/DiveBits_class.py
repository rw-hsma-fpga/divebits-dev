from bitstring import BitArray
import math

class HexInt(int):  # subtype definition to allow Hex YAML output
    pass


DB_CONFIG_LENGTH_BITWIDTH = 20
DB_ADDRESS_BITWIDTH = 12
DB_CHANNEL_BITWIDTH = 4
DB_LENGTH_BITWIDTH = 16


TYPE_DIVEBITS_CONSTANT = 1001
TYPE_DIVEBITS_4_CONSTANTS = 1003
TYPE_DIVEBITS_16_CONSTANTS = 1005

TYPE_DIVEBITS_AXI_4_CONSTANT_REGS = 2002
TYPE_DIVEBITS_AXI4_MASTER_RDWR = 2010
TYPE_DIVEBITS_AXI4_MASTER_WRONLY = 2011
TYPE_DIVEBITS_AXI4S_MASTER = 2020

TYPE_DIVEBITS_BLOCKRAM_INIT = 3000


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

            elif db_type == TYPE_DIVEBITS_4_CONSTANTS:
                # TODO add all parameter sanity checks
                db_vector_width = component["DB_VECTOR_WIDTH"]
                if db_vector_width != 0:
                    bitcount += (DB_ADDRESS_BITWIDTH * 4)
                    bitcount += (DB_CHANNEL_BITWIDTH * 4)
                    bitcount += (DB_LENGTH_BITWIDTH * 4)
                    bitcount += (db_vector_width * 4)
                    return bitcount
                else:
                    raise SyntaxError('DB_VECTOR_WIDTH is 0')

            elif db_type == TYPE_DIVEBITS_AXI_4_CONSTANT_REGS:
                # TODO add all parameter sanity checks
                db_register_width = 32
                bitcount += (DB_ADDRESS_BITWIDTH * 4)
                bitcount += (DB_CHANNEL_BITWIDTH * 4)
                bitcount += (DB_LENGTH_BITWIDTH * 4)
                bitcount += (db_register_width * 4)
                return bitcount

            elif db_type == TYPE_DIVEBITS_BLOCKRAM_INIT:
                db_bram_addr_width = component["DB_BRAM_ADDR_WIDTH"]
                db_bram_data_width = component["DB_BRAM_DATA_WIDTH"]
                bitcount += DB_ADDRESS_BITWIDTH
                bitcount += DB_CHANNEL_BITWIDTH
                bitcount += (db_bram_data_width * pow(2, db_bram_addr_width))
                return bitcount

            elif db_type == TYPE_DIVEBITS_AXI4_MASTER_RDWR:
                db_num_codewords = component["DB_NUM_CODE_WORDS"]
                bitcount += DB_ADDRESS_BITWIDTH
                bitcount += DB_CHANNEL_BITWIDTH
                bitcount += (32 * db_num_codewords)
                return bitcount

            elif db_type == TYPE_DIVEBITS_AXI4_MASTER_WRONLY:
                db_num_codewords = component["DB_NUM_CODE_WORDS"]
                bitcount += DB_ADDRESS_BITWIDTH
                bitcount += DB_CHANNEL_BITWIDTH
                bitcount += (32 * db_num_codewords)
                return bitcount

            elif db_type == TYPE_DIVEBITS_AXI4S_MASTER:
                db_num_datawords = component["DB_NUM_DATA_WORDS"]
                db_data_width = component["DB_DATA_WIDTH"]
                code_addr_width = math.ceil(math.log2(db_num_datawords))
                bitcount += DB_ADDRESS_BITWIDTH
                bitcount += DB_CHANNEL_BITWIDTH
                bitcount += (db_num_datawords * (db_data_width+1))
                bitcount += (code_addr_width+1)
                return bitcount

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

            elif db_type == TYPE_DIVEBITS_4_CONSTANTS:
                # TODO add all parameter sanity checks
                temp_comp["READONLY"]["DB_VECTOR_WIDTH"] = component["DB_VECTOR_WIDTH"]
                # TODO maybe error checking size of default values?
                db_default_value = component["DB_DEFAULT_VALUE_ALL"]
                for i in range (0, 4):
                    temp_comp["CONFIGURABLE"]["VALUE_" + f'{i:02d}'] = \
                        component["DB_DEFAULT_VALUE_" + f'{i:02d}'] + db_default_value

            elif db_type == TYPE_DIVEBITS_AXI_4_CONSTANT_REGS:
                # TODO maybe error checking size of default values?
                db_default_value = component["DB_DEFAULT_VALUE"]
                for i in range (0, 4):
                    temp_comp["CONFIGURABLE"]["REGISTER_" + f'{i:02d}' + "_VALUE"] = db_default_value

            elif db_type == TYPE_DIVEBITS_BLOCKRAM_INIT:
                temp_comp["READONLY"]["DB_BRAM_ADDR_WIDTH"] = component["DB_BRAM_ADDR_WIDTH"]
                temp_comp["READONLY"]["DB_BRAM_DATA_WIDTH"] = component["DB_BRAM_DATA_WIDTH"]
                temp_comp["CONFIGURABLE"]["default"] = 0

            elif db_type == TYPE_DIVEBITS_AXI4_MASTER_RDWR:
                temp_comp["READONLY"]["DB_NUM_CODE_WORDS"] = component["DB_NUM_CODE_WORDS"]
                code: dict = {}

                n = 0
                codeword: dict = {"OPCODE": "SET_BASE_ADDR",
                                  "ADDR": HexInt(0x40600000)}
                code[n] = codeword.copy()
                n += 1
                codeword: dict = {"OPCODE": "WRITE_FROM_CODE",
                                  "ADDR": 4,
                                  "DATA": 0x41}
                code[n] = codeword.copy()
                n += 1
                codeword: dict = {"OPCODE": "READ_TO_BUFFER",
                                  "ADDR": 0}
                code[n] = codeword.copy()
                n += 1
                codeword: dict = {"OPCODE": "WRITE_FROM_BUFFER",
                                  "ADDR": 4}
                code[n] = codeword.copy();
                n += 1
                codeword: dict = {"OPCODE": "READ_CHECK_WAIT",
                                  "ADDR": 8,
                                  "CHECK_MASK": 0x0,
                                  "CHECK_DATA": 0x42}
                code[n] = codeword.copy()
                n += 1
                temp_comp["CONFIGURABLE"]["OPCODE_COUNT"] = n
                temp_comp["CONFIGURABLE"]["CODE"] = code

            elif db_type == TYPE_DIVEBITS_AXI4_MASTER_WRONLY:
                temp_comp["READONLY"]["DB_NUM_CODE_WORDS"] = component["DB_NUM_CODE_WORDS"]
                code: dict = {}

                n = 0
                codeword: dict = {"OPCODE": "SET_BASE_ADDR",
                                  "ADDR": HexInt(0x40600000)}
                code[n] = codeword.copy()
                n += 1
                codeword: dict = {"OPCODE": "WRITE_FROM_CODE",
                                  "ADDR": 4,
                                  "DATA": 0x41}
                code[n] = codeword.copy()
                n += 1
                codeword: dict = {"OPCODE": "WRITE_FROM_BUFFER",
                                  "ADDR": 4}
                code[n] = codeword.copy();
                n += 1
                temp_comp["CONFIGURABLE"]["OPCODE_COUNT"] = n
                temp_comp["CONFIGURABLE"]["CODE"] = code

            elif db_type == TYPE_DIVEBITS_AXI4S_MASTER:
                temp_comp["READONLY"]["DB_NUM_DATA_WORDS"] = component["DB_NUM_DATA_WORDS"]
                temp_comp["READONLY"]["DB_DATA_WIDTH"] = component["DB_DATA_WIDTH"]

                words: dict = {}

                n = 0
                dataword: dict = {"TDATA": HexInt(0xDEADBEEF), "TLAST": False }
                words[n] = dataword.copy()
                n += 1
                dataword: dict = {"TDATA": HexInt(0xC0FFEE77), "TLAST": False }
                words[n] = dataword.copy()
                n += 1
                dataword: dict = {"TDATA": HexInt(0xBADC0C0A), "TLAST": True }
                words[n] = dataword.copy()
                n += 1
                temp_comp["CONFIGURABLE"]["WORD_COUNT"] = n
                temp_comp["CONFIGURABLE"]["DATA"] = words

            else:
                raise SyntaxError('DB_TYPE unknown')

        return temp_comp

    @staticmethod
    def generate_config_bitstring(config_data, block_data) -> BitArray:
        # TODO check config blocks against block data availability... really all kinds of integrity checking...

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

        elif db_type == TYPE_DIVEBITS_4_CONSTANTS:
            db_vector_width = block_data["DB_VECTOR_WIDTH"]
            for i in range(0, 4):
                value = config_data["CONFIGURABLE"]["VALUE_" + f'{i:02d}']
                configbits.prepend(BitArray(uint=i, length=DB_CHANNEL_BITWIDTH))
                configbits.prepend(BitArray(uint=db_address, length=DB_ADDRESS_BITWIDTH))
                configbits.prepend(BitArray(uint=db_vector_width, length=DB_LENGTH_BITWIDTH))
                configbits.prepend(BitArray(uint=value, length=db_vector_width))

        elif db_type == TYPE_DIVEBITS_AXI_4_CONSTANT_REGS:
            db_register_width = 32
            for i in range(0, 4):
                value = config_data["CONFIGURABLE"]["REGISTER_" + f'{i:02d}' + "_VALUE"]
                configbits.prepend(BitArray(uint=i, length=DB_CHANNEL_BITWIDTH))
                configbits.prepend(BitArray(uint=db_address, length=DB_ADDRESS_BITWIDTH))
                configbits.prepend(BitArray(uint=db_register_width, length=DB_LENGTH_BITWIDTH))
                configbits.prepend(BitArray(uint=value, length=db_register_width))

        elif db_type == TYPE_DIVEBITS_BLOCKRAM_INIT:
            db_bram_addr_width = block_data["DB_BRAM_ADDR_WIDTH"]
            db_bram_data_width = block_data["DB_BRAM_DATA_WIDTH"]
            bram_num_words = pow(2, db_bram_addr_width)
            bram_data_length = (db_bram_data_width * bram_num_words)

            configbits.prepend(BitArray(uint=0, length=DB_CHANNEL_BITWIDTH))
            configbits.prepend(BitArray(uint=db_address, length=DB_ADDRESS_BITWIDTH))
            configbits.prepend(BitArray(uint=bram_data_length, length=DB_LENGTH_BITWIDTH))

            bram_config_data = config_data["CONFIGURABLE"]
            for addr in range(0, bram_num_words):
                if addr in bram_config_data["words"]:
                    value = bram_config_data["words"][addr]
                else:
                    found_in_range = False
                    for addr_range in bram_config_data["ranges"]:
                        if addr_range["from"] <= addr <= addr_range["to"]:
                            value = addr_range["value"]
                            found_in_range = True
                    if not found_in_range:
                        value = bram_config_data["default_value"]
                configbits.prepend(BitArray(uint=value, length=db_bram_data_width))

        elif db_type == TYPE_DIVEBITS_AXI4_MASTER_WRONLY:
            db_num_codewords = block_data["DB_NUM_CODE_WORDS"]
            configbits.prepend(BitArray(uint=0, length=DB_CHANNEL_BITWIDTH))
            configbits.prepend(BitArray(uint=db_address, length=DB_ADDRESS_BITWIDTH))
            configbits.prepend(BitArray(uint=32*db_num_codewords, length=DB_LENGTH_BITWIDTH))

            opcode_cnt = config_data["CONFIGURABLE"]["OPCODE_COUNT"]
            code = config_data["CONFIGURABLE"]["CODE"]
            wordcount = db_num_codewords
            base_addr: HexInt = 0
            for i in range(0, opcode_cnt):
                op = code[i]
                if op["OPCODE"] == "SET_BASE_ADDR":
                    base_addr = op["ADDR"]
                elif op["OPCODE"] == "WRITE_FROM_CODE":  # TODO check remaining wordcount first
                    wordcount -= 2
                    if wordcount < 1:
                        raise SyntaxError("AXI Master code doesn't fit into", block_data["BLOCK_PATH"])
                    addr: HexInt = base_addr + op["ADDR"] + 0  # adding opcode to addr
                    configbits.prepend(BitArray(uint=addr, length=32))
                    configbits.prepend(BitArray(uint=op["DATA"], length=32))
                elif op["OPCODE"] == "WRITE_FROM_BUFFER":
                    wordcount -= 1
                    if wordcount < 1:
                        raise SyntaxError("AXI Master code doesn't fit into", block_data["BLOCK_PATH"])
                    addr: HexInt = base_addr + op["ADDR"] + 1  # adding opcode to addr
                    configbits.prepend(BitArray(uint=addr, length=32))
            # stuff with zeroes - at least one word needs to remain for stopcode 0x00000000
            print("Remaining words: ",wordcount-1)
            configbits.prepend(BitArray(32*wordcount))

        elif db_type == TYPE_DIVEBITS_AXI4_MASTER_RDWR:
            db_num_codewords = block_data["DB_NUM_CODE_WORDS"]
            configbits.prepend(BitArray(uint=0, length=DB_CHANNEL_BITWIDTH))
            configbits.prepend(BitArray(uint=db_address, length=DB_ADDRESS_BITWIDTH))
            configbits.prepend(BitArray(uint=32*db_num_codewords, length=DB_LENGTH_BITWIDTH))

            opcode_cnt = config_data["CONFIGURABLE"]["OPCODE_COUNT"]
            code = config_data["CONFIGURABLE"]["CODE"]
            wordcount = db_num_codewords
            base_addr: HexInt = 0
            for i in range(0, opcode_cnt):
                op = code[i]
                if op["OPCODE"] == "SET_BASE_ADDR":
                    base_addr = op["ADDR"]
                elif op["OPCODE"] == "WRITE_FROM_CODE":  # TODO check remaining wordcount first
                    wordcount -= 2
                    if wordcount < 1:
                        raise SyntaxError("AXI Master code doesn't fit into", block_data["BLOCK_PATH"])
                    addr: HexInt = base_addr + op["ADDR"] + 0  # adding opcode to addr
                    configbits.prepend(BitArray(uint=addr, length=32))
                    configbits.prepend(BitArray(uint=op["DATA"], length=32))
                elif op["OPCODE"] == "WRITE_FROM_BUFFER":
                    wordcount -= 1
                    if wordcount < 1:
                        raise SyntaxError("AXI Master code doesn't fit into", block_data["BLOCK_PATH"])
                    addr: HexInt = base_addr + op["ADDR"] + 1  # adding opcode to addr
                    configbits.prepend(BitArray(uint=addr, length=32))
                elif op["OPCODE"] == "READ_TO_BUFFER":
                    wordcount -= 1
                    if wordcount < 1:
                        raise SyntaxError("AXI Master code doesn't fit into", block_data["BLOCK_PATH"])
                    addr: HexInt = base_addr + op["ADDR"] + 2  # adding opcode to addr
                    configbits.prepend(BitArray(uint=addr, length=32))
                elif op["OPCODE"] == "READ_CHECK_WAIT":
                    wordcount -= 3
                    if wordcount < 1:
                        raise SyntaxError("AXI Master code doesn't fit into", block_data["BLOCK_PATH"])
                    addr: HexInt = base_addr + op["ADDR"] + 3  # adding opcode to addr
                    configbits.prepend(BitArray(uint=addr, length=32))
                    configbits.prepend(BitArray(uint=op["CHECK_MASK"], length=32))
                    configbits.prepend(BitArray(uint=op["CHECK_DATA"], length=32))
            # stuff with zeroes - at least one word needs to remain for stopcode 0x00000000
            print("Remaining words: ",wordcount-1)
            configbits.prepend(BitArray(32*wordcount))

        elif db_type == TYPE_DIVEBITS_AXI4S_MASTER:
            db_num_datawords = block_data["DB_NUM_DATA_WORDS"]
            db_data_width = block_data["DB_DATA_WIDTH"]
            code_addr_width = math.ceil(math.log2(db_num_datawords))
            payloadbits = ((db_num_datawords * (db_data_width + 1)) + (code_addr_width + 1))

            configbits.prepend(BitArray(uint=0, length=DB_CHANNEL_BITWIDTH))
            configbits.prepend(BitArray(uint=db_address, length=DB_ADDRESS_BITWIDTH))
            configbits.prepend(BitArray(uint=payloadbits, length=DB_LENGTH_BITWIDTH))

            word_count = config_data["CONFIGURABLE"]["WORD_COUNT"]
            data = config_data["CONFIGURABLE"]["DATA"]

            for i in range(0, word_count):
                configbits.prepend(BitArray(uint=data[i]["TDATA"], length=db_data_width))
                configbits.prepend(BitArray(bool=data[i]["TLAST"]))
            configbits.prepend(BitArray((db_data_width+1) * (db_num_datawords-word_count)))

            configbits.prepend(BitArray(uint=word_count, length=code_addr_width+1))

        else:
            raise SyntaxError('DB_TYPE unknown')

        return configbits
