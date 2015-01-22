library IEEE; 
library WORK;

use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;

entity REG_FILE is

	port
	(
		record_in_crls			:  in CRLS_RCD;
		
		-- Input ports from decoder
		decoder_record_regfile	: in DECODER_REGFILE_RCD;

		-- from wb phase
		wb_record_id				: in WB_ID_RCD;
		
		-- Output ports
		id_record_ex				: out ID_EX_RCD
		
	);
	
end REG_FILE;


architecture arch of REG_FILE is

	shared variable register_array	: REG_FILE_TYPE := init_regs;

begin
		
		process(decoder_record_regfile.opcode)
			begin

	case decoder_record_regfile.opcode is
	
			--Operation with registers + LOAD OPERATION
			when 	OPCODE_AND | OPCODE_SUB |OPCODE_ADD  | OPCODE_ADC | OPCODE_SBC |
					OPCODE_CMP | OPCODE_SSUB| OPCODE_SADD| OPCODE_SADC| OPCODE_SSBC|
					OPCODE_MOV | OPCODE_NOT | OPCODE_SL  | OPCODE_SR  | OPCODE_ASR | OPCODE_LOAD
					=>
				
						id_record_ex.opcode     		<= decoder_record_regfile.opcode;
						id_record_ex.a   					<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile.operand_A)));
						id_record_ex.b   					<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile.operand_B)));
						id_record_ex.dst 					<= ZERO_27 & decoder_record_regfile.destination;
						id_record_ex.immediate			<= UNDEFINED_32;
						id_record_ex.branch_offset		<= UNDEFINED_32;
						id_record_ex.pc					<= decoder_record_regfile.PC;
						
						
			when 	OPCODE_STORE =>
				
						id_record_ex.opcode     		<= decoder_record_regfile.opcode;
						id_record_ex.a   					<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile.operand_A)));
						id_record_ex.b   					<= UNDEFINED_32;
						id_record_ex.dst 					<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile.destination)));
						id_record_ex.immediate			<= UNDEFINED_32;
						id_record_ex.branch_offset		<= UNDEFINED_32;
						id_record_ex.pc					<= decoder_record_regfile.PC;
									
			
			--Operation with registers and immediate values
			when 	OPCODE_UMOV | OPCODE_SMOV	=>
			
						id_record_ex.opcode     		<= decoder_record_regfile.opcode;
						id_record_ex.a   					<= UNDEFINED_32;
						id_record_ex.b   					<= UNDEFINED_32;
						id_record_ex.dst 					<= ZERO_27 & decoder_record_regfile.destination;
						id_record_ex.immediate			<= func_sign_extend(decoder_record_regfile.immediate);
						id_record_ex.branch_offset		<= UNDEFINED_32;				
						id_record_ex.pc					<= decoder_record_regfile.PC;
			
			-- BRANCH OPERATIONS
			when 	OPCODE_BEQ | OPCODE_BGT | OPCODE_BHI | OPCODE_BAL | OPCODE_BLAL =>
						
						id_record_ex.opcode     		<= decoder_record_regfile.opcode;
						id_record_ex.a   					<= UNDEFINED_32;
						id_record_ex.b   					<= UNDEFINED_32;
						id_record_ex.dst 					<= UNDEFINED_32;
						id_record_ex.immediate			<= UNDEFINED_32;
						id_record_ex.branch_offset		<= func_offset_extend(decoder_record_regfile.offset);
						id_record_ex.pc					<= decoder_record_regfile.PC;
						
			when 	OPCODE_STOP =>
						
						id_record_ex.opcode     		<= decoder_record_regfile.opcode;
						id_record_ex.a   					<= UNDEFINED_32;
						id_record_ex.b   					<= UNDEFINED_32;
						id_record_ex.dst 					<= UNDEFINED_32;
						id_record_ex.immediate			<= UNDEFINED_32;
						id_record_ex.branch_offset		<= UNDEFINED_32;		
						id_record_ex.pc					<= decoder_record_regfile.PC;
				
			
			--WHEN INSTRUCTION IS NOT VALID
			when others =>	
						id_record_ex.opcode     		<= UNDEFINED_5 ;
						id_record_ex.a   					<= UNDEFINED_32;
						id_record_ex.b   					<= UNDEFINED_32;
						id_record_ex.dst 					<= UNDEFINED_32;
						id_record_ex.immediate			<= UNDEFINED_32;
						id_record_ex.branch_offset		<= UNDEFINED_32;										
						id_record_ex.pc					<= UNDEFINED_32;
			end case;
		end process;
			
		process(record_in_crls.clk) begin
			--Warnings !!!
			if (rising_edge(record_in_crls.clk) and wb_record_id.write_enable = '1') then
				register_array(TO_INTEGER(UNSIGNED(wb_record_id.reg_adr(4 downto 0)))) := wb_record_id.data;
			end if;
		end process;
		
end arch;