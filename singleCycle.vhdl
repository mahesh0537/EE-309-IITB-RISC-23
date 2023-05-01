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

    component execStage is
        port(
            clk: in std_logic;
        
            opcode: in std_logic_vector(3 downto 0);
            Ra, Rb, Rc: in std_logic_vector(2 downto 0);
            RaValue, RbValue: in std_logic_vector(15 downto 0);
            immediate: in std_logic_vector(15 downto 0);
            condition: in std_logic_vector(1 downto 0);
            useComplement: in std_logic;
            PC: in std_logic_vector(15 downto 0);
            
            -- this PC is to be used when a branch instruction is
            -- executed. otherwise, the default update is to be performed
            -- i.e. PC <- PC + 2
            PC_new: out std_logic_vector(15 downto 0);
            useNewPc: out std_logic;
    
            -- the new value of the register and wheter to write to it
            regNewValue: out std_logic_vector(15 downto 0);
            regToWrite: out std_logic_vector(2 downto 0);
            writeReg: out std_logic;
            
            -- writing the result to RAM, instead of register file
            RAM_Address: out std_logic_vector(15 downto 0);
            RAM_writeEnable: out std_logic;
            RAM_DataToWrite: out std_logic_vector(15 downto 0);
            
            -- used for the load instruction
            -- tells us where we have to write the result of the
            -- load instruction, or that of the ALU/branch targets
            -- '1' is for RAM, '0' is for ALU
            writeBackUseRAM_orALU: out std_logic;
            writeBackEnable: out std_logic;
            
            stallInstructionRead: out std_logic
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
    signal PC_RF, reg3Data_WB, reg3Data_Ex, PCtoRF, PCtoRF_Ex: std_logic_vector(15 downto 0) := (others => '0');
    signal reg1Data_RF, reg2Data_RF: std_logic_vector(15 downto 0);
    signal reg3Addr_WB, reg3Add_Ex: std_logic_vector(2 downto 0);
    signal regWrite_WB: std_logic := '0';
    signal clk: std_logic := '0';
    signal reset: std_logic := '0';
    signal ZF_prev, CF_prev, ZF_Ex, CF_Ex, useResult_Ex: std_logic := '0';
    signal readPC, updatePC_Ex: std_logic := '1';
    signal dataFromRAM, dataToRAM, addressOfRAM: std_logic_vector(15 downto 0) := (others => '0');
    signal writeSignalToRAM : std_logic := '0';
    signal selectSignalEx_RAM_Ex : std_logic := '0';
    signal nousesignal0 : std_logic := '0';
    signal stallInstructionRead : std_logic := '0';
    signal idkWhythisExist : std_logic := '1';

begin
    instructionMem1: instructionFetch port map(
                                clk => clk, PCtoFetch => PC_RF, 
                                instruction => instruction,
                                PCfromEx => PCtoRF_Ex,
                                PCbranchSignal_Ex => updatePC_Ex,
                                PCOutFinal => PCtoRF
    );
    instructionDecoder1: instructionDecoder port map(
                                instruction => instruction, 
                                Ra => Ra_ID, Rb => Rb_ID, Rc => Rc_ID, 
                                immediate => immediate_ID, condition => condition_ID, 
                                useComplement => useComplement_ID, opcode => opcode_ID
                                );
    regFile1: regFile port map(
                                clk => clk, 
                                regWrite => regWrite_WB, 
                                reg1Addr=> Ra_ID, reg2Addr => Rb_ID, reg3Addr => reg3Addr_WB, 
                                reg1Data => reg1Data_RF, reg2Data => reg2Data_RF, reg3Data => reg3Data_WB, 
                                PC => PC_RF, PCtoRF => PCtoRF, 
                                reset => reset, updatePC => idkWhythisExist, readPC => readPC
                                );
    exec1: execStage port map(
                                clk => clk,
                                opcode => opcode_ID,
                                Ra => Ra_ID, Rb => Rb_ID, Rc => Rb_ID,
                                RaValue => reg1Data_RF, RbValue => reg2Data_RF,
                                immediate => immediate_ID, condition => condition_ID, useComplement => useComplement_ID,
                                PC => PC_RF, PC_new => PCtoRF_Ex, useNewPc => updatePC_Ex,
                                regNewValue => reg3Data_Ex, regToWrite => reg3Add_Ex, writeReg => nousesignal0,
                                RAM_Address => addressOfRAM, RAM_writeEnable => writeSignalToRAM, RAM_DataToWrite => dataToRAM,
                                writeBackUseRAM_orALU => selectSignalEx_RAM_Ex, writeBackEnable => useResult_Ex,
                                stallInstructionRead => stallInstructionRead
                                );
    RAM1 : memory port map(
                                RAM_Address => addressOfRAM, RAM_Data_IN => dataToRAM, 
                                RAM_Data_OUT => dataFromRAM, RAM_Write => writeSignalToRAM, 
                                RAM_Clock => clk
                            );
    writeBack1: writeBack port map(
                                clk => clk, writeSignal => useResult_Ex, writeSignalOut => regWrite_WB, 
                                selectSignalEx_RAM =>selectSignalEx_RAM_Ex, writeDataIN_RAM => dataFromRAM, 
                                writeDataIN_Ex => reg3Data_Ex, writeDataOUT => reg3Data_WB, writeAddressIN => reg3Add_Ex, 
                                writeAddressOUT => reg3Addr_WB
                                );

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
                wait for 100 ns;

                --Instruction Decoder
                write(OUTPUT_LINE, to_string("Instruction: "));
                write(OUTPUT_LINE, to_bit_vector(instruction));
                write(OUTPUT_LINE, to_string(" PC: "));
                write(OUTPUT_LINE, to_bit_vector(PC_RF));
                write(OUTPUT_LINE, to_string(" PC_ALUOUT: "));
                write(OUTPUT_LINE, to_bit_vector(PCtoRF));
                writeline(OUTFILE, OUTPUT_LINE);
                clk <= not clk;
                wait for 100 ns;
                i := i + 1;
            end loop;
            wait;
        end process;
    
end Behave;
