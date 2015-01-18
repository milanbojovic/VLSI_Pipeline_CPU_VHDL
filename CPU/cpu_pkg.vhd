--- CPU Package ---
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_LIB.all;

package CPU_PKG is
	
	-- Record CLOCK, RESET, LOAD, STALL
	type CRLS_RCD is record
		clk		: STD_LOGIC;
		reset		: STD_LOGIC;
		load 		: STD_LOGIC;
		stall 	: STD_LOGIC;
	end record;
	
	
	-- Record for one way conection (IF --> ID)
	type IF_ID_RCD is record
		pc 	: REG_TYPE;
		ir1	: REG_TYPE;
		ir2	: REG_TYPE;
	end record;

	
	-- Record for one way conectio (ID --> EX)
	type ID_EX_RCD is record
		opcode 			: OPCODE_TYPE;
		pc					: REG_TYPE;
		a, b				: REG_TYPE;
		immediate		: REG_TYPE;
		branch_offset	: REG_TYPE;
		dst				: REG_TYPE;		
	end record;
	
	
	-- Record for one way conection (EX --> IF)
	type EX_IF_RCD is record
		pc				: REG_TYPE;
		branch_cond	: SIGNAL_BIT_TYPE;
	end record;
	
	
	-- Record for one way conectio (EX --> MEM)
	type EX_MEM_RCD is record
		opcode		: OPCODE_TYPE;
		pc 			: REG_TYPE;
		alu_out		: REG_TYPE;
		dst	: REG_TYPE;
	end record;
	
	
	-- Record for one way conection(MEM --> WB)
	type MEM_WB_RCD is record
		opcode 	: OPCODE_TYPE;
		alu_out	: REG_TYPE;
		lmd		: REG_TYPE;
		dst		: REG_TYPE;
		pc			: REG_TYPE;
	end record;
	
	
	-- Record for one way conection(WB --> ID)
	type WB_ID_RCD is record
		data				: REG_TYPE;
		reg_adr			: REG_TYPE;
		write_enable	: SIGNAL_BIT_TYPE;
	end record;
	
	
	
	
	
	
	
	
	
	-- DATA CACHE RECORDS
	-- Record for one way connection of Mem phase with Data Cache(MEM_PHASE -> DATA_CACHE)
	type MEMPHASE_DATACACHE_RCD is record
		control		: DATA_CONTROL_TYPE;
		address		: ADDR_TYPE;
		dataIn		: WORD_TYPE;
	end record;
	
	
	-- Record for one way connection of Mem phase with Data Cache (DATA_CACHE -> MEM_PHASE)
	type DATACACHE_MEMPHASE_RCD is record
		dataOut		: REG_TYPE;
	end record;
	
	
	-- INSTRUCTION CACHE RECORDS
	-- Record for one way connection of If phase with Instruction Cache(IF_PHASE -> INSTR_CACHE)
	type IFPHASE_INSTCACHE_RCD is record
		address1 	: ADDR_TYPE;
		address2 	: ADDR_TYPE;
		control		: INSTR_CONTROL_TYPE;
	end record;
	
	
	-- Record for one way connection of If phase with Instruction Cache(INSTR_CACHE -> IF_PHASE)
	type INSTCACHE_IFPHASE_RCD is record
		data1		: WORD_TYPE;
		data2		: WORD_TYPE;
	end record;	
	
end package CPU_PKG;

package body CPU_PKG is
end package body CPU_PKG;
