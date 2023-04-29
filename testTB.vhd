library ieee;
use ieee.std_logic_1164.all;

entity my_entity_tb is
end entity my_entity_tb;

architecture sim of my_entity_tb is
  signal a : std_logic_vector(7 downto 0) := "10101010";
  signal b : std_logic_vector(7 downto 0);

  component my_entity is
    port (
      a : in  std_logic_vector(7 downto 0);
      b : out std_logic_vector(7 downto 0)
    );
  end component;

begin
  uut: my_entity port map (
    a => a,
    b => b
  );

  process
  begin
    -- wait for some time before changing the input
    wait for 10 ns;

    -- change the input value
    a <= "11001100";

    -- wait for some time before checking the output
    wait for 10 ns;

    -- check the output value
    assert b = "11001100"
      report "Output value is incorrect"
      severity error;

    -- wait for some time before ending the simulation
    wait for 10 ns;

    -- end the simulation
    wait;
  end process;
end architecture sim;
