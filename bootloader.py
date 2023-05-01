import assembler

skeleton_start = \
"""
-- this file was autogenerated using bootloader.py
-- see that file for usage details


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instructionMemory is
    port(
        clk : in std_logic;
        address : in std_logic_vector(15 downto 0);
        instruction : out std_logic_vector(15 downto 0)
    );
end entity instructionMemory;

architecture instructions of instructionMemory is
    type instructionMemoryDataType is array (0 to 255) of std_logic_vector(7 downto 0);
    signal instructionMemoryData : instructionMemoryDataType := (
"""

skeleton_end = \
"""   
    );
begin 
instruction(15 downto 8) <= instructionMemoryData(to_integer(unsigned(address)));
instruction(7 downto 0) <= instructionMemoryData(to_integer(unsigned(address))+1);
end architecture instructions;
"""

class fileArray:
    def __init__(self) -> None:
        self.data = []

    def write(self, data):
        self.data.append(data)
    
    def flush(self):
        pass

def main():
    import sys
    instructions = fileArray()

    file = open(sys.argv[1])
    outputfile = open('instructionMem.vhdl', 'w')
    assembler.main(file=file, outfile=instructions)
    instructions.data.extend(['0000001001000000', '\n']*(128-len(instructions.data)//2))
    print(skeleton_start, end='', file=outputfile)
    for i, inst in enumerate(instructions.data):
        if inst == '\n':
            pass
        else:
            i1, i2 = inst[0:8], inst[8:]
            if i == len(instructions.data)-2:
                print(' '* 8, f'"{i1}", "{i2}"', end='', file=outputfile)
            else:
                print(' '*8, f'"{i1}", "{i2}",', file=outputfile)
    print(skeleton_end, file=outputfile)


if __name__ == '__main__':
    main()