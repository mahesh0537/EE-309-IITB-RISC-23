library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dataTypeConverter.all;

entity singleCycle is

end singleCycle;


architecture Behave of singleCycle is
    --COMPONENTS
    component instructionMemory is
        port(
            clk : in std_logic;
            address : in std_logic_vector(15 downto 0);
            instruction : out std_logic_vector(15 downto 0)
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

    component regFile is
        port(
            clk : in std_logic;
            regWrite : in std_logic;
            reg1Addr, reg2Addr, reg3Addr : in std_logic_vector(2 downto 0);
            reg1Data, reg2Data, PC : out std_logic_vector(15 downto 0);
            reg3Data, PCtoRF : in std_logic_vector(15 downto 0);
            reset : in std_logic;
            updatePC : in std_logic;
            readPC : in std_logic
        );
    end component;

    component ALU_wrapper is
        port (
		A, B: in std_logic_vector(15 downto 0);
		opcode: in std_logic_vector(3 downto 0);
		condition: in std_logic_vector(1 downto 0);
		compliment: in std_logic;
		ZF_prev, CF_prev: in std_logic;
		result: out std_logic_vector(15 downto 0);
		ZF, CF: out std_logic;
		useResult: out std_logic
	);
    end component;

    component memory is
        port(
            RAM_Address : in std_logic_vector(15 downto 0); -- 16 bit address for read/write
            RAM_Data_IN : in std_logic_vector(15 downto 0); -- 16 bit data for write
            RAM_Data_OUT : out std_logic_vector(15 downto 0); -- 16 bit data for read
            RAM_Write : in std_logic; -- write enable
            RAM_Clock : in std_logic -- clock
    );
    end component;

    component writeBack is
        port(
        clk : in std_logic;
        writeSignal : in std_logic;
        writeSignalOut : out std_logic;
        selectSignalEx_RAM : in std_logic;
        writeDataIN_Ex : in std_logic_vector(15 downto 0);
        writeDataIN_RAM : in std_logic_vector(15 downto 0);
        writeDataOUT : out std_logic_vector(15 downto 0);
        writeAddressIN : in std_logic_vector(2 downto 0);
        writeAddressOUT : out std_logic_vector(2 downto 0)
    );
    end component;

    -- signals for integration
    signal instruction: std_logic_vector(15 downto 0);
    signal Ra_ID, Rb_ID, Rc_ID: std_logic_vector(2 downto 0);
    signal immediate_ID: std_logic_vector(15 downto 0);
    signal condition_ID: std_logic_vector(1 downto 0);
    signal useComplement_ID: std_logic;
    signal opcode_ID: std_logic_vector(3 downto 0);
    signal PC_RF, PCtoRF, reg3Data_WB, reg3Data_Ex: std_logic_vector(15 downto 0) := (others => '0');
    signal reg1Data_RF, reg2Data_RF: std_logic_vector(15 downto 0);
    signal reg3Addr_WB: std_logic_vector(2 downto 0);
    signal regWrite_WB: std_logic := '0';
    signal clk: std_logic := '0';
    signal reset: std_logic := '0';
    signal ZF_prev, CF_prev, ZF_Ex, CF_Ex, useResult_Ex: std_logic := '0';
    signal readPC, updatePC: std_logic := '0';
    signal dataFromRAM, dataToRAM, addressOfRAM: std_logic_vector(15 downto 0);
    signal writeSignalToRAM : std_logic := '0';
    signal selectSignalEx_RAM_Ex : std_logic := '0';

begin
    instructionMem1: instructionMemory port map(clk => clk, address => PC_RF, instruction => instruction);
    instructionDecoder1: instructionDecoder port map(instruction => instruction, Ra => Ra_ID, Rb => Rb_ID, Rc => Rc_ID, immediate => immediate_ID, condition => condition_ID, useComplement => useComplement_ID, opcode => opcode_ID);
    regFile1: regFile port map(clk => clk, regWrite => regWrite_WB, reg1Addr=> Ra_ID, reg2Addr => Rb_ID, reg3Addr => reg3Addr_WB, reg1Data => reg1Data_RF, reg2Data => reg2Data_RF, PC => PC_RF, reg3Data => reg3Data_WB, PCtoRF => PCtoRF, reset => reset, updatePC => updatePC, readPC => readPC);
    ALU_wrapper1: ALU_wrapper port map(reg1Data_RF, reg2Data_RF, opcode_ID, condition_ID, useComplement_ID, ZF_prev, CF_prev, reg3Data_Ex, ZF_Ex, CF_Ex, useResult_Ex);
    RAM1 : memory port map(RAM_Address => addressOfRAM, RAM_Data_IN => dataToRAM, RAM_Data_OUT => dataFromRAM, RAM_Write => writeSignalToRAM, RAM_Clock => clk);
    writeBack1: writeBack port map(clk => clk, writeSignal => useResult_Ex, writeSignalOut => regWrite_WB, selectSignalEx_RAM =>selectSignalEx_RAM_Ex, writeDataIN_RAM => dataFromRAM, writeDataIN_Ex => reg3Data_Ex, writeDataOUT => reg3Data_WB, writeAddressIN => Rc_ID, writeAddressOUT => reg3Addr_WB);

    process
        -- for read and write
        variable OUTPUT_LINE: line;
        variable LINE_COUNT: integer := 0;
        variable i : integer := 0;

        -- Instruction read
        File OUTFILE: text open write_mode is "testBench/singleCycle.out";

        begin
            
            while i < 10 loop
                --Just Testing
                --CLOCK
                clk <= not clk;
                wait for 20 ns;

                --Instruction Decoder
                write(OUTPUT_LINE, to_string("Instruction: "));
                write(OUTPUT_LINE, to_bit_vector(instruction));
                write(OUTPUT_LINE, to_bit_vector(PC_RF));
                writeline(OUTFILE, OUTPUT_LINE);
                clk <= not clk;
                wait for 20 ns;
                i := i + 1;
            end loop;
            wait;
        end process;
    
end Behave;
