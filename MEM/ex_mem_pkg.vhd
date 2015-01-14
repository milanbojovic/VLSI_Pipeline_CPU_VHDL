library IEEE;
use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_LIB.all;

package EX_MEM_PKG is
	-- Record for one way conectio (EX --> MEM)
	type EX_MEM_RCD is record
		opcode		: OPCODE_TYPE;
		pc 			: REG_TYPE;
		alu_out		: REG_TYPE;
		--cond 			: SIGNAL_BIT_TYPE;
		dst	: REG_TYPE;
	end record;

end package EX_MEM_PKG;

package body EX_MEM_PKG is
end package body EX_MEM_PKG;