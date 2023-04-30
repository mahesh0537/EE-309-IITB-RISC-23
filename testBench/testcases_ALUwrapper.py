import sys
import typing
sys.path.append("C:\\Users\\Pari\\Desktop\\Lectures\\EE309 - Microprocessors\\project\\iitbrisc23\\assembler")
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
        self.data.append(data)
    
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
    return convertToBinary(RTypeInstructions[op][0], 4), convertToBinary(RTypeInstructions[op][2], 2), convertToBinary(RTypeInstructions[op][1], 1)


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
        [r3, r4, *instOP_cond_compl('adz'), 0, 1, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 0, ' ', '1'*19],
        [r3, r4, *instOP_cond_compl('adz'), 1, 1, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 1, ' ', '1'*19],
        [r3, r4, *instOP_cond_compl('adz'), 1, 0, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 1, ' ', '1'*19],
        [r3, r4, *instOP_cond_compl('adz'), 0, 0, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 0, ' ', '1'*19],
    ])

    tcs.extend([
        [r3, r4, *instOP_cond_compl('adc'), 0, 1, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 1, ' ', '1'*19],
        [r3, r4, *instOP_cond_compl('adc'), 1, 1, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 1, ' ', '1'*19],
        [r3, r4, *instOP_cond_compl('adc'), 1, 0, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 0, ' ', '1'*19],
        [r3, r4, *instOP_cond_compl('adc'), 0, 0, ' ', *RZC_add(int(r3, base=2) + int(r4, base=2)), 0, ' ', '1'*19],
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
        [r6, r7, *instOP_cond_compl('ncc'), 0, 0, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 0), 0, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ncc'), 0, 1, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 1), 1, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ncc'), 1, 0, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 0), 0, ' ', '1'*19],
        [r6, r7, *instOP_cond_compl('ncc'), 1, 1, ' ', *RZC_nand(bitwiseNand(r6, bitwiseNot(r7)), 1), 1, ' ', '1'*19],
    ])

    tcs.append([
        convertToBinary(10, 16), convertToBinary(-1, 16), *instOP_cond_compl('ada'), 0, 1, ' ', *RZC_add(2**16 + 89), 1, ' ', '1'*19
    ])


    for tc in tcs:
        print(''.join(map(str, tc)), file=f)
        print(''.join(map(str, tc)))

if __name__ == '__main__':
    main()