library ieee;
use ieee.std_logic_1164.all;

entity writeBack is
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
end entity;

architecture arch of writeBack is
    component mux2 is
        port (
            data0, data1 : in std_logic_vector(15 downto 0);
            sel : in std_logic;
            data_out : out std_logic_vector(15 downto 0)
    );
    end component;
signal writeDataIN : std_logic_vector(15 downto 0);
begin
    mux2_ExRAM : mux2 port map(writeDataIN_Ex, writeDataIN_RAM, selectSignalEx_RAM, writeDataIN);
    process(clk, writeSignal, writeDataIN_RAM, writeDataIN_Ex, writeAddressIN)
    begin
        -- if rising_edge(clk) then
            if writeSignal = '1' then
                writeDataOUT <= writeDataIN;
                writeAddressOUT <= writeAddressIN;
            end if;
            writeSignalOut <= writeSignal;
        -- end if;
    end process;
end arch;