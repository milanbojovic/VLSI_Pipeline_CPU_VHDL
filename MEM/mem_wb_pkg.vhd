library IEEE;
use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_LIB.all;

package MEM_WB_PKG is
	-- Record for one way conection(MEM --> WB)
	type MEM_WB_RCD is record
		opcode 	: OPCODE_TYPE;
		alu_out	: REG_TYPE;
		lmd		: REG_TYPE;
		dst		: REG_TYPE;
		pc			: REG_TYPE;
	end record;
	
end package MEM_WB_PKG;

package body MEM_WB_PKG is
end package body MEM_WB_PKG;