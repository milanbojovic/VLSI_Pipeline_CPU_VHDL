-- EX_PHASE TEST --
LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;   
USE WORK.CPU_PKG.all;
USE WORK.CPU_lib.all;
              
ENTITY EX_PHASE_vhd_tst IS
END EX_PHASE_vhd_tst;
ARCHITECTURE EX_PHASE_arch OF EX_PHASE_vhd_tst IS
-- constants                                                 
-- signals                                                   

SIGNAL record_in_crls		: CRLS_RCD;
SIGNAL id_record_ex			: ID_EX_RCD;
SIGNAL ex_record_if			: EX_IF_RCD;
SIGNAL ex_record_mem			: EX_MEM_RCD;



COMPONENT EX_PHASE
	PORT (
			SIGNAL record_in_crls		: in 	CRLS_RCD;
			SIGNAL id_record_ex			: in 	ID_EX_RCD;
			SIGNAL ex_record_if			: out EX_IF_RCD;
			SIGNAL ex_record_mem			: out EX_MEM_RCD
	);
END COMPONENT;


BEGIN
	ex1 : EX_PHASE
	PORT MAP (
    record_in_crls 	=> record_in_crls,
    id_record_ex	  	=> id_record_ex,
	 ex_record_if		=> ex_record_if,
    ex_record_mem 	=> ex_record_mem
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
	
	id_record_ex.pc							<=	"00000000000000000000000000000011";
	id_record_ex.branch_offset				<=	"00000000000000000000000000000001";	
	
--	--CMP > LESS
--	id_record_ex.a 							<= "00000000000000000000000000000111";
--	id_record_ex.b 							<=	"00000000000000000000000001111011";
--	id_record_ex.opcode 						<= OPCODE_CMP;
--	
--	wait for 10 ns;
--	
--	id_record_ex.opcode 						<= OPCODE_BEQ;
--	
--	wait for 10 ns;
--	
--	--CMP > ZERO
--	id_record_ex.b 							<=	"00000000000000000000000000000111";
--	id_record_ex.opcode 						<= OPCODE_CMP;
--	
--	wait for 10 ns;
--
--
--	id_record_ex.opcode 						<= OPCODE_BEQ;
--	
--	wait for 10 ns;
--	
--	
--	--	--CMP > GREATHER
--	id_record_ex.opcode 						<= OPCODE_CMP;	  
--	id_record_ex.a 							<= "00000000000000000000000000000111";
--	id_record_ex.b 							<=	"00000000000000000000000000000011";
--	wait for 10 ns;
--	
--	id_record_ex.opcode 						<= OPCODE_BGT;
--	
--	wait for 10 ns;	
--	
--	id_record_ex.opcode 						<= OPCODE_BHI;
--	
--	wait for 10 ns;	
	
	id_record_ex.opcode 						<= OPCODE_BAL;
		
	wait for 10 ns;	
	
	id_record_ex.opcode 						<= OPCODE_BLAL;
	
	wait for 10 ns;	

	 
	--******************************************************************
	-- LOAD/STORE 										 !!!!!!!!!!!!!!!!!!!!!!!
	--******************************************************************
	
--	id_record_ex.dst		 				<= "00000000000000000000000000111111";
--	
--	id_record_ex.a 						<=	"00000000000000001111111111111111";
--	id_record_ex.b							<=	"00111111111111111111111111111111";
--	id_record_ex.opcode 					<= OPCODE_STORE;
--	
--	wait for 10 ns;	
--
--	id_record_ex.opcode 					<= OPCODE_LOAD;
--
--	wait for 10 ns;


	--******************************************************************
	-- IMMEDIATE INSTRUCTIONS						 !!!!!!!!!!!!!!!!!!!!!!!
	--******************************************************************
	
	
--  id_record_ex.pc 						<= "00000000000000000000000000000001";	  
--  id_record_ex.immediate 				<= "00000000000000000000000000000111";
--  id_record_ex.branch_offset			<= "00000000000000000000000000000001";
--  id_record_ex.dst		 				<= "00000000000000000000000000000001";
	
	
	-- Output should be pc + immed =00001000
--	id_record_ex.a 							<=	"00000000000000001010001111111000";
--	id_record_ex.b								<=	"00111111111111111111111111111111";
--	id_record_ex.opcode 					<= OPCODE_UMOV;
--	
--	wait for 10 ns;	
--	
--	
--	id_record_ex.a 							<=	"00000000000000000000000000000001";
--	id_record_ex.b								<=	"00000000000000000011111111111111";	
--	id_record_ex.opcode 					<= OPCODE_SMOV;
--	
--	wait for 10 ns;
	 
	 
	--******************************************************************
	-- ALU INSTRUCTIONS 								 !!!!!!!!!!!!!!!!!!!!!!!
	--******************************************************************	 



--	--CMP > GREATHER
--	id_record_ex.opcode 						<= OPCODE_CMP;	  
--	id_record_ex.a 							<= "00000000000000000000000000000111";
--	id_record_ex.b 							<=	"00000000000000000000000000000011";
--	wait for 10 ns;
--	
--	--CMP > LESS
--	id_record_ex.b 							<=	"00000000000000000000000001111011";
--	id_record_ex.opcode 						<= OPCODE_CMP;
--	wait for 10 ns;
--	
--	--CMP > ZERO
--	id_record_ex.b 							<=	"00000000000000000000000000000111";
--	id_record_ex.opcode 						<= OPCODE_CMP;
--	
--	wait for 10 ns;
--	
--	--ADD - SET CARRY FLAG
--	id_record_ex.a 							<= "11111111111111111111111111111111";
--	id_record_ex.b 							<=	"11111111111111111111111111111111";
--	id_record_ex.opcode 						<= OPCODE_ADD;
--	
--	wait for 10 ns;
--	
--	--ADD WITH CARRY
--	id_record_ex.b 							<=	"00000000000000000000000000000011";
--	id_record_ex.a								<=	"00000000000000000000000000000111";
--	id_record_ex.opcode 						<= OPCODE_ADC;
--	
--	wait for 10 ns;	
--	
--	--SADD -21 + 22 = 1
--	id_record_ex.a 							<=	"11111111111111111111111111101011";
--	id_record_ex.b								<=	"00000000000000000000000000010110";
--	id_record_ex.opcode 						<= OPCODE_SADD;
--		
--	wait for 10 ns;
--	
--	--ADD - SET CARRY FLAG
--	id_record_ex.a 							<= "11111111111111111111111111111111";
--	id_record_ex.b 							<=	"11111111111111111111111111111111";
--	id_record_ex.opcode 						<= OPCODE_ADD;
--	
--	wait for 10 ns;
--	
--	-- SADC  -21 + 22 + CARRY
--	id_record_ex.a 							<=	"11111111111111111111111111101011";
--	id_record_ex.b								<=	"00000000000000000000000000010110";
--	id_record_ex.opcode 						<= OPCODE_SADC;
--	
--	wait for 10 ns;
--	
--	--SSUB  -21 - - 21 = -42
--	id_record_ex.a 							<=	"11111111111111111111111111101011";
--	id_record_ex.b								<=	"11111111111111111111111111101011";
--	id_record_ex.opcode 						<= OPCODE_SSUB;
--	
--	--ADD - SET CARRY FLAG
--	id_record_ex.a 							<= "11111111111111111111111111111111";
--	id_record_ex.b 							<=	"11111111111111111111111111111111";
--	id_record_ex.opcode 						<= OPCODE_ADD;
--	
--	wait for 10 ns;
--	
--	--SSUB -21 -- 21 - CARRY
--	id_record_ex.a 							<=	"11111111111111111111111111101011";
--	id_record_ex.b								<=	"11111111111111111111111111101011";
--	id_record_ex.opcode 						<= OPCODE_SSBC;
--	
--	
--	wait for 10 ns;

--	id_record_ex.a 							<=	"00000000000000000000000000000001";
--	id_record_ex.b								<=	"00000000000000000011111111111111";
--	id_record_ex.opcode 						<= OPCODE_MOV;
--
--	wait for 10 ns;
--	
--	
--	
--	id_record_ex.opcode 						<= OPCODE_NOT;
--	
--	wait for 10 ns;
--
--	id_record_ex.opcode 						<= OPCODE_SL;
--	id_record_ex.b								<=	"00000000000000000000000000000011";
--	
--	wait for 10 ns;
--	
--	id_record_ex.opcode 						<= OPCODE_SR;
--	id_record_ex.b								<=	"00000000000000000000000000000001";
--	
--	wait for 10 ns;
--
--	id_record_ex.a 							<=	"11111111111111111111111111000000";
--	id_record_ex.b								<=	"00000000000000000000000000000011";
--	id_record_ex.opcode 						<= OPCODE_ASR;
--		
--	wait for 10 ns;
--	
--	id_record_ex.a 							<=	"00000000000000000000000111110000";
--	id_record_ex.opcode 						<= OPCODE_ASR;
--		
--	wait for 10 ns;
	
	wait for 5 ns;

END PROCESS always;                                          

END EX_PHASE_arch;
