from bitstring import BitArray

# TODO remember to keep the 20 config length bits out... they are not sent out!
# TODO remember including CRC address (0x0000?) and length (32/0x20) in CRC calculation


if __name__ == "__main__":

    # Standard CRC32b-polynomial
    # x32 + x26 + x23 + x22 + x16 + x12 + x11 + x10 + x8 + x7 + x5 + x4 + x2 + x + 1.
    #CRC32b = BitArray('0b 1  0000  0100  1100  0001  0001  1101  1011  0111 ')
                         #32  31-28 27-24 23-20 19-16 15-12 11-8  7-4   3-0
    CRC32b_x32_x0 = BitArray(bin='1  0000  0100  1100  0001  0001  1101  1011  0111 ')
    print(CRC32b_x32_x0.bin)
    CRC32b_x35_x0 = BitArray(bin='0001  0000  0100  1100  0001  0001  1101  1011  0111 ')
    print(CRC32b_x35_x0.hex)

    # 1 + x + x2 + ... + x32
    CRC32b_x0_to_x32 = BitArray(bin='1110 1101 1011 1000 1000 0011 0010 0000 1')
    print(CRC32b_x0_to_x32.bin)
    CRC32b_x0_to_x31 = BitArray(bin='1110 1101 1011 1000 1000 0011 0010 0000')  # w/o x32
    print(CRC32b_x0_to_x31.hex)

    polynomial: BitArray = CRC32b_x0_to_x32

    teststring = BitArray(hex="0xDEADBEEF0123456789DEADC0DE")
    teststring_length = teststring.length
    divstring = teststring.copy()
    divstring.prepend(BitArray(32))
    print("Teststring is", teststring_length, "bits long:")
    print(teststring)
    print(teststring.bin)
    print("Divstring:")
    print(divstring)
    print(divstring.bin)
    divstring.append(BitArray(1))  # attach two zeros to make indexing from LSB side easier
    print()
    print()
    print("Division:")
    print(divstring[:-1].bin)
    for i in range(1, teststring_length+1):
        if divstring[-(i+1)] == 1:
            bufferstr = " " * (teststring_length-i)
            divstring[-(i+33):-i] ^= polynomial
            print(bufferstr+polynomial.bin)
            #print(bufferstr+divstring[-(i+33):-i].bin)
            print(divstring[:-1].bin)
    remainder = divstring[0:32]
    teststring.prepend(remainder)
    print("Remainder:")
    print(remainder.bin)
    print(remainder.hex)
    print("Sent string:")
    print(teststring.bin)
    print(teststring.hex)

    print("Sent string plus config length parameter:")
    divebitsstring = teststring.copy()
    divebitsstring.append(BitArray(uint=(teststring_length+32+20), length=20))
    print(divebitsstring.hex)
    divebitsstring.prepend(BitArray(4))
    divebitsstring.byteswap()
    print("For MEM file insertion:", divebitsstring.hex)

    print()
    print()
    print("Receiver Division:")
    divstring = teststring.copy()
    divstring.append(BitArray(1))  # attach two zeros to make indexing from LSB side easier
    print(divstring[:-1].bin)
    for i in range(1, teststring_length+1):
        if divstring[-(i+1)] == 1:
            bufferstr = " " * (teststring_length-i)
            divstring[-(i+33):-i] ^= polynomial
            print(bufferstr+polynomial.bin)
            #print(bufferstr+divstring[-(i+33):-i].bin)
            print(divstring[:-1].bin)
    remainder = divstring[0:32]
    teststring.prepend(remainder)
    print("Remainder:")
    print(remainder.bin)
    print(remainder.hex)
