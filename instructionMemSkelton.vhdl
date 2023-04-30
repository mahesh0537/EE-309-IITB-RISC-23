library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instructionMemory is
    port(
        address : in std_logic_vector(15 downto 0);
        instruction : out std_logic_vector(15 downto 0)
    );
end entity instructionMemory;

architecture instructions of instructionMemory is
    type instructionMemoryDataType is array (0 to 127) of std_logic_vector(15 downto 0);
    signal instructionMemoryData : instructionMemoryDataType := (
      
    );
begin 
instruction <= instructionMemoryData(to_integer(unsigned(address)));
end architecture instructions;