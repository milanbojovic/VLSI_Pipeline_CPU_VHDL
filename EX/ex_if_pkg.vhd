library ieee;
use ieee.std_logic_1164.all;
use WORK.CPU_LIB.all;

package EX_IF_PKG is
	-- Record for one way conection (IF --> ID)
	type EX_IF_RCD is record
		pc				: REG_TYPE;
		branch_cond	: MUX_SELECT_TYPE;
	end record;

end package EX_IF_PKG;

package body EX_IF_PKG is
end package body EX_IF_PKG;