library ieee;
use ieee.std_logic_1164.all;

entity RF_TB is
end RF_TB;

architecture whatever of RF_TB is
    component regFile is
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
    end component;
    signal clk : std_logic := '0';
    signal regWrite : std_logic := '0';
    signal reg1Addr, reg2Addr, reg3Addr : std_logic_vector(2 downto 0) := "000";
    signal reg1Data, reg2Data, PC : std_logic_vector(15 downto 0) := (others => '0');
    signal reg3Data, PCtoRF : std_logic_vector(15 downto 0) := (others => '1');
    signal reset : std_logic := '0';
    signal updatePC : std_logic := '0';
    signal readPC : std_logic := '0';
    signal PCout : std_logic_vector(15 downto 0);
    signal PCin : std_logic_vector(15 downto 0);


    begin
    regFile1 : regFile port map(
        clk => clk,
        regWrite => regWrite,
        reg1Addr => reg1Addr, reg2Addr => reg2Addr, reg3Addr => reg3Addr,
        reg1Data => reg1Data, reg2Data => reg2Data, reg3Data => reg3Data,
        PC => PCout, PCtoRF => PCtoRF,
        reset => reset,
        updatePC => updatePC,
        readPC => readPC
    );

    process
    variable i : integer := 0;
    begin
        while i < 10 loop
            wait for 10 ns;
            clk <= not clk;
            i := i + 1;
            updatePC <= '1';
            regWrite <= not regWrite;
        end loop;
    end process;
        end architecture;