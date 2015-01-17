library IEEE;
use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_LIB.all;

package EX_MEM_PKG is
	-- Record for one way conectio (EX --> MEM)
	type EX_MEM_RCD is record
		opcode		: OPCODE_TYPE;
		pc 			: REG_TYPE;
		alu_out		: REG_TYPE;
		dst	: REG_TYPE;
	end record;
	
	type MEMPHASE_DATACACHE_RCD is record
		control		: DATA_CONTROL_TYPE;
		address		: ADDR_TYPE;
		dataIn		: WORD_TYPE;
	end record;
	
	type DATACACHE_MEMPHASE_RCD is record
		dataOut		: REG_TYPE;
	end record;
	
end package EX_MEM_PKG;

package body EX_MEM_PKG is
end package body EX_MEM_PKG;