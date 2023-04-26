library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Testbench is
end entity;
architecture Behave of Testbench is

  ----------------------------------------------------------------
  --  edit the following lines to set the number of i/o's of your
  --  DUT.
  ----------------------------------------------------------------
  constant ABitCount  : integer := 16;  -- # input bits to your design.
  constant BBitCount  : integer := 16;
  constant opBitCount : integer := 4;

  constant resultBitCount : integer := 16;  -- # output bits from your design.
  constant zBitCount  : integer  := 1;  -- # output bits from your design.
  constant nBitCount  :  integer  := 1;  -- # output bits from your design.
  ----------------------------------------------------------------
  ----------------------------------------------------------------

  -- Note that you will have to wrap your design into the DUT
  -- as indicated in class.
  component ALU is
   port(a, b : in std_logic_vector(15 downto 0);
        op : in std_logic;
        compliment : in std_logic;
        condition : in std_logic_vector(1 downto 0);        
        enable : in std_logic;
        zeroFlagPrevious : in std_logic;
        carryFlagPrevious : in std_logic;
        result : out std_logic_vector(15 downto 0);
        zeroFlag, carryFlag : out std_logic);
  end component;


    signal a_in, b_in  : std_logic_vector(ABitCount-1 downto 0);
    signal op_in : std_logic;
    signal compliment_in : std_logic;
    signal condition_in : std_logic_vector(1 downto 0);
    signal enable_in : std_logic;
    signal zeroFlagPrevious_in : std_logic;
    signal carryFlagPrevious_in : std_logic;
    signal result_out : std_logic_vector(resultBitCount-1 downto 0);
    signal zero_out, carry_out : std_logic;
  -- create a constrained string

  function to_string(x: string) return string is
      variable ret_val: string(1 to x'length);
      alias lx : string (1 to x'length) is x;
  begin  
      ret_val := lx;
      return(ret_val);
  end to_string;

  -- bit-vector to std-logic-vector and vice-versa
  function to_std_logic_vector(x: bit_vector) return std_logic_vector is
     alias lx: bit_vector(1 to x'length) is x;
     variable ret_val: std_logic_vector(1 to x'length);
  begin
     for I in 1 to x'length loop
        if(lx(I) = '1') then
          ret_val(I) := '1';
        else
          ret_val(I) := '0';
        end if;
     end loop; 
     return ret_val;
  end to_std_logic_vector;

  function to_bit_vector(x: std_logic_vector) return bit_vector is
     alias lx: std_logic_vector(1 to x'length) is x;
     variable ret_val: bit_vector(1 to x'length);
  begin
     for I in 1 to x'length loop
        if(lx(I) = '1') then
          ret_val(I) := '1';
        else
          ret_val(I) := '0';
        end if;
     end loop; 
     return ret_val;
  end to_bit_vector;

  function bit_to_std_logic(bit_val : bit) return std_logic is
    begin
      if bit_val = '0' then
        return '0';
      else
        return '1';
      end if;
    end function;

    function std_logic_to_bit(std_logic_val : std_logic) return bit is
    begin
      if std_logic_val = '0' then
        return '0';
      else
        return '1';
      end if;
    end function;

begin
  process 
    variable err_flag : boolean := false;
    File INFILE: text open read_mode is "testBench/TRACEFILEalu.txt";
    FILE OUTFILE: text  open write_mode is "testBench/outputsalu.txt";
    variable output_mask_var: bit_vector (resultBitCount-1 downto 0);
    variable output_mask_var_z: bit;
    variable output_mask_var_c: bit;

    variable input_vector_a: bit_vector (ABitCount-1 downto 0);
    variable input_vector_b: bit_vector (BBitCount-1 downto 0);
    variable input_vector_op: bit;
    variable input_vector_compliment: bit;
    variable input_vector_condition: bit_vector (1 downto 0);
    variable input_vector_enable: bit;
    variable input_vector_zeroFlagPrevious: bit;
    variable input_vector_carryFlagPrevious: bit;
    variable output_vector: bit_vector (resultBitCount-1 downto 0);
    variable output_vector_z: bit;
    variable output_vector_c: bit;
    -- for comparison of output with expected-output
    variable output_vector_comp: std_logic_vector (resultBitCount-1 downto 0);
    variable output_vector_z_comp: std_logic;
    variable output_vector_c_comp: std_logic;
    constant ZZZZout : std_logic_vector(resultBitCount-1 downto 0) := (others => '0');
    constant ZZZZoutz : std_logic := '0';
    constant ZZZZoutc : std_logic := '0';

    -- for read/write.
    variable INPUT_LINE: Line;
    variable OUTPUT_LINE: Line;
    variable LINE_COUNT: integer := 0;

    
  begin
    while not endfile(INFILE) loop 
	  -- will read a new line every 5ns, apply input,
	  -- wait for 1 ns for circuit to settle.
	  -- read output.


          LINE_COUNT := LINE_COUNT + 1;


	  -- read input at current time.
	    readLine(INFILE, INPUT_LINE);
            read(INPUT_LINE, input_vector_a);
            read(INPUT_LINE, input_vector_b);
            read(INPUT_LINE, input_vector_op);
            read(INPUT_LINE, input_vector_compliment);
            read(INPUT_LINE, input_vector_condition);
            read(INPUT_LINE, input_vector_enable);
            read(INPUT_LINE, input_vector_zeroFlagPrevious);
            read(INPUT_LINE, input_vector_carryFlagPrevious);
            read(INPUT_LINE, output_vector);
            read(INPUT_LINE, output_vector_z);
            read(INPUT_LINE, output_vector_c);
            read(INPUT_LINE, output_mask_var);
            read(INPUT_LINE, output_mask_var_z);
            read(INPUT_LINE, output_mask_var_c);
	
	  -- apply input.
            a_in <= to_std_logic_vector(input_vector_a);
            b_in <= to_std_logic_vector(input_vector_b);
            op_in <= bit_to_std_logic(input_vector_op);
            compliment_in <= bit_to_std_logic(input_vector_compliment);
            condition_in <= to_std_logic_vector(input_vector_condition);
            enable_in <= bit_to_std_logic(input_vector_enable);
            zeroFlagPrevious_in <= bit_to_std_logic(input_vector_zeroFlagPrevious);
            carryFlagPrevious_in <= bit_to_std_logic(input_vector_carryFlagPrevious);





	  -- wait for the circuit to settle 
	  -- wait for 10 ns;
	  wait for 20 ns;

	  -- check output.
      output_vector_comp   := (to_std_logic_vector(output_mask_var)   and (to_std_logic_vector(output_vector)   xor result_out));
      output_vector_z_comp := (bit_to_std_logic(output_mask_var_z) and (bit_to_std_logic(output_vector_z) xor zero_out));
      output_vector_c_comp := (bit_to_std_logic(output_mask_var_c) and (bit_to_std_logic(output_vector_c) xor carry_out));
          if (output_vector_comp /= ZZZZout) then
             write(OUTPUT_LINE,to_string("ERROR: line "));
             write(OUTPUT_LINE, LINE_COUNT);
             writeline(OUTFILE, OUTPUT_LINE);
             err_flag := true;
          end if;
          if (output_vector_z_comp /= ZZZZoutz) then
             write(OUTPUT_LINE,to_string("ERROR: line "));
             write(OUTPUT_LINE, LINE_COUNT);
             writeline(OUTFILE, OUTPUT_LINE);
             err_flag := true;
          end if;
          if (output_vector_c_comp /= ZZZZoutc) then
             write(OUTPUT_LINE,to_string("ERROR: line "));
             write(OUTPUT_LINE, LINE_COUNT);
             writeline(OUTFILE, OUTPUT_LINE);
             err_flag := true;
          end if;
        --   write(OUTPUT_LINE, to_bit_vector(input_vector));
        --   write(OUTPUT_LINE, to_string(" "));
        --   write(OUTPUT_LINE, to_bit_vector(output_vector));
        --   writeline(OUTFILE, OUTPUT_LINE);
        write(OUTPUT_LINE, input_vector_a);
        write(OUTPUT_LINE, to_string(" "));
        write(OUTPUT_LINE, input_vector_b);
        write(OUTPUT_LINE, to_string(" "));
        write(OUTPUT_LINE, input_vector_op);
        write(OUTPUT_LINE, to_string(" "));
        write(OUTPUT_LINE, input_vector_compliment);
        write(OUTPUT_LINE, to_string(" "));
        write(OUTPUT_LINE, input_vector_condition);
        write(OUTPUT_LINE, to_string(" "));
        write(OUTPUT_LINE, input_vector_enable);
        write(OUTPUT_LINE, to_string(" "));
        write(OUTPUT_LINE, input_vector_zeroFlagPrevious);
        write(OUTPUT_LINE, to_string(" "));
        write(OUTPUT_LINE, input_vector_carryFlagPrevious);
        write(OUTPUT_LINE, to_string(" "));
        write(OUTPUT_LINE, to_bit_vector(result_out));
        write(OUTPUT_LINE, to_string(" "));
        write(OUTPUT_LINE, std_logic_to_bit(zero_out));
        write(OUTPUT_LINE, to_string(" "));
        write(OUTPUT_LINE, std_logic_to_bit(carry_out));
        writeline(OUTFILE, OUTPUT_LINE);


	  -- advance time by 4 ns.
	  -- wait for 4 ns;
	  wait for 20 ns;
    end loop;

    assert (err_flag) report "SUCCESS, all tests passed." severity note;
    assert (not err_flag) report "FAILURE, some tests failed." severity error;

    wait;
  end process;

  dut_instance: ALU 
     	port map(
            a => a_in,
            b => b_in,
            op => op_in,
            compliment => compliment_in,
            condition => condition_in,
            enable => enable_in,
            zeroFlagPrevious => zeroFlagPrevious_in,
            carryFlagPrevious => carryFlagPrevious_in,
            result => result_out,
            zeroFlag => zero_out,
            carryFlag => carry_out);

end Behave;
