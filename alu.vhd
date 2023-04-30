library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
	port (
		-- inputs for the ALU
		A, B: in std_logic_vector(15 downto 0);
		carryIn: in std_logic;

		-- '0' for ADD and '1' for NAND
		op: std_logic;
		
		-- results of the operation
		result: out std_logic_vector(15 downto 0);
		ZF, CF: out std_logic
	);
end entity ALU;

architecture struct of ALU is
signal m_A, m_B: std_logic_vector(16 downto 0);
signal m_nandResult: std_logic_vector(16 downto 0);
signal m_addResult: std_logic_vector(16 downto 0);
signal m_carryVector: std_logic_vector(16 downto 0);
signal m_finalResult: std_logic_vector(16 downto 0);
begin
	
	m_carryVector <= "0000000000000000" & carryIn;
	
	-- we want to generate carry flags from the addition
	-- if we use A and B directly, the result is not resized into 17 bits
	m_A <= '0' & A;
	m_B <= '0' & B;
	
	m_addResult <= std_logic_vector(unsigned(m_A) + unsigned(m_B) + unsigned(m_carryVector));
   m_nandResult <= carryIn & (A nand B);
	m_finalResult <= 	m_addResult when op = '0' else m_nandResult;
	
	ZF <= '1' when (m_finalResult(15 downto 0) = "0000000000000000") else '0';
	CF <= m_finalResult(16);
	
	result <= m_finalResult(15 downto 0);
end architecture struct;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_wrapper is
	port (
		-- inputs to be forwarded to the ALU
		-- the exact operation performed is dependent on the opcode
		-- see the doc for more details
		A, B: in std_logic_vector(15 downto 0);
		opcode: in std_logic_vector(3 downto 0);
		condition: in std_logic_vector(1 downto 0);
		compliment: in std_logic;
		ZF_prev, CF_prev: in std_logic;
		
		-- results of the operation
		result: out std_logic_vector(15 downto 0);
		ZF, CF: out std_logic;
		useResult: out std_logic
	);
end entity ALU_wrapper;

architecture struct of ALU_wrapper is

component ALU is
	port (
		A, B: in std_logic_vector(15 downto 0);
		carryIn: in std_logic;
		op: in std_logic;

		result: out std_logic_vector(15 downto 0);
		ZF, CF: out std_logic
	);
end component ALU;

signal ALU_op: std_logic_vector(1 downto 0);
signal ALU_A, ALU_B: std_logic_vector(15 downto 0);
signal ALU_carryIn: std_logic;

-- '0' is for ADD, '1' is for NAND
signal m_toPerformAddOrNand: std_logic;
signal m_useCarry: std_logic;
begin

	ALU_A <= A;
	ALU_B <= B when compliment = '0' else not B;
	
	ALU_carryIn <= CF_prev when ((opcode = "0001" and condition = "11") or
										  (opcode = "0010")) else '0';
	
	with opcode select
		m_toPerformAddOrNand <= '0' when "0000" | "0001", 
										'1' when others;
		
	ALU_instance: ALU
		port map(
			A => ALU_A,
			B => ALU_B,
			carryIn => ALU_carryIn,
			op => m_toPerformAddOrNand,
			result => result,
			ZF => ZF,
			CF => CF
		);

	useresult <=	'1' when (opcode = "0001" and (
										(condition = "00") or 							-- ada and aca
										(condition = "01" and ZF_prev = '1') or	-- adz and acz
										(condition = "10" and CF_prev = '1') or	-- adc and acc
										(condition = "11")								-- acw and awc
									)) or 
									(opcode = "0000") or									-- aci
									(opcode = "0010" and (
										(condition = "00") or							-- ndu and ncu
										(condition = "10" and CF_prev = '1') or	-- ndc and ncc
										(condition = "01" and ZF_prev = '1')		-- ndz and ncz
									)) else '0';

end architecture struct;