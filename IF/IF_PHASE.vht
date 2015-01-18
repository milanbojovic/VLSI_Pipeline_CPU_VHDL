-- IF_PHASE TEST --
LIBRARY ieee;                                         
USE ieee.std_logic_1164.all;
use WORK.CPU_PKG.all;
USE WORK.CPU_lib.all;  

ENTITY IF_PHASE_vhd_tst IS
END IF_PHASE_vhd_tst;
ARCHITECTURE IF_PHASE_arch OF IF_PHASE_vhd_tst IS
-- constants                                                 
-- signals    

     
SIGNAL record_in_crls : CRLS_RCD;                                          
SIGNAL ex_record_if 	 : EX_IF_RCD;
SIGNAL if_record_id	 : IF_ID_RCD;
SIGNAL if_record_instr_cache 	: IFPHASE_INSTCACHE_RCD;
SIGNAL instr_cache_record_if	: INSTCACHE_IFPHASE_RCD;

COMPONENT IF_PHASE
	PORT (
		signal record_in_crls 			: in CRLS_RCD;
		signal ex_record_if				: in EX_IF_RCD;
		signal if_record_id				: out IF_ID_RCD;
		signal if_record_instr_cache 	: out	IFPHASE_INSTCACHE_RCD;
		signal instr_cache_record_if	: in	INSTCACHE_IFPHASE_RCD
	);
END COMPONENT;
BEGIN
	if_phase_1 : IF_PHASE
	PORT MAP (
-- list connections between master ports and signals
	record_in_crls => record_in_crls,
    ex_record_if  => ex_record_if,
    if_record_id  => if_record_id,
	 if_record_instr_cache => if_record_instr_cache,
	 instr_cache_record_if => instr_cache_record_if
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
  report "Test report: First output 1 2 3 bla bla bla";
  
  --ex_record_if.pc <= "00000000000000000000000000001010";
  ex_record_if.branch_cond <= '0';
  
  --record_in_crls.reset<= '1';
    
  wait for 50 ns;
                                             
END PROCESS always;

END IF_PHASE_arch;
