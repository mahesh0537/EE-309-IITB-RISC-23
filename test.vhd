library ieee;
use ieee.std_logic_1164.all;

entity my_entity is
  port (
    a : in  std_logic_vector(7 downto 0);
    b : out std_logic_vector(7 downto 0)
  );
end entity my_entity;

architecture rtl of my_entity is
  signal tempA : std_logic_vector(7 downto 0);
begin
  tempA <= a; -- assign input a to signal tempA
  b <= tempA; -- assign signal tempA to output b
end architecture rtl;
