library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use WORK.CPU_LIB.all;
	
entity MUX_2_IN_1 is
	port
	(
		-- Input ports
		a	: in  REG_TYPE;
		b	: in  REG_TYPE;
		sel: in  std_logic;

		-- Output ports
		z	: out REG_TYPE
	);
end MUX_2_IN_1;


architecture BEH of MUX_2_IN_1 is
begin

	process(a, b, sel) is 
	begin
		if(sel = '0') then
			z <= a;
		elsif(sel = '1') then
			z <= b;
		else z <= UNDEFINED_32;
		end if;
	end process; 
end architecture BEH;





