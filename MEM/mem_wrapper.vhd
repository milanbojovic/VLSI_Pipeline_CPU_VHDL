--IF Phase--
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
use IEEE.STD_LOGIC_ARITH.all;

entity MEM_WRAPPER is
	port
	(	
		-- Input ports
		record_in_crls 		: in CRLS_RCD;	--Clock, Reset, Load, Store
		
		-- EX_Phase
		ex_record_mem			: in EX_MEM_RCD;
				
		-- WB Phase
		mem_record_wb			: out MEM_WB_RCD
	);
end MEM_WRAPPER;

architecture arch of MEM_WRAPPER is
	signal sig_mem_record_data_cache	: MEMPHASE_DATACACHE_RCD;
	signal sig_data_cache_record_mem	: DATACACHE_MEMPHASE_RCD;
begin
		COMP_MEM_PHASE : entity work.MEM_PHASE(arch) 	port map (record_in_crls, ex_record_mem, mem_record_wb, sig_mem_record_data_cache, sig_data_cache_record_mem);
		COMP_DATA_CACHE: entity work.DATA_CACHE(arch) 	port map (record_in_crls, sig_mem_record_data_cache, sig_data_cache_record_mem);
end arch;

