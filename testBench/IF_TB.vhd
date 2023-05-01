library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dataTypeConverter.all;

entity test is
end entity test;

architecture Behave of test is
    --Component
    component instructionFetch is
        port(
        clk : in std_logic;
        PCtoFetch : in std_logic_vector(15 downto 0);
        instruction : out std_logic_vector(15 downto 0);
        PCfromEx : in std_logic_vector(15 downto 0);
        PCbranchSignal_Ex : in std_logic;
        PCOutFinal : out std_logic_vector(15 downto 0)
    );
    end component;


    --Signals
    signal clk : std_logic := '0';
    signal PCtoFetch : std_logic_vector(15 downto 0) := (others => '0');
    signal instruction : std_logic_vector(15 downto 0) := (others => '0');
    signal PCfromEx : std_logic_vector(15 downto 0) := (others => '0');
    signal PCbranchSignal_Ex : std_logic := '0';
    signal PCOutFinal : std_logic_vector(15 downto 0) := (others => '0');
    signal testvar : std_logic_vector(15 downto 0) := (others => '0');

begin
    instructionFetch1 : instructionFetch port map(
        clk => clk,
        PCtoFetch => PCtoFetch,
        instruction => instruction,
        PCfromEx => PCfromEx,
        PCbranchSignal_Ex => PCbranchSignal_Ex,
        PCOutFinal => PCOutFinal
    );
    process
    variable OUTPUT_LINE: line;
    variable LINE_COUNT: integer := 0;
    variable i : integer := 0;
    File OUTFILE: text open write_mode is "testBench/IF_TB.out";

    begin
        while i < 10 loop
            clk <= not clk;
            wait for 10 ns;
            i := i + 1;
            PCtoFetch <= PCOutFinal;
            write(OUTPUT_LINE, to_string("Instruction: "));
            write(OUTPUT_LINE, to_bitvector(instruction));
            write(OUTPUT_LINE, to_string(" PCtoFetch: "));
            write(OUTPUT_LINE, to_bitvector(PCtoFetch));
            write(OUTPUT_LINE, to_string(" PCOUT: "));
            write(OUTPUT_LINE, to_bitvector(PCOutFinal));
            writeline(OUTFILE, OUTPUT_LINE);
            clk <= not clk;
            wait for 10 ns;
        end loop;
    end process;
end Behave;