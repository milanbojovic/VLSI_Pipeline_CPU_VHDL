library IEEE;
use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_LIB.all;

package ID_EX_PKG is
	-- Record for one way conectio (EX --> MEM)
	type ID_EX_RCD is record
		opcode 			: OPCODE_TYPE;
		pc					: REG_TYPE;
		a, b				: REG_TYPE;
		immediate		: REG_TYPE;
		branch_offset	: REG_TYPE;
		dst			: REG_TYPE;		
		--sel				: SIGNAL_BIT_TYPE;
	end record;

end package ID_EX_PKG;

package body ID_EX_PKG is
end package body ID_EX_PKG;