library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity execStage is
	port(
		clk: in std_logic;
	
		opcode: in std_logic_vector(3 downto 0);
		Ra, Rb, Rc: in std_logic_vector(2 downto 0);
		RaValue, RbValue: in std_logic_vector(15 downto 0);
		immediate: in std_logic_vector(15 downto 0);
		condition: in std_logic_vector(1 downto 0);
		useComplement: in std_logic;
		PC: in std_logic_vector(15 downto 0);
		
		-- this PC is to be used when a branch instruction is
		-- executed. otherwise, the default update is to be performed
		-- i.e. PC <- PC + 2
		PC_new: out std_logic_vector(15 downto 0);
		useNewPc: out std_logic;

		-- the new value of the register and wheter to write to it
		regNewValue: out std_logic_vector(15 downto 0);
		regToWrite: out std_logic_vector(2 downto 0);
		writeReg: out std_logic;
		
		-- writing the result to RAM, instead of register file
		RAM_Address: out std_logic_vector(15 downto 0);
		RAM_writeEnable: out std_logic;
		RAM_DataToWrite: out std_logic_vector(15 downto 0);
		
		-- used for the load instruction
		-- tells us where we have to write the result of the
		-- load instruction, or that of the ALU/branch targets
		-- '1' is for RAM, '0' is for ALU
		writeBackUseRAM_orALU: out std_logic;
		writeBackEnable: out std_logic;
		
		stallInstructionRead: out std_logic
	);
end entity execStage;

architecture impl of execStage is
component ALU_wrapper is
	port (
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
end component ALU_wrapper;

component conditionalBranchHandler is
	port (
		opcode: in std_logic_vector(3 downto 0);
		Ra, Rb: in std_logic_vector(15 downto 0);
		imm: in std_logic_vector(15 downto 0);
		PC: in std_logic_vector(15 downto 0);
		
		PC_new: out std_logic_vector(15 downto 0);
		useNewPc: out std_logic
	);
end component conditionalBranchHandler;

component unconditionalBranchHandler is
	port(
		opcode: in std_logic_vector(3 downto 0);
		PC: in std_logic_vector(15 downto 0);
		Ra, Rb, immediate: in std_logic_vector(15 downto 0);

		RA_new: out std_logic_vector(15 downto 0);
		PC_new: out std_logic_vector(15 downto 0);
		useNewPc, useNewRa: out std_logic
	);
end component unconditionalBranchHandler;

component loadStoreHandler
	port(
		opcode: in std_logic_vector(3 downto 0);
		Ra, Rb, Rc: in std_logic_vector(2 downto 0);
		RaValue, RbValue: in std_logic_vector(15 downto 0);
		immediate: in std_logic_vector(15 downto 0);
		ALU_result: in std_logic_vector(15 downto 0);
		ALU_resutWriteEnable: in std_logic;
		
		RAM_Address: out std_logic_vector(15 downto 0);
		RAM_writeEnable: out std_logic;
		RAM_DataToWrite: out std_logic_vector(15 downto 0);
		writeBackUseRAM_orALU: out std_logic;
		writeBackEnable: out std_logic
	);
end component loadStoreHandler;

signal ALU_ZF, ALU_CF: std_logic;
signal ALU_result: std_logic_vector(15 downto 0);
signal ALU_useResult: std_logic;
signal ALU_A, ALU_B: std_logic_vector(15 downto 0);

signal m_ZeroFlag: std_logic := '0';
signal m_CarryFlag: std_logic := '0';

-- CB is conditional Branch, UCB is unconditional branch
signal CB_PC_new, UCB_PC_new: std_logic_vector(15 downto 0);
signal CB_useNewPC, UCB_useNewPC: std_logic;
signal UCB_useNewRa: std_logic;
signal UCB_RA_new: std_logic_vector(15 downto 0);

signal PC_plus2: std_logic_vector(15 downto 0);
begin
	
	ALU_A <= RaValue;
	ALU_B <= RbValue when (opcode = "0001" or opcode = "0010") else
				immediate; --when (opcode = "0000")
	
	ALU_wrapperInstance: ALU_wrapper
		port map (
			A => ALU_A,
			B => ALU_B,
			opcode => opcode,
			condition => condition,
			ZF_prev => m_ZeroFlag,
			CF_prev => m_CarryFlag,
			compliment => useComplement,
			
			result => ALU_result,
			ZF => ALU_ZF,
			CF => ALU_CF,
			useResult => ALU_useResult
		);
	
	UCBH_instance: unconditionalBranchHandler
		port map (
			opcode => opcode,
			PC => PC,
			Ra => RaValue,
			Rb => RbValue,
			immediate => immediate,
			
			Ra_new => UCB_RA_new,
			PC_new => UCB_PC_new,
			useNewPc => UCB_useNewPC,
			useNewRa => UCB_useNewRa
		);
	
	CBH_instance: conditionalBranchHandler
		port map (
			opcode => opcode,
			Ra => RaValue,
			Rb => RbValue,
			imm => immediate,
			PC => PC,
			
			PC_new => CB_PC_new,
			useNewPc => CB_useNewPC
		);
	
	LSH_instance: loadStoreHandler
		port map(
			opcode => opcode,
			Ra => Ra,
			Rb => Rb,
			Rc => Rc,
			RaValue => RaValue,
			RbValue => RbValue,
			immediate => immediate,
			ALU_result => ALU_result,
			ALU_resutWriteEnable => ALU_useResult,
			RAM_Address => RAM_Address,
			RAM_writeEnable => RAM_writeEnable,
			RAM_DataToWrite => RAM_DataToWrite,
			writeBackUseRAM_orALU => writeBackUseRAM_orALU,
			writeBackEnable => writeBackEnable
		);
	process (clk) begin
		if rising_edge(clk) then
			if (ALU_useResult = '1') then
				m_ZeroFlag <= ALU_ZF;
				m_CarryFlag <= ALU_CF;
				regNewValue <= ALU_result;
				regToWrite <= Rc;
				writeReg <= '1';
				
				-- default pc increment, done in instruction
				-- fetch stage. write dummy value for now
				PC_new <= "0000000000000000";
				useNewPc <= '0';
			elsif (CB_useNewPC = '1') then
				-- flags are not modified
			
				PC_new <= CB_PC_new;
				useNewPc <= '1';
				
				-- none of the conditional branch instructions
				-- modify registers. write a dummy value for now
				regNewValue <= "0000000000000000";
				regToWrite <= "111";
				writeReg <= '0';
			elsif (UCB_useNewPC = '1') then
				-- flags are not modified
				PC_new <= UCB_PC_new;
				useNewPc <= UCB_useNewPC;
				
				-- jal and jlr write to a register
				regNewValue <= UCB_RA_new;
				regToWrite <= Ra;
				writeReg <= UCB_useNewRa;
				
			else
				-- nothing is updated
				PC_new <= "0000000000000000";
				useNewPc <= '0';
				regNewValue <= "0000000000000000";
				regToWrite <= "111";
				writeReg <= '0';
 			end if;
		end if;
	end process;
	
	-- will use later when pipelining
	stallInstructionRead <= '0';
end architecture impl;