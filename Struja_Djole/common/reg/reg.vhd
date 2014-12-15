library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_LIB.all;

-- input : input bus of the register
-- clk : clock signal input
-- output : output bus of the register

entity REG is
	port
	(
		-- Inout ports
		input	: in REG_TYPE;
		clk 	: in STD_LOGIC;

		-- Output ports
		output	: out REG_TYPE
	);
end REG;

architecture RLT of REG is
begin
	process (clk) 
	begin
		if (rising_edge(clk)) then
			output <= input;
		end if;
	end process;
end architecture;


