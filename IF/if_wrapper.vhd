-- IF Phase WRAPPER --
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
use IEEE.STD_LOGIC_ARITH.all;

entity IF_WRAPPER is
	port
	(
		--Clock, Reset, Load, Store
		record_in_crls 		: in CRLS_RCD;	
		
		-- EX_PHASE
		ex_record_if			: in EX_IF_RCD;
				
		-- Output to ID phase
		if_record_id			: out IF_ID_RCD
	);
end IF_WRAPPER;

architecture arch of IF_WRAPPER is
		-- INSTRUCTION CACHE CONNECTIONS
	signal sig_if_record_instr_cache	: IFPHASE_INSTCACHE_RCD;
	signal sig_instr_cache_record_if	: INSTCACHE_IFPHASE_RCD;
	
begin
		COMP_IF_PHASE  : entity work.IF_PHASE(arch)			 	port map (record_in_crls, ex_record_if, if_record_id, sig_if_record_instr_cache, sig_instr_cache_record_if);
		COMP_INST_CACHE: entity work.INSTRUCTION_CACHE(arch) 	port map (record_in_crls, sig_if_record_instr_cache, sig_instr_cache_record_if);
end arch;

