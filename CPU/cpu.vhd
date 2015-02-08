--- CPU ---
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;

entity CPU is
  port
    (
    -- Input ports
      signal clk		: STD_LOGIC;
		signal reset	: STD_LOGIC;
      signal load 	: STD_LOGIC;
      signal stall 	: STD_LOGIC

    );
end CPU;

architecture arch of CPU is

	--Records
	signal record_in_crls : CRLS_RCD;
	signal ex_record_if	 : EX_IF_RCD;
	signal ex_record_id	 : EX_ID_RCD;
	signal ex_record_mem  : EX_MEM_RCD;
	signal if_record_id	 : IF_ID_RCD;
	signal id_record_ex	 : ID_EX_RCD;
	signal mem_record_wb  : MEM_WB_RCD;
	signal mem_record_ex	 : MEM_EX_RCD;
	signal wb_record_id   : WB_ID_RCD;
	signal wb_record_ex	 : WB_EX_RCD;
	
	signal sig_if_record_instr_cache	: IFPHASE_INSTCACHE_RCD;
	signal sig_instr_cache_record_if	: INSTCACHE_IFPHASE_RCD;
	signal sig_mem_record_data_cache : MEMPHASE_DATACACHE_RCD;
	signal sig_data_cache_record_mem : DATACACHE_MEMPHASE_RCD;
	signal opcode 							: OPCODE_TYPE;
	
begin	
				
		COMP_IF_PHASE  : entity work.IF_PHASE(arch)		port map (record_in_crls, ex_record_if, if_record_id, sig_if_record_instr_cache, sig_instr_cache_record_if);
		COMP_ID_PHASE	: entity work.ID_PHASE(arch) 		port map (record_in_crls, if_record_id, wb_record_id, ex_record_id, id_record_ex);
		COMP_EX_PHASE	: entity work.EX_PHASE(arch) 		port map (record_in_crls, id_record_ex, wb_record_ex, mem_record_ex, ex_record_if, ex_record_id, ex_record_mem);
		COMP_MEM_PHASE : entity work.MEM_PHASE(arch) 	port map (record_in_crls, ex_record_mem, wb_record_ex, mem_record_wb, mem_record_ex, sig_mem_record_data_cache, sig_data_cache_record_mem);
		COMP_WB_PHASE	: entity work.WB_PHASE(arch) 		port map (record_in_crls, mem_record_wb, opcode, wb_record_id, wb_record_ex);
		
		COMP_DATA_CACHE: entity work.DATA_CACHE(arch) 	port map (record_in_crls, sig_mem_record_data_cache, opcode, sig_data_cache_record_mem);
		COMP_INST_CACHE: entity work.INSTRUCTION_CACHE(arch) 	port map (record_in_crls, sig_if_record_instr_cache, sig_instr_cache_record_if);	
	
		
		record_in_crls.clk <= clk;
		record_in_crls.reset <= reset;
		record_in_crls.load <= load;
		record_in_crls.stall <= stall;
	
end arch;