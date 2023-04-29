library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registerFetch is
	port (
		-- data of all the registers
		registerData: in std_logic_vector(8*16-1 downto 0);
		
		-- the registers whose value we want to read
		regA, regB: in std_logic_vector(2 downto 0);
		
		-- the data of the corresponding registers
		regA_data, regB_data: out std_logic_vector(15 downto 0)
	);
end entity registerFetch;

architecture impl of registerFetch is
signal regA_val_start, regA_val_end, regB_val_start, regB_val_end: unsigned(6 downto 0);
begin
	regA_val_start <= unsigned(regA)*16+15;
	regB_val_start <= unsigned(regA)*16+15;
	regA_val_end <= unsigned(regA)*16;
	regB_val_end <= unsigned(regA)*16;

	regA_data <= registerData(to_integer(regA_val_end) downto to_integer(regA_val_start));
	regB_data <= registerData(to_integer(regB_val_end) downto to_integer(regA_val_start));
	
end architecture impl;