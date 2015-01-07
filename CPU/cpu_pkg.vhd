--- CPU Package ---
library ieee;
use ieee.std_logic_1164.all;

package CPU_PKG is
	-- Record CLOCK, RESET, LOAD, STALL
	type CRLS_RCD is record
		clk		: STD_LOGIC;
		reset		: STD_LOGIC;
		load 		: STD_LOGIC;
		stall 	: STD_LOGIC;
	end record;

end package CPU_PKG;

package body CPU_PKG is
end package body CPU_PKG;
