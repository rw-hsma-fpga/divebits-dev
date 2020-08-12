import DiveBits_base
from DiveBits_base import HexInt
from bitstring import BitArray


class divebits_AXI_Master_ReadWrite(DiveBits_base.DiveBits_base):

    def num_configbits(self, component) -> int:

        bitcount = super().num_configbits(component)

        db_num_codewords = component["DB_NUM_CODE_WORDS"]
        bitcount += DiveBits_base.DB_ADDRESS_BITWIDTH
        bitcount += DiveBits_base.DB_CHANNEL_BITWIDTH
        bitcount += (32 * db_num_codewords)

        return bitcount

    def generate_component_template(self, component) -> dict:

        temp_comp = super().generate_component_template(component)

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

        return temp_comp

    def generate_config_bitstring(self, config_data, block_data) -> BitArray:

        configbits = super().generate_config_bitstring(config_data, block_data)

        db_num_codewords = block_data["DB_NUM_CODE_WORDS"]
        configbits.prepend(BitArray(uint=0, length=DiveBits_base.DB_CHANNEL_BITWIDTH))
        configbits.prepend(BitArray(uint=self.db_address, length=DiveBits_base.DB_ADDRESS_BITWIDTH))
        configbits.prepend(BitArray(uint=32 * db_num_codewords, length=DiveBits_base.DB_LENGTH_BITWIDTH))

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
        print("Remaining words: ", wordcount - 1)
        configbits.prepend(BitArray(32 * wordcount))

        return configbits

