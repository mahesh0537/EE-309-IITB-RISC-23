library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ADI : compliment:0 op:1, condition:11
entity ALU is
    port (
        a, b : in std_logic_vector(15 downto 0);
        op : in std_logic;
        compliment : in std_logic;
        condition : in std_logic_vector(1 downto 0);        
        enable : in std_logic;
        zeroFlagPrevious : in std_logic;
        carryFlagPrevious : in std_logic;
        result : out std_logic_vector(15 downto 0);
        zeroFlag, carryFlag : out std_logic
    );
end entity ALU;

architecture rtl of ALU is
    signal tempNand, tempB : std_logic_vector(15 downto 0);
    signal tempOutAdder, tempOutAdderCarry : std_logic_vector(16 downto 0);
    signal carryPastVector : std_logic_vector(0 downto 0);
    function zeroFlagFinder(a : std_logic_vector(15 downto 0)) return std_logic is
    begin
        if a = "0000000000000000" then
            return '1';
        else
            return '0';
        end if;
    end function zeroFlagFinder;
begin
    process(a, b, op)
    begin

        if enable = '1' then 
            if compliment = '1' then
                tempB <= not b;
            else
                tempB <= b;
            end if;
            
            -- adder
            if op = '0' then
                tempOutAdder <= std_logic_vector(unsigned('0' & a) + unsigned('0' & tempB));
                if condition = "00" then
                    carryFlag <= tempOutAdder(16);
                    zeroFlag <= zeroFlagFinder(tempOutAdder(15 downto 0));
                    result <= tempOutAdder(15 downto 0);
                elsif ((condition = "10") and (carryFlagPrevious = '1')) then
                    carryFlag <= tempOutAdder(16);
                    zeroFlag <= zeroFlagFinder(tempOutAdder(15 downto 0));
                    result <= tempOutAdder(15 downto 0);
                elsif ((condition = "01") and (zeroFlagPrevious = '1')) then
                    carryFlag <= tempOutAdder(16);
                    zeroFlag <= zeroFlagFinder(tempOutAdder(15 downto 0));
                    result <= tempOutAdder(15 downto 0);
                elsif condition = "11" then
                    carryPastVector(0) <= carryFlagPrevious;
                    tempOutAdderCarry <= std_logic_vector(unsigned(tempOutAdder) + unsigned(carryPastVector));
                    carryFlag <= tempOutAdderCarry(16);
                    zeroFlag <= zeroFlagFinder(tempOutAdder(15 downto 0));
                    result <= tempOutAdderCarry(15 downto 0);
                end if;







            -- NAND
            elsif op = '1' then
                tempNand <= not std_logic_vector(unsigned(a) and unsigned(tempB));

                -- SPL ADDER
                if condition = "11" then
                    tempOutAdder <= std_logic_vector(signed('0' & a) + signed('0' & tempB));
                    carryFlag <= tempOutAdder(16);
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
