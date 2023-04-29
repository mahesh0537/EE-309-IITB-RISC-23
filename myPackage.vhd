library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

package my_pkg is
    function zeroFlagFinder(a : in std_logic_vector(15 downto 0)) return std_logic;
    function carryFlagFinder(operandAmsp :in std_logic; operandBmsp : in std_logic; resultmsp :in std_logic) return std_logic;
    function std_logic_to_bit(std_logic_val : std_logic) return String;
    file output : text open write_mode is "console.log";   
    procedure writer16(a : in std_logic_vector(15 downto 0));


end my_pkg; 

package body my_pkg is
    function zeroFlagFinder(a : in std_logic_vector(15 downto 0)) return std_logic is
        begin
            if a = x"0000" then
                return '1';
            else
                return '0';
            end if;
    end function zeroFlagFinder;
    function carryFlagFinder(operandAmsp :in std_logic; operandBmsp : in std_logic; resultmsp :in std_logic) return std_logic is
        begin
            if resultmsp = '1' then
                return '1';
            else
                return '0';
            end if;
    end function carryFlagFinder;
    function std_logic_to_bit(std_logic_val : std_logic) return String is
        begin
            if std_logic_val = '0' then
            return "0";
            else
            return "1";
            end if;
    end function;
    procedure writer16(a : in std_logic_vector(15 downto 0)) is
        begin
        for i in 0 to 15 loop
            write(output, std_logic_to_bit(a(i)));
        end loop;
    end procedure writer16;
end package body my_pkg;