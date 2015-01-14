library IEEE;
use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_LIB.all;

package EX_IF_PKG is
	-- Record for one way conection (IF --> ID)
	type EX_IF_RCD is record
		pc				: REG_TYPE;
		branch_cond	: SIGNAL_BIT_TYPE;
	end record;
	
--	type CSR_RCD is record
--		n : STD_LOGIC ;
--		c : STD_LOGIC ;
--		v : STD_LOGIC ;
--		z : STD_LOGIC ;
--	end record;

end package EX_IF_PKG;

package body EX_IF_PKG is
end package body EX_IF_PKG;