-- Mem Wrapper TEST --
LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;             
USE WORK.CPU_PKG.all;
USE WORK.CPU_lib.all;                   

ENTITY MEM_WRAPPER_vhd_tst IS
END MEM_WRAPPER_vhd_tst;
ARCHITECTURE MEM_WRAPPER_arch OF MEM_WRAPPER_vhd_tst IS
-- constants                                                 
-- signals

SIGNAL record_in_crls		: CRLS_RCD;
SIGNAL ex_record_mem			: EX_MEM_RCD;
SIGNAL mem_record_wb			: MEM_WB_RCD;

COMPONENT MEM_WRAPPER
	PORT (
		SIGNAL record_in_crls		: in 	CRLS_RCD;
		SIGNAL ex_record_mem			: in 	EX_MEM_RCD;
		SIGNAL mem_record_wb			: out MEM_WB_RCD
	);
END COMPONENT;
BEGIN
	wrapp : MEM_WRAPPER
	PORT MAP (
		ex_record_mem => ex_record_mem,
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
	
	record_in_crls.stall 		<= '0';
	--Address in memory !!!
	ex_record_mem.pc				<=	"00000000000000000000000000000000";	
	ex_record_mem.alu_out		<=	"00000000000000000000000000000001";	
	ex_record_mem.opcode 		<= OPCODE_STORE;
	ex_record_mem.dst		     	<= "11111111111100011111100001111111";
	
	wait for 30 ns;
	
	ex_record_mem.opcode 		<= OPCODE_LOAD;

	wait for 40 ns;
	
END PROCESS always;          

END MEM_WRAPPER_arch;
