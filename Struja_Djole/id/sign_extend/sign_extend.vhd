library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use WORK.CPU_LIB.all;

entity SIGN_EXTEND is
	port
	(
		a : in IMMIDIATE_TYPE;
		result : out REG_TYPE
	);
end SIGN_EXTEND;

architecture RTL of SIGN_EXTEND is 
begin 
	process(a)
    begin
        if (a(15) = '1') then 
            result <= MAX_16 & a;
        elsif(a(15) = '0') then 
            result <= ZERO_16 & a;
        else
            result <= UNDEFINED_16 & a;
        end if;
    end process;
end RTL;