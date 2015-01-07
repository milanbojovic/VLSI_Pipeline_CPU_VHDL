library ieee;
use ieee.std_logic_1164.all;
use WORK.CPU_LIB.all;

package IF_ID_PKG is
	-- Record for one way conection (IF --> ID)
	type IF_ID_RCD is record
		pc 	: REG_TYPE;
		ir		: REG_TYPE;
	end record;

end package IF_ID_PKG;

package body IF_ID_PKG is
end package body IF_ID_PKG;
