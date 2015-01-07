LIBRARY ieee;                                         
USE ieee.std_logic_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_PKG.all;
use WORK.EX_IF_PKG.all;
use WORK.IF_ID_pkg.all;

ENTITY IF_PHASE_vhd_tst IS
END IF_PHASE_vhd_tst;
ARCHITECTURE IF_PHASE_arch OF IF_PHASE_vhd_tst IS
-- constants                                                 
-- signals         
SIGNAL record_in_crls : CRLS_RCD;                                          
SIGNAL ex_record_if 	 : EX_IF_RCD;
SIGNAL if_record_id	 : IF_ID_RCD;




COMPONENT IF_PHASE
	PORT (
		record_in_crls 		: in CRLS_RCD;
		ex_record_if			: in EX_IF_RCD;
		if_record_id			: out IF_ID_RCD
	);
END COMPONENT;
BEGIN
	IFPHASE : IF_PHASE
	PORT MAP (
-- list connections between master ports and signals
	record_in_crls => record_in_crls,
    ex_record_if    => ex_record_if,
    if_record_id     => if_record_id
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
  
  ex_record_if.pc <= "00000000000000000000000000001010";
  ex_record_if.branch_cond <= '0';
  
  --record_in_crls.reset<= '1';
  
  wait for 10 ns; 
  
  record_in_crls.reset<= '0';
    
  wait for 50 ns;
                                             
END PROCESS always;

END IF_PHASE_arch;
