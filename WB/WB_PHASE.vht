-- WB_PHASE --
LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;   
USE WORK.CPU_PKG.all;                             
USE WORK.CPU_LIB.all;       

ENTITY WB_PHASE_vhd_tst IS
END WB_PHASE_vhd_tst;
ARCHITECTURE WB_PHASE_arch OF WB_PHASE_vhd_tst IS
-- constants
-- signals

SIGNAL record_in_crls		: CRLS_RCD;
SIGNAL mem_record_wb			: MEM_WB_RCD;
SIGNAL wb_record_id			: WB_ID_RCD;

COMPONENT WB_PHASE
	PORT (
	record_in_crls	: IN 	CRLS_RCD;
	mem_record_wb	: IN 	MEM_WB_RCD;
	wb_record_id	: OUT WB_ID_RCD
	);
	
END COMPONENT;
BEGIN
	i1 : WB_PHASE
	PORT MAP (
	mem_record_wb => mem_record_wb,
	record_in_crls=> record_in_crls,
	wb_record_id  => wb_record_id
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
	
	mem_record_wb.pc					<=	"00000000000000000000000000101010";	
	mem_record_wb.alu_out			<=	"11100000001111111111111110000111";	
	mem_record_wb.lmd		    		<= "00000000000000000000000000000111";
	mem_record_wb.dst		     		<= "00000000000000000000000000000111";
	
	mem_record_wb.opcode 			<= OPCODE_ADD;
	wait for 10 ns;
	mem_record_wb.opcode 			<= OPCODE_CMP;
	wait for 10 ns;
	mem_record_wb.opcode 			<= OPCODE_BLAL;
	wait for 10 ns;
	mem_record_wb.opcode 			<= OPCODE_BEQ;
	
	wait for 10 ns;
WAIT;                                                        
END PROCESS always;                                          
END WB_PHASE_arch;


