--IF Phase--
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_LIB.all;

entity IF_PHASE is
	port
	(	
		-- Input ports
		clk		: STD_LOGIC;
		reset		: STD_LOGIC;
		load 		: STD_LOGIC;
		stall 	: STD_LOGIC;
		
		-- EX_PHASE
		ex_pc					: REG_TYPE;
		ex_branch_cond 	: STD_LOGIC := '0'
				
		-- Output ports

		
	);
end IF_PHASE;



-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture arch of IF_PHASE is

begin
		i1 : INSTRUCTION_CACHE
		instr_cache : entity work.INSTRUCTION_CACHE(arch) port map (a,b,c,d,outer_component_output_signal);

end arch;
