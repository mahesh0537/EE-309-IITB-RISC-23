library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_pkg.all;

-- ADI : compliment:0 op:1, condition:11
entity ALU is
    port (
        a : in std_logic_vector(15 downto 0);
        b : in std_logic_vector(15 downto 0);
        op : in std_logic;
        compliment : in std_logic;
        condition : in std_logic_vector(1 downto 0);        
        enable : in std_logic;
        zeroFlagPrevious : in std_logic;
        carryFlagPrevious : in std_logic;
        result : buffer std_logic_vector(15 downto 0);
        zeroFlag, carryFlag : out std_logic
    );
end entity ALU;

architecture rtl of ALU is
    signal tempNand : std_logic_vector(15 downto 0);
    signal tempB : std_logic_vector(15 downto 0);
    signal tempOutAdder, tempOutAdderCarry : std_logic_vector(15 downto 0);
    signal carryPastVector : std_logic_vector(15 downto 0) := (others => '0');
begin
    process(a, b, op, compliment, condition, enable, zeroFlagPrevious, carryFlagPrevious, tempB, tempNand, tempOutAdder, tempOutAdderCarry, carryPastVector)
    begin

        if enable = '1' then 
            if compliment = '1' then
                tempB <= not b;
            else
                tempB <= b;
            end if;    

            -- adder
            if op = '0' then
                tempOutAdder <= std_logic_vector(signed(a) + signed(tempB));
                if condition = "00" then
                    carryFlag <= carryFlagFinder(a(15), tempB(15), tempOutAdder(15));
                    zeroFlag <= zeroFlagFinder(tempOutAdder(15 downto 0));
                    result <= tempOutAdder(15 downto 0);
                elsif ((condition = "10") and (carryFlagPrevious = '1')) then
                    carryFlag <= carryFlagFinder(a(15), tempB(15), tempOutAdder(15));
                    zeroFlag <= zeroFlagFinder(tempOutAdder(15 downto 0));
                    result <= tempOutAdder(15 downto 0);
                elsif ((condition = "01") and (zeroFlagPrevious = '1')) then
                    carryFlag <= carryFlagFinder(a(15), tempB(15), tempOutAdder(15));
                    zeroFlag <= zeroFlagFinder(tempOutAdder(15 downto 0));
                    result <= tempOutAdder(15 downto 0);
                elsif condition = "11" then
                    carryPastVector(0) <= carryFlagPrevious;
                    tempOutAdderCarry <= std_logic_vector(signed(a) + signed(tempB) + signed(carryPastVector));
                    carryFlag <= carryFlagFinder(a(15), tempB(15), tempOutAdderCarry(15));
                    zeroFlag <= zeroFlagFinder(tempOutAdderCarry(15 downto 0));
                    result <= tempOutAdderCarry(15 downto 0);
                end if;







            -- NAND
            elsif op = '1' then
                tempNand <= not std_logic_vector(unsigned(a) and unsigned(tempB));

                -- SPL ADDER
                if condition = "11" then
                    tempOutAdder <= std_logic_vector(signed(a) + signed(tempB));
                    carryFlag <= carryFlagFinder(a(15), tempB(15), tempOutAdder(15));
                    zeroFlag <= zeroFlagFinder(tempOutAdder(15 downto 0));
                    result <= tempOutAdder(15 downto 0);
                else
                    carryFlag <= carryFlagPrevious;
                    if condition = "00" then
                        zeroFlag <= zeroFlagFinder(tempNand);
                        result <= tempNand;
                    elsif ((condition = "10") and (carryFlagPrevious = '1')) then
                        zeroFlag <= zeroFlagFinder(tempNand);
                        result <= tempNand;
                    elsif ((condition = "01") and (zeroFlagPrevious = '1')) then
                        zeroFlag <= zeroFlagFinder(tempNand);
                        result <= tempNand;
                    end if;
                end if;
            end if;





            
            
        else 
            zeroFlag <= zeroFlagPrevious;
            CarryFlag <= carryFlagPrevious;
        end if;
    end process;
end architecture rtl;
