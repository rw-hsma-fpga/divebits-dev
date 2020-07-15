import sys
import bitstring
import yaml

DB_ADDRESS_BITWIDTH = 12
DB_CHANNEL_BITWIDTH = 4
DB_LENGTH_BITWIDTH = 16

TYPE_DIVEBITS_CONSTANT = 1001

class DiveBits:

    @staticmethod
    def dbtest():
        print("Hi here's DiveBits' first static method!")
        #raise SyntaxError('MUHAHA THIS IS A ERROR')

    @staticmethod
    def num_configbits(component) -> int:
        bitcount = 0;
        if ("DB_TYPE" not in component):
            raise SyntaxError('No DB_TYPE in component')
        else:
            db_type = component["DB_TYPE"]

            ### TODO seek best equivalent of case structure
            if (db_type == TYPE_DIVEBITS_CONSTANT):
                if "DB_VECTOR_WIDTH" not in component:
                    raise SyntaxError('DB_VECTOR_WIDTH parameter missing')
                else:
                    db_vector_width = component["DB_VECTOR_WIDTH"]
                    if (db_vector_width != 0):
                        bitcount += db_vector_width
                        bitcount += DB_ADDRESS_BITWIDTH
                        bitcount += DB_CHANNEL_BITWIDTH
                        bitcount += DB_LENGTH_BITWIDTH
                        return bitcount
                    else:
                        raise SyntaxError('DB_VECTOR_WIDTH is 0')
            ###... elseif other types...
            ###
            else:
                raise SyntaxError('DB_TYPE unknown')


    @staticmethod
    def generate_template(component) -> int:
        bitcount = 0;
        if ("DB_TYPE" not in component):
            raise SyntaxError('No DB_TYPE in component')
        else:
            db_type = component["DB_TYPE"]

            ### TODO seek best equivalent of case structure
            if (db_type == TYPE_DIVEBITS_CONSTANT):
                if "DB_VECTOR_WIDTH" not in component:
                    raise SyntaxError('DB_VECTOR_WIDTH parameter missing')
                else:
                    db_vector_width = component["DB_VECTOR_WIDTH"]
                    if (db_vector_width != 0):
                        bitcount += db_vector_width
                        bitcount += DB_ADDRESS_BITWIDTH
                        bitcount += DB_CHANNEL_BITWIDTH
                        bitcount += DB_LENGTH_BITWIDTH
                        return bitcount
                    else:
                        raise SyntaxError('DB_VECTOR_WIDTH is 0')
            ###... elseif other types...
            ###
            else:
                raise SyntaxError('DB_TYPE unknown')
