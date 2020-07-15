import sys
from os import path
from bitstring import BitArray
import yaml
from DiveBits import DiveBits

DB_CONFIG_LENGTH_BITWIDTH = 20

db_project_path = ""

if __name__ == "__main__":

    if (len(sys.argv) > 1):
        db_project_path = str(sys.argv[1])
        #print (db_project_path)
    else: #TODO remove below
        db_project_path = "/home/willenbe/Projekte/DB_PROJECT_2020.1a/divebits/"

    excomp_file = db_project_path + "/1_extracted_components/db_components.yaml"
    template_file = db_project_path + "/4_data_template/db_template.yaml"
    #print(excomp_file)
    #print(template_file)


    # Read YAML file
    if (path.exists(excomp_file)):
        data = yaml.safe_load(open(excomp_file))
        print()
        print("Complete db_components list:")
        print(data['db_components'])
    else:
        raise SyntaxError('No file with extracted block diagram components')

    plant_ids = []
    flag_no_ids = 0


    bitcount = 0

    for component in data['db_components']:
        print()
        print(component["NAME"], "is type", component["DB_TYPE"], "and has address", hex(component["DB_ADDRESS"]))
        print(component)
        bitcount += DiveBits.num_configbits(component)

    bitcount += DB_CONFIG_LENGTH_BITWIDTH
    bram32cnt = bitcount // 32768
    if ((bitcount % 32768) != 0):
        bram32cnt += 1

    print()
    print("Complete number of DB config bits:", bitcount)
    print("Number of RAMB36 required:", bram32cnt)
    # TODO: Check against DB_NUM_OF_32K_ROMS parameter for divebits_config
    #       Generate Tcl command or return parameter to fix it






    stream = open(template_file, 'w')
    yaml.dump(data,stream, sort_keys=False)


    # print(type(component["NAME"]))
    # print(type(component["DB_TYPE"]))
    # print(type(component["DB_ADDRESS"]))
    # print(int(-65).bit_length())
    # print(BitArray(int=component["DB_ADDRESS"],length=16).bin)
    #print("sys.maxsize", sys.maxsize)
    #DiveBits.dbtest()
    #Klaus = BitArray(20)
    #Klaus.overwrite(BitArray(uint=15,length=4), -8)
    #print(Klaus.bin)
