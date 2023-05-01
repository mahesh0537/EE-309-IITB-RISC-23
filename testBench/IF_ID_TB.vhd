library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dataTypeConverter.all;

entity IF_ID is
end entity IF_ID;

architecture whatever of IF_ID is
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

    component instructionDecoder is 
    port(
		instruction: in std_logic_vector(15 downto 0);
		Ra, Rb, Rc: out std_logic_vector(2 downto 0);
		immediate: out std_logic_vector(15 downto 0);
		condition: out std_logic_vector(1 downto 0);
		useComplement: out std_logic;
		opcode: out std_logic_vector(3 downto 0)
    );
    end component;


    --Signals
    signal clk : std_logic := '0';
    signal PCtoFetch : std_logic_vector(15 downto 0) := (others => '0');
    signal instruction_IF : std_logic_vector(15 downto 0) := (others => '0');
    signal PCfrom_Ex : std_logic_vector(15 downto 0) := (others => '0');
    signal PCbranchSignal_Ex : std_logic := '0';
    signal PCOutFinal_IF : std_logic_vector(15 downto 0) := (others => '0');
    signal testvar : std_logic_vector(15 downto 0) := (others => '0');

    --Signal for Instruction Decoder
    signal Ra_ID, Rb_ID, Rc_ID : std_logic_vector(2 downto 0) := (others => '0');
    signal immediate_ID : std_logic_vector(15 downto 0) := (others => '0');
    signal condition_ID : std_logic_vector(1 downto 0) := (others => '0');
    signal useComplement_ID : std_logic := '0';
    signal opcode_ID : std_logic_vector(3 downto 0) := (others => '0');


begin
    instructionFetch1 : instructionFetch port map(
        clk => clk,
        PCtoFetch => PCtoFetch,
        instruction => instruction_IF,
        PCfromEx => PCfrom_Ex,
        PCbranchSignal_Ex => PCbranchSignal_Ex,
        PCOutFinal => PCOutFinal_IF
    );
    instructionDecode1 : instructionDecoder port map(
        instruction => instruction_IF,
        Ra => Ra_ID, Rb => Rb_ID, Rc => Rc_ID,
        immediate => immediate_ID, condition => condition_ID,
        useComplement => useComplement_ID,
        opcode => opcode_ID
    );
    process
    variable OUTPUT_LINE: line;
    variable LINE_COUNT: integer := 0;
    variable i : integer := 0;
    File OUTFILE: text open write_mode is "testBench/IF_ID_TB.out";

    begin
        while i < 10 loop
            clk <= not clk;
            wait for 10 ns;
            i := i + 1;
            PCtoFetch <= PCOutFinal_IF;
            --IF WRITE
            write(OUTPUT_LINE, to_string("Instruction: "));
            write(OUTPUT_LINE, to_bitvector(instruction_IF));
            write(OUTPUT_LINE, to_string(" PCtoFetch: "));
            write(OUTPUT_LINE, to_bitvector(PCtoFetch));
            write(OUTPUT_LINE, to_string(" PCOUT: "));
            write(OUTPUT_LINE, to_bitvector(PCOutFinal_IF));
            writeline(OUTFILE, OUTPUT_LINE);

            --ID WRITE
            write(OUTPUT_LINE, to_string("Ra: "));
            write(OUTPUT_LINE, to_bitvector(Ra_ID));
            write(OUTPUT_LINE, to_string(" Rb: "));
            write(OUTPUT_LINE, to_bitvector(Rb_ID));
            write(OUTPUT_LINE, to_string(" Rc: "));
            write(OUTPUT_LINE, to_bitvector(Rc_ID));
            write(OUTPUT_LINE, to_string(" immediate: "));
            write(OUTPUT_LINE, to_bitvector(immediate_ID));
            write(OUTPUT_LINE, to_string(" condition: "));
            write(OUTPUT_LINE, to_bitvector(condition_ID));
            write(OUTPUT_LINE, to_string(" useComplement: "));
            write(OUTPUT_LINE, std_logic_to_bit(useComplement_ID));
            write(OUTPUT_LINE, to_string(" opcode: "));
            write(OUTPUT_LINE, to_bitvector(opcode_ID));
            writeline(OUTFILE, OUTPUT_LINE);
            clk <= not clk;
            wait for 10 ns;
        end loop;
    end process;
end whatever;