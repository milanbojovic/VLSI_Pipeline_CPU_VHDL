-- IF WRAPPER TEST --
LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                
USE WORK.CPU_PKG.all;
USE WORK.CPU_lib.all;  

ENTITY IF_WRAPPER_vhd_tst IS
END IF_WRAPPER_vhd_tst;
ARCHITECTURE IF_WRAPPER_arch OF IF_WRAPPER_vhd_tst IS
-- constants                                                 
-- signals   


SIGNAL record_in_crls 	: CRLS_RCD;	
SIGNAL ex_record_if		: EX_IF_RCD;
SIGNAL if_record_id		: IF_ID_RCD;

COMPONENT IF_WRAPPER
	PORT (
	SIGNAL record_in_crls 	: in  CRLS_RCD;	
	SIGNAL ex_record_if		: in  EX_IF_RCD;
	SIGNAL if_record_id		: out IF_ID_RCD
	);
END COMPONENT;
BEGIN
	if_wrapper_1 : IF_WRAPPER
	PORT MAP (
-- list connections between master ports and signals
	record_in_crls => record_in_crls,
	ex_record_if 	=> ex_record_if,
	if_record_id 	=> if_record_id
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
	--wait for 10 ns;
	ex_record_if.branch_cond <= '0';
	
	--ex_record_if.pc <= "00000000000000000000000000001010";
	
	  
	--record_in_crls.reset<= '1';
	  
	wait for 30 ns; 

	
END PROCESS always;          	
END IF_WRAPPER_arch;
