library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

use WORK.CPU_LIB.all;

entity ADDER is
	port(
		-- Input port
		input: in REG_TYPE;
		
		-- Output port
		output: out REG_TYPE
	);
end entity ADDER;

architecture BHV of ADDER is
begin
	process(input) is
	begin
		output <= signed(input) + 1;
	end process;
end architecture BHV;