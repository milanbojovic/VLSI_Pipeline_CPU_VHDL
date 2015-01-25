--ID Phase--
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_LIB.all;
use WORK.CPU_PKG.all;
use IEEE.STD_LOGIC_ARITH.all;


entity ID_PHASE is

	port
	(
		-- Input ports
		record_in_crls			:  in CRLS_RCD;
		
		--IF phase 
		if_record_id	      :	in	IF_ID_RCD;
		
		--MEM phase
		wb_record_id			:  in WB_ID_RCD;

		ex_record_id			: 	in EX_ID_RCD;
		-- Output ports
		--EX phase
		id_record_ex			: 	out ID_EX_RCD
	);

end ID_PHASE;
 

architecture arch of ID_PHASE is

	--Register PC (Program Counter)
	signal reg_pc						: REG_TYPE;
	signal reg_ir1, reg_ir2			: REG_TYPE;
	signal decoder_record_regfile : DECODER_REGFILE_RCD;
		
begin
	
	process (record_in_crls.load, record_in_crls.reset) begin 
		if (record_in_crls.reset = '0') and (record_in_crls.load = '1') then 		
				reg_pc	<= if_record_id.pc;
				reg_ir1	<= if_record_id.ir1;
				reg_ir2	<= if_record_id.ir2;
				
		elsif (record_in_crls.reset = '1') then
				reg_pc	<= UNDEFINED_32;
				reg_ir1	<= UNDEFINED_32;
				reg_ir2	<= UNDEFINED_32;		
		end if;
	end process;
		
	--Instatination and connecting of INSTRUCTION_DECODER
	COMP_instr_dec : entity work.INSTRUCTION_DECODER(arch)
		port map (
					 instruction    			=> reg_ir1, 
					 pc							=> reg_pc,
					 decoder_record_regfile => decoder_record_regfile
					);				 
					 
	--Instatination and connecting of REG_FILE
	COMP_reg_file : entity work.REG_FILE(arch)
		port map (
						record_in_crls				=>	record_in_crls,
						decoder_record_regfile	=> decoder_record_regfile, 
						wb_record_id				=> wb_record_id,
						ex_record_id				=> ex_record_id,
						id_record_ex				=> id_record_ex
					 );
	
end arch;



