library ieee;
use ieee.std_logic_1164.all;

entity instructionMemory_tb is
end entity instructionMemory_tb;

architecture testbench of instructionMemory_tb is
    -- import entity
    component instructionMemory is
        port (
            address : in std_logic_vector(15 downto 0);
            instruction : out std_logic_vector(15 downto 0)
        );
    end component;

    -- signals
    signal clk : std_logic := '0';
    signal address : std_logic_vector(15 downto 0) := (others => '0');
    signal instruction : std_logic_vector(15 downto 0);

begin
    -- instantiate the entity
    uut : instructionMemory
        port map (
            address => address,
            instruction => instruction
        );

    -- generate clock

    -- test stimulus
    process
    begin
        address <= "0000000000000000";  -- load instruction at address 0
        wait for 20 ns;
        assert instruction = "1111111111111111"
            report "Instruction read error at address 0" severity error;
        
        address <= "0000000000000010";  -- load instruction at address 2
        wait for 20 ns;
        assert instruction = "1111111111111111"
            report "Instruction read error at address 2" severity error;
        
        address <= "0000000000000011";  -- load instruction at address 3
        wait for 20 ns;
        assert instruction = "1111111111111111"
            report "Instruction read error at address 3" severity error;
        
        wait;
    end process;

    -- clock driver

end architecture testbench;
