library ieee;
use ieee.std_logic_1164.all;

entity NBitRegister is
    generic (
        N: integer
    );
    port (
        dataIn: in std_logic_vector(N-1 downto 0);
        writeEnable: in std_logic;
        clk: in std_logic;
        asyncReset: in std_logic;
        dataOut: out std_logic
    );
end entity NBitRegister;

architecture impl of NBitRegister is
    signal m_data: std_logic_vector(N-1 downto 0);
begin

    process (clk, asyncReset) begin
        if (asyncReset = '1') then 
            m_data <= (
                others => '0'
            ); -- set all the bits to 0
        elsif (rising_edge(clk)) then
            if (writeEnable = '1') then
                m_data <= dataIn;
            end if;
        end if;
    end process;
end architecture impl;