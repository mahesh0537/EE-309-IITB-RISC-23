class UnrecognizedInstructionException(ValueError):
    def __init__(self) -> None:
        super().__init__()

class InvalidInstructionFormatException(ValueError):
    def __init__(self) -> None:
        super().__init__()


def getRegisterEncoding(reg: str):
    if len(reg) != 2 or reg[0].lower() != 'r':
        raise InvalidInstructionFormatException
    reg_int = int(reg[1])

    # we have only 7 registers 
    if not (0 <= reg_int <= 7):
        raise InvalidInstructionFormatException
    return reg_int


def getImmediateEncoding(imm, length):
    try:
        # written in hex
        if '0x' in imm:
            enc = int(imm, base=16)
        # written in binary
        elif '0b' in imm:
            enc = int(imm, base=2)
        else:
        # assume decimal
            enc = int(imm)
    except ValueError:
        raise InvalidInstructionFormatException

    # ensure that the supplied immediate fits in the size
    # the range is as such because the immediates are signed
    if not (-(2**(length-1)) <= enc <= 2**(length) - 1):
        raise InvalidInstructionFormatException
    return enc


# instruction format is:
# OP Ra, Rb, Rc, C, Cz
# (OP, C, Cz) are mentioned below
RTypeInstructions = {
    'ada': (0b00_01, 0b0, 0b00),
    'adc': (0b00_01, 0b0, 0b10), 
    'adz': (0b00_01, 0b0, 0b01), 
    'awc': (0b00_01, 0b0, 0b11), 
    'aca': (0b00_01, 0b1, 0b00), 
    'acc': (0b00_01, 0b1, 0b10), 
    'acz': (0b00_01, 0b1, 0b01), 
    'acw': (0b00_01, 0b1, 0b11),
    'ndu': (0b00_10, 0b0, 0b00), 
    'ndc': (0b00_10, 0b0, 0b10), 
    'ndz': (0b00_10, 0b0, 0b01), 
    'ncu': (0b00_10, 0b1, 0b00), 
    'ncc': (0b00_10, 0b1, 0b10), 
    'ncz': (0b00_10, 0b1, 0b01),
}

# instruction format is:
# OP Ra, Rc, Imm6
ITypeInstructions = {
    'adi': (0b00_00,), 
    'lw' : (0b01_00,), 
    'sw' : (0b01_01,), 
    'beq': (0b10_00,), 
    'blt': (0b10_01,), 
    'ble': (0b10_10,), # 0b10_01 is mentioned in the doc, same at blt. might be a typo
    'jlr': (0b11_01,),
}

# instruction format is:
# OP Ra, Imm9
JTypeInstructions = {
    'lli': (0b00_11,),
    'lm' : (0b01_10,), 
    'sm' : (0b01_11,), 
    'jal': (0b11_00,), 
    'jri': (0b11_11,), 
}

def assemble(line: str):
    toks = [t.rstrip(',') for t in line.split()]
    inst = toks[0].lower()
    if inst in RTypeInstructions:
        _, rc, ra, rb = toks
        ra_enc = getRegisterEncoding(ra)
        rb_enc = getRegisterEncoding(rb)
        rc_enc = getRegisterEncoding(rc)
        opcode, complement, condition = RTypeInstructions[inst]
        return (
            convertToBinary(opcode, 4),
            convertToBinary(ra_enc, 3),
            convertToBinary(rb_enc, 3),
            convertToBinary(rc_enc, 3),
            convertToBinary(complement, 1),
            convertToBinary(condition, 2)
        )
    elif inst in  ITypeInstructions:
        _, ra, rb, imm6 = toks
        ra_enc = getRegisterEncoding(ra)
        rb_enc = getRegisterEncoding(rb)

        # the encoding of adi instruction is given to be opposite
        # so make changes as necessary
        if inst.lower() == 'adi':
            ra_enc, rb_enc = rb_enc, ra_enc

        imm6_enc = getImmediateEncoding(imm6, 6)
        opcode, = ITypeInstructions[inst]
        return (
            convertToBinary(opcode, 4),
            convertToBinary(ra_enc, 3),
            convertToBinary(rb_enc, 3),
            convertToBinary(imm6_enc, 6)
        )
    elif inst in JTypeInstructions:
        _, ra, imm9 = toks
        ra_enc = getRegisterEncoding(ra)
        imm9_enc = getImmediateEncoding(imm9, 9)
        opcode, = JTypeInstructions[inst]
        return (
            convertToBinary(opcode, 4),
            convertToBinary(ra_enc, 3),
            convertToBinary(imm9_enc, 9)
        )
    else:
        raise UnrecognizedInstructionException


def convertToBinary(num: int, size: int):
    # we have to do this wierd conversion because the built in bin()
    # doesnt return the 2's complement representation of a negative
    # integer. we take modulo with 2**size to take only the lower bits
    # withing the specified size
    n = int.from_bytes(
        num.to_bytes(32, signed=True)
    ) % (2**size)
    return f'{{0:0{size}b}}'.format(n)




def main():
    import sys
    if len(sys.argv) == 1:
        print('no input file specified')
        print('usage: `python assembler.py <file>`')
        print('** ABORT **')
        exit(1)
    file_name = sys.argv[1]
    
    try:
        with open(file_name) as f:
            lines = f.readlines()
    except:
        print(f'"{file_name}": no such file in directory')
        print('** ABORT **')
        exit(2)
    
    for i, line in enumerate(lines):
        line = line.split(';')[0].strip()
        if line:
            try:
                print(''.join(assemble(line)))
            except:
                print(f'ERROR on line {i+1}')
                print('** ABORT **')
                exit(1)

if __name__ == '__main__':
    main()
