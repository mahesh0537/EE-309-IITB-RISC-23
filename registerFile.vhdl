library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity regFile is 
port(
    clk : in std_logic;
    regWrite : in std_logic;
    reg1Addr, reg2Addr, reg3Addr : in std_logic_vector(2 downto 0);
    reg1Data, reg2Data, PC : out std_logic_vector(15 downto 0);
    reg3Data, PCtoRF : in std_logic_vector(15 downto 0);
    reset : in std_logic;
    updatePC : in std_logic;
    readPC : in std_logic   --toggle to read PC, anytime
);
end regFile;

architecture regFile_arch of regFile is
    type regFileType is array (0 to 7) of std_logic_vector(15 downto 0);
    signal regFile : regFileType := (others => (others => '0'));
    
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            if regWrite = '1' then
                regFile(to_integer(unsigned(reg3Addr))) <= reg3Data;
            end if;
            if updatePC = '1' then
                regFile(0) <= PCtoRF;
            end if;
        end if;
    end process;

    process(reset)
    begin
        if reset = '1' then
            regFile <= (others => (others => '0'));
        end if;
    end process;

    
        reg1Data <= regFile(to_integer(unsigned(reg1Addr)));
        reg2Data <= regFile(to_integer(unsigned(reg2Addr)));
        PC <= regFile(0);

    -- process(readPC)
    -- begin
    --         PC <= regFile(0);
    -- end process;
end regFile_arch;