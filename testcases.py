import sys
import typing
# sys.path.extend("C:\\Users\\Pari\\Desktop\\Lectures\\EE309 - Microprocessors\\project\\iitbrisc23\\assembler")
if typing.TYPE_CHECKING:
    from .. import assembler
else:
    import assembler

convertToBinary = assembler.convertToBinary

RTypeInstructions = assembler.RTypeInstructions
ITypeInstructions = assembler.ITypeInstructions
JTypeInstructions = assembler.JTypeInstructions

class FileArray:
    def __init__(self) -> None:
        self.data = []

    def write(self, data):
        self.data.extend(data)
    
    def flush(self):
        pass

def getRegRands():
    import random
    return list(random.randrange(0, 2**16) for _ in range(8))

def RZC_add(r):
    c = 1 if r > 2**16 else 0

    z = 1 if r == 0 else 0

    r = assembler.convertToBinary(r % 2**16, 16)
    
    return r, z, c


def RZC_nand(r, cin):
    r = int(r, base=2)
    z = 1 if r == 0 else 0
    r = assembler.convertToBinary(r % 2**16, 16)
    return r, z, cin


def instOP_cond_compl(op):
    # instruction format is:
    # OP Ra, Rb, Rc, C, Cz
    # (OP, C, Cz) are mentioned below
    RType = ['ada', 'adc', 'adz', 'awc', 'aca', 'acc', 'acz', 'acw', 'ndu', 'ndc', 'ndz', 'ncu', 'ncc', 'ncz']

    # instruction format is:
    # OP Ra, Rc, Imm6
    IType = ['adi', 'lw', 'sw', 'beq', 'blt', 'ble', 'jlr']

    # instruction format is:
    # OP Ra, Imm9
    JType = ['lli', 'lm', 'sm', 'jal', 'jri']
    
    if op in RType:
        return convertToBinary(RTypeInstructions[op][0], 4), convertToBinary(RTypeInstructions[op][2], 2), convertToBinary(RTypeInstructions[op][1], 1)
    elif op in IType:
        return convertToBinary(RTypeInstructions[op][0], 4)
    elif op in JType:

    else:
        print('InvalidInstruction')


def bitwiseNot(a):
    result = ''
    for c in a:
        result += '1' if c == '0' else '0'
    return result

def bitwiseNand(a, b):
    result = ''
    for c1, c2 in zip(a, b):
        result += (
            '1' if (int(c1) * int(c2)) == 0 else '0'
        )
    return result


def main():
    f = open('../TRACEFILE.txt', 'w')
    tcs = []
    r0, r1, r2, r3, r4, r5, r6, r7 = map(lambda n: assembler.convertToBinary(n, 16), getRegRands())
    tcs.extend([
        # A B op condition compl zfin cfin, result zfout cfout useresult
        [r0, r1, *instOP_cond_compl('ada'), 0, 0, ' ', *RZC_add(int(r0, base=2) + int(r1, base=2)), 1, ' ', '1'*19],
        [r0, r1, *instOP_cond_compl('ada'), 1, 0, ' ', *RZC_add(int(r0, base=2) + int(r1, base=2)), 1, ' ', '1'*19],
        [r0, r1, *instOP_cond_compl('ada'), 0, 1, ' ', *RZC_add(int(r0, base=2) + int(r1, base=2)), 1, ' ', '1'*19],
        [r0, r1, *instOP_cond_compl('ada'), 1, 1, ' ', *RZC_add(int(r0, base=2) + int(r1, base=2)), 1, ' ', '1'*19],
    ])

    tcs.extend([
        [convertToBinary(2*15 - 1, 16), convertToBinary(2*15 - 1, 16), *instOP_cond_compl('ada'), 0, 1, ' ', *RZC_add(2*16 - 2), 1, ' ', '1'*19],
        [convertToBinary(10, 16), convertToBinary(-1, 16), *instOP_cond_compl('ada'), 0, 1, ' ', *RZC_add(2**16 + 9), 1, ' ', '1'*19]
    ])

    tcs.extend([
        [r3, r4, *instOP_cond_compl('adc'), 0, 1, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 1, ' ', '1'*19],
        [r3, r4, *instOP_cond_compl('adc'), 1, 1, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 1, ' ', '1'*19],
        [r3, r4, *instOP_cond_compl('adc'), 1, 0, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 0, ' ', '1'*19],
        [r3, r4, *instOP_cond_compl('adc'), 0, 0, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 0, ' ', '1'*19],
    ])

    tcs.extend([
        [r3, r4, *instOP_cond_compl('adz'), 0, 1, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 0, ' ', '1'*19],
        [r3, r4, *instOP_cond_compl('adz'), 1, 1, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 1, ' ', '1'*19],
        [r3, r4, *instOP_cond_compl('adz'), 1, 0, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 1, ' ', '1'*19],
        [r3, r4, *instOP_cond_compl('adz'), 0, 0, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 0, ' ', '1'*19],
    ])

    tcs.extend([
        [r0, r1, *instOP_cond_compl('awc'), 0, 0, ' ', *RZC_add(int(r0, base = 2) + int(r1, base = 2)), 0, ' ', '1'*19],
        [r0, r1, *instOP_cond_compl('awc'), 1, 0, ' ', *RZC_add(int(r0, base = 2) + int(r1, base = 2)), 0, ' ', '1'*19],
        [r0, r1, *instOP_cond_compl('awc'), 1, 1, ' ', *RZC_add(int(r0, base = 2) + int(r1, base = 2)), 1, ' ', '1'*19],
        [r0, r1, *instOP_cond_compl('awc'), 0, 1, ' ', *RZC_add(int(r0, base = 2) + int(r1, base = 2)), 1, ' ', '1'*19],
    ])

    tcs.extend([
        [r5, r1, *instOP_cond_compl('aca'), 0, 0, ' ', *RZC_add(int(r0, base = 2) + int(bitwiseNot(r1), base = 2)), 1, ' ', '1'*19],
        [r5, r1, *instOP_cond_compl('aca'), 1, 0, ' ', *RZC_add(int(r0, base = 2) + int(bitwiseNot(r1), base = 2)), 1, ' ', '1'*19],
        [r5, r1, *instOP_cond_compl('aca'), 1, 1, ' ', *RZC_add(int(r0, base = 2) + int(bitwiseNot(r1), base = 2)), 1, ' ', '1'*19],
        [r5, r1, *instOP_cond_compl('aca'), 0, 1, ' ', *RZC_add(int(r0, base = 2) + int(bitwiseNot(r1), base = 2)), 1, ' ', '1'*19],
    ])

    tcs.extend([
        [r5, r1, *instOP_cond_compl('acc'), 0, 0, ' ', *RZC_add(int(r0, base = 2) + int(bitwiseNot(r1), base = 2)), 0, ' ', '1'*19],
        [r5, r1, *instOP_cond_compl('acc'), 1, 0, ' ', *RZC_add(int(r0, base = 2) + int(bitwiseNot(r1), base = 2)), 0, ' ', '1'*19],
        [r5, r1, *instOP_cond_compl('acc'), 1, 1, ' ', *RZC_add(int(r0, base = 2) + int(bitwiseNot(r1), base = 2)), 1, ' ', '1'*19],
        [r5, r1, *instOP_cond_compl('acc'), 0, 1, ' ', *RZC_add(int(r0, base = 2) + int(bitwiseNot(r1), base = 2)), 1, ' ', '1'*19],
    ])

    tcs.extend([
        [r5, r1, *instOP_cond_compl('acz'), 0, 0, ' ', *RZC_add(int(r0, base = 2) + int(bitwiseNot(r1), base = 2)), 0, ' ', '1'*19],
        [r5, r1, *instOP_cond_compl('acz'), 1, 0, ' ', *RZC_add(int(r0, base = 2) + int(bitwiseNot(r1), base = 2)), 1, ' ', '1'*19],
        [r5, r1, *instOP_cond_compl('acz'), 1, 1, ' ', *RZC_add(int(r0, base = 2) + int(bitwiseNot(r1), base = 2)), 1, ' ', '1'*19],
        [r5, r1, *instOP_cond_compl('acz'), 0, 1, ' ', *RZC_add(int(r0, base = 2) + int(bitwiseNot(r1), base = 2)), 0, ' ', '1'*19],
    ])

    tcs.extend([
        [r2, r5, *instOP_cond_compl('acw'), 0, 0, ' ', *RZC_add(int(r2, base=2) + int(bitwiseNot(r5), base=2)), 1, ' ', '1'*19],
        [r2, r5, *instOP_cond_compl('acw'), 1, 0, ' ', *RZC_add(int(r2, base=2) + int(bitwiseNot(r5), base=2)), 1, ' ', '1'*19],
        [r2, r5, *instOP_cond_compl('acw'), 0, 1, ' ', *RZC_add(int(r2, base=2) + int(bitwiseNot(r5), base=2) + 1), 1, ' ', '1'*19],
        [r2, r5, *instOP_cond_compl('acw'), 1, 1, ' ', *RZC_add(int(r2, base=2) + int(bitwiseNot(r5), base=2) + 1), 1, ' ', '1'*19],
    ])

    tcs.extend([
        [r6, r7, *instOP_cond_compl('ndu'), 0, 0, ' ', *RZC_nand(bitwiseNand(r6, r7), 0), 1, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ndu'), 0, 1, ' ', *RZC_nand(bitwiseNand(r6, r7), 1), 1, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ndu'), 1, 0, ' ', *RZC_nand(bitwiseNand(r6, r7), 0), 1, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ndu'), 1, 1, ' ', *RZC_nand(bitwiseNand(r6, r7), 1), 1, ' ', '1'*19],
    ])

    tcs.extend([
        [r6, r7, *instOP_cond_compl('ndc'), 0, 0, ' ', *RZC_nand(bitwiseNand(r6, r7), 0), 0, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ndc'), 0, 1, ' ', *RZC_nand(bitwiseNand(r6, r7), 1), 1, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ndc'), 1, 0, ' ', *RZC_nand(bitwiseNand(r6, r7), 0), 0, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ndc'), 1, 1, ' ', *RZC_nand(bitwiseNand(r6, r7), 1), 1, ' ', '1'*19],
    ])

    tcs.extend([
        [r6, r7, *instOP_cond_compl('ndz'), 0, 0, ' ', *RZC_nand(bitwiseNand(r6, r7), 0), 0, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ndz'), 0, 1, ' ', *RZC_nand(bitwiseNand(r6, r7), 1), 0, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ndz'), 1, 0, ' ', *RZC_nand(bitwiseNand(r6, r7), 0), 1, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ndz'), 1, 1, ' ', *RZC_nand(bitwiseNand(r6, r7), 1), 1, ' ', '1'*19],
    ])

    tcs.extend([
        [r6, r7, *instOP_cond_compl('ncu'), 0, 0, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 0), 1, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ncu'), 0, 1, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 1), 1, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ncu'), 1, 0, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 0), 1, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ncu'), 1, 1, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 1), 1, ' ', '1'*19],
    ])

    tcs.extend([
        [r6, r7, *instOP_cond_compl('ncc'), 0, 0, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 0), 0, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ncc'), 0, 1, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 1), 1, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ncc'), 1, 0, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 0), 0, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ncc'), 1, 1, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 1), 1, ' ', '1'*19],
    ])

    tcs.extend([
        [r6, r7, *instOP_cond_compl('ncc'), 0, 0, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 0), 0, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ncz'), 0, 1, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 1), 0, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ncz'), 1, 0, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 0), 1, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ncz'), 1, 1, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 1), 1, ' ', '1'*19],
    ])

    for tc in tcs:
        print(''.join(map(str, tc)), file=f)
        print(''.join(map(str, tc)))

if __name__ == '__main__':
    main()