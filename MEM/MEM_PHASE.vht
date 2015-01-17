-- MEM PHASE TEST
LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;             
USE WORK.CPU_PKG.all;
USE WORK.CPU_lib.all;                               

ENTITY MEM_PHASE_vhd_tst IS
END MEM_PHASE_vhd_tst;
ARCHITECTURE MEM_PHASE_arch OF MEM_PHASE_vhd_tst IS

SIGNAL record_in_crls			: CRLS_RCD;
SIGNAL ex_record_mem				: EX_MEM_RCD;
SIGNAL mem_record_wb				: MEM_WB_RCD;          
SIGNAL mem_record_data_cache	: MEMPHASE_DATACACHE_RCD;		
SIGNAL data_cache_record_mem	: DATACACHE_MEMPHASE_RCD;

COMPONENT MEM_PHASE
	PORT (
			SIGNAL record_in_crls			: in  CRLS_RCD;
			SIGNAL ex_record_mem				: in  EX_MEM_RCD;
			SIGNAL mem_record_wb				: out MEM_WB_RCD;          
			SIGNAL mem_record_data_cache	: out MEMPHASE_DATACACHE_RCD;		
			SIGNAL data_cache_record_mem	: in  DATACACHE_MEMPHASE_RCD
	);
END COMPONENT;
BEGIN
	i1 : MEM_PHASE
	PORT MAP (
-- list connections between master ports and signals
	data_cache_record_mem=> data_cache_record_mem,
	ex_record_mem => ex_record_mem,
	mem_record_data_cache=> mem_record_data_cache,
	mem_record_wb => mem_record_wb,
	record_in_crls=> record_in_crls
	);
	
	
	PROCESS
	variable clk_next : std_logic := '1';
	BEGIN
	  loop
		 record_in_crls.clk <= clk_next;
		 clk_next := not clk_next;
		 wait for 5 ns;
	  end loop;
	END PROCESS;
                                        
always : PROCESS                                              

BEGIN                                                         
	
	wait for 10 ns;
	
	data_cache_record_mem.dataOut <= "00000000000000000000000000001111";
		
	ex_record_mem.alu_out			<=	"00000000000000000000000000000001";
	ex_record_mem.opcode 			<= OPCODE_LOAD;
	ex_record_mem.dst		     		<= "00000000000000000000000000001001";
	
	
		  
WAIT;                                                        
END PROCESS;  
END MEM_PHASE_arch;
