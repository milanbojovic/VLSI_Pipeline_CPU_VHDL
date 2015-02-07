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
		
		-- Input ports from decoder2
		decoder_record_regfile2 : in DECODER_REGFILE_RCD_2;

		-- from wb phase
		wb_record_id				: in WB_ID_RCD;
		
		-- from ex_phase
		ex_record_id				: in EX_ID_RCD;
		
		-- Output ports
		id_record_ex				: out ID_EX_RCD
	);
	
end REG_FILE;


architecture arch of REG_FILE is

	shared variable register_array	: REG_FILE_TYPE := init_regs;

begin
		
		process(decoder_record_regfile.opcode,record_in_crls.clk)
		begin		
		
		if (ex_record_id.flush_out = '1') then 
			id_record_ex.opcode     		<= UNDEFINED_5 ;
			id_record_ex.a   					<= UNDEFINED_32;
			id_record_ex.index_a          <= UNDEFINED_5;
			id_record_ex.b   					<= UNDEFINED_32;
			id_record_ex.index_b				<= UNDEFINED_5;
			id_record_ex.dst 					<= UNDEFINED_32;
			id_record_ex.index_dst			<= UNDEFINED_5;
			id_record_ex.immediate			<= UNDEFINED_32;
			id_record_ex.branch_offset		<= UNDEFINED_32;										
			id_record_ex.pc					<= UNDEFINED_32;			
			
		else
			case decoder_record_regfile.opcode is
		
				--Operation with registers
				when 	OPCODE_AND | OPCODE_SUB |OPCODE_ADD  | OPCODE_ADC | OPCODE_SBC |
						OPCODE_SSUB| OPCODE_SADD| OPCODE_SADC| OPCODE_SSBC| 
						OPCODE_SL  | OPCODE_SR  | OPCODE_ASR 
						=>
					
							id_record_ex.opcode     		<= decoder_record_regfile.opcode;
							id_record_ex.a   					<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile.operand_A)));
							id_record_ex.index_a				<= decoder_record_regfile.operand_A;
							id_record_ex.b   					<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile.operand_B)));
							id_record_ex.index_b				<= decoder_record_regfile.operand_B;
							id_record_ex.dst 					<= ZERO_27 & decoder_record_regfile.destination;
							id_record_ex.index_dst			<= decoder_record_regfile.destination;
							id_record_ex.immediate			<= UNDEFINED_32;
							id_record_ex.branch_offset		<= UNDEFINED_32;
							id_record_ex.pc					<= decoder_record_regfile.PC;
				
				
				when 	OPCODE_CMP =>
					
							id_record_ex.opcode     		<= decoder_record_regfile.opcode;
							id_record_ex.a   					<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile.operand_A)));
							id_record_ex.index_a				<= decoder_record_regfile.operand_A;
							id_record_ex.b   					<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile.operand_B)));
							id_record_ex.index_b				<= decoder_record_regfile.operand_B;
							id_record_ex.dst 					<= UNDEFINED_32;
							id_record_ex.index_dst			<= UNDEFINED_5;
							id_record_ex.immediate			<= UNDEFINED_32;
							id_record_ex.branch_offset		<= UNDEFINED_32;
							id_record_ex.pc					<= decoder_record_regfile.PC;
							
				
				when 	OPCODE_MOV | OPCODE_NOT
						=>
					
							id_record_ex.opcode     		<= decoder_record_regfile.opcode;
							id_record_ex.a   					<= UNDEFINED_32;
							id_record_ex.index_a				<= UNDEFINED_5;
							id_record_ex.b   					<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile.operand_B)));
							id_record_ex.index_b				<= decoder_record_regfile.operand_B;
							id_record_ex.dst 					<= ZERO_27 & decoder_record_regfile.destination;
							id_record_ex.index_dst			<= decoder_record_regfile.destination;
							id_record_ex.immediate			<= UNDEFINED_32;
							id_record_ex.branch_offset		<= UNDEFINED_32;
							id_record_ex.pc					<= decoder_record_regfile.PC;
							
							
				when 	OPCODE_LOAD
						=>
					
							id_record_ex.opcode     		<= decoder_record_regfile.opcode;
							id_record_ex.a   					<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile.operand_A)));
							id_record_ex.index_a				<= decoder_record_regfile.operand_A;
							id_record_ex.b   					<= UNDEFINED_32;
							id_record_ex.index_b				<= UNDEFINED_5;
							id_record_ex.dst 					<= ZERO_27 & decoder_record_regfile.destination;
							id_record_ex.index_dst			<= decoder_record_regfile.destination;
							id_record_ex.immediate			<= UNDEFINED_32;
							id_record_ex.branch_offset		<= UNDEFINED_32;
							id_record_ex.pc					<= decoder_record_regfile.PC;

							
				when 	OPCODE_STORE =>
					
							id_record_ex.opcode     		<= decoder_record_regfile.opcode;
							id_record_ex.a   					<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile.operand_A)));
							id_record_ex.index_a				<= decoder_record_regfile.operand_A;
							id_record_ex.index_dst			<= decoder_record_regfile.destination;
							id_record_ex.b   					<= UNDEFINED_32;
							id_record_ex.index_b				<= UNDEFINED_5;
							id_record_ex.dst 					<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile.destination)));
							id_record_ex.index_a				<= decoder_record_regfile.operand_A;
							id_record_ex.immediate			<= UNDEFINED_32;
							id_record_ex.branch_offset		<= UNDEFINED_32;
							id_record_ex.pc					<= decoder_record_regfile.PC;
										
				
				--Operation with registers and immediate values
				when 	OPCODE_UMOV | OPCODE_SMOV	=>
				
							id_record_ex.opcode     		<= decoder_record_regfile.opcode;
							id_record_ex.a   					<= UNDEFINED_32;
							id_record_ex.index_a				<= UNDEFINED_5;
							id_record_ex.b   					<= UNDEFINED_32;
							id_record_ex.index_b				<= UNDEFINED_5;
							id_record_ex.dst 					<= ZERO_27 & decoder_record_regfile.destination;
							id_record_ex.index_dst			<= decoder_record_regfile.destination;
							id_record_ex.immediate			<= func_sign_extend(decoder_record_regfile.immediate, decoder_record_regfile.opcode);
							id_record_ex.branch_offset		<= UNDEFINED_32;				
							id_record_ex.pc					<= decoder_record_regfile.PC;
				
				
				-- BRANCH OPERATIONS
				when 	OPCODE_BEQ | OPCODE_BGT | OPCODE_BHI | OPCODE_BAL | OPCODE_BLAL =>
							
							id_record_ex.opcode     		<= decoder_record_regfile.opcode;
							id_record_ex.a   					<= UNDEFINED_32;
							id_record_ex.index_a				<= UNDEFINED_5;
							id_record_ex.b   					<= UNDEFINED_32;
							id_record_ex.index_b				<= UNDEFINED_5;
							id_record_ex.dst 					<= UNDEFINED_32;
							id_record_ex.index_dst			<= UNDEFINED_5;
							id_record_ex.immediate			<= UNDEFINED_32;
							id_record_ex.branch_offset		<= func_offset_extend(decoder_record_regfile.offset);
							id_record_ex.pc					<= decoder_record_regfile.PC;
							
				when 	OPCODE_STOP =>
							
							id_record_ex.opcode     		<= decoder_record_regfile.opcode;
							id_record_ex.a   					<= UNDEFINED_32;
							id_record_ex.index_a				<= UNDEFINED_5;
							id_record_ex.b   					<= UNDEFINED_32;
							id_record_ex.index_b				<= UNDEFINED_5;
							id_record_ex.dst 					<= UNDEFINED_32;
							id_record_ex.index_dst			<= UNDEFINED_5;
							id_record_ex.immediate			<= UNDEFINED_32;
							id_record_ex.branch_offset		<= UNDEFINED_32;		
							id_record_ex.pc					<= decoder_record_regfile.PC;
				
				--WHEN INSTRUCTION IS NOT VALID
				when others =>	
							id_record_ex.opcode     		<= UNDEFINED_5;
							id_record_ex.a   					<= UNDEFINED_32;
							id_record_ex.index_a				<= UNDEFINED_5;
							id_record_ex.b   					<= UNDEFINED_32;
							id_record_ex.index_b				<= UNDEFINED_5;
							id_record_ex.dst 					<= UNDEFINED_32;
							id_record_ex.index_dst			<= UNDEFINED_5;
							id_record_ex.immediate			<= UNDEFINED_32;
							id_record_ex.branch_offset		<= UNDEFINED_32;										
							id_record_ex.pc					<= UNDEFINED_32;
			end case;		
		end if;

		end process;
		
		process(decoder_record_regfile2.opcode,record_in_crls.clk)
		begin		
		
		if (ex_record_id.flush_out = '1') then 
			id_record_ex.opcode2     		<= UNDEFINED_5 ;
			id_record_ex.a2   				<= UNDEFINED_32;
			id_record_ex.index_a2         <= UNDEFINED_5;
			id_record_ex.b2   				<= UNDEFINED_32;
			id_record_ex.index_b2			<= UNDEFINED_5;
			id_record_ex.dst2 				<= UNDEFINED_32;
			id_record_ex.index_dst2			<= UNDEFINED_5;
			id_record_ex.immediate2			<= UNDEFINED_32;
			id_record_ex.branch_offset2	<= UNDEFINED_32;										
			id_record_ex.pc2					<= UNDEFINED_32;	
			
		else
			case decoder_record_regfile2.opcode is
		
				--Operation with registers
				when 	OPCODE_AND | OPCODE_SUB |OPCODE_ADD  | OPCODE_ADC | OPCODE_SBC |
						OPCODE_SSUB| OPCODE_SADD| OPCODE_SADC| OPCODE_SSBC| 
						OPCODE_SL  | OPCODE_SR  | OPCODE_ASR 
						=>
					
							id_record_ex.opcode2     		<= decoder_record_regfile2.opcode;
							id_record_ex.a2   				<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile2.operand_A)));
							id_record_ex.index_a2			<= decoder_record_regfile2.operand_A;
							id_record_ex.b2   				<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile2.operand_B)));
							id_record_ex.index_b2			<= decoder_record_regfile2.operand_B;
							id_record_ex.dst2 				<= ZERO_27 & decoder_record_regfile2.destination;
							id_record_ex.index_dst2			<= decoder_record_regfile2.destination;
							id_record_ex.immediate2			<= UNDEFINED_32;
							id_record_ex.branch_offset2	<= UNDEFINED_32;
							id_record_ex.pc2					<= decoder_record_regfile2.PC;
				
				
				when 	OPCODE_CMP =>
					
							id_record_ex.opcode2     		<= decoder_record_regfile2.opcode;
							id_record_ex.a2   				<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile2.operand_A)));
							id_record_ex.index_a2			<= decoder_record_regfile2.operand_A;
							id_record_ex.b2   				<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile2.operand_B)));
							id_record_ex.index_b2			<= decoder_record_regfile2.operand_B;
							id_record_ex.dst2 				<= UNDEFINED_32;
							id_record_ex.index_dst2			<= UNDEFINED_5;
							id_record_ex.immediate2			<= UNDEFINED_32;
							id_record_ex.branch_offset2	<= UNDEFINED_32;
							id_record_ex.pc2					<= decoder_record_regfile2.PC;
							
				
				when 	OPCODE_MOV | OPCODE_NOT
						=>
					
							id_record_ex.opcode2     		<= decoder_record_regfile2.opcode;
							id_record_ex.a2   				<= UNDEFINED_32;
							id_record_ex.index_a2			<= UNDEFINED_5;
							id_record_ex.b2   				<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile2.operand_B)));
							id_record_ex.index_b2			<= decoder_record_regfile2.operand_B;
							id_record_ex.dst2 				<= ZERO_27 & decoder_record_regfile.destination;
							id_record_ex.index_dst2			<= decoder_record_regfile2.destination;
							id_record_ex.immediate2			<= UNDEFINED_32;
							id_record_ex.branch_offset2	<= UNDEFINED_32;
							id_record_ex.pc2					<= decoder_record_regfile2.PC;
							
							
				when 	OPCODE_LOAD
						=>
					
							id_record_ex.opcode2     		<= decoder_record_regfile2.opcode;
							id_record_ex.a2   				<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile2.operand_A)));
							id_record_ex.index_a2			<= decoder_record_regfile2.operand_A;
							id_record_ex.b2   				<= UNDEFINED_32;
							id_record_ex.index_b2			<= UNDEFINED_5;
							id_record_ex.dst2 				<= ZERO_27 & decoder_record_regfile2.destination;
							id_record_ex.index_dst2			<= decoder_record_regfile2.destination;
							id_record_ex.immediate2			<= UNDEFINED_32;
							id_record_ex.branch_offset2	<= UNDEFINED_32;
							id_record_ex.pc2					<= decoder_record_regfile2.PC;

							
				when 	OPCODE_STORE =>
					
							id_record_ex.opcode2     		<= decoder_record_regfile2.opcode;
							id_record_ex.a2   				<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile2.operand_A)));
							id_record_ex.index_a2			<= decoder_record_regfile2.operand_A;
							id_record_ex.index_dst2			<= decoder_record_regfile2.destination;
							id_record_ex.b2	   			<= UNDEFINED_32;
							id_record_ex.index_b2			<= UNDEFINED_5;
							id_record_ex.dst2 				<= register_array(TO_INTEGER(UNSIGNED(decoder_record_regfile2.destination)));
							id_record_ex.index_a2			<= decoder_record_regfile2.operand_A;
							id_record_ex.immediate2			<= UNDEFINED_32;
							id_record_ex.branch_offset2	<= UNDEFINED_32;
							id_record_ex.pc2					<= decoder_record_regfile2.PC;
										
				
				--Operation with registers and immediate values
				when 	OPCODE_UMOV | OPCODE_SMOV	=>
				
							id_record_ex.opcode2     		<= decoder_record_regfile2.opcode;
							id_record_ex.a2   				<= UNDEFINED_32;
							id_record_ex.index_a2			<= UNDEFINED_5;
							id_record_ex.b2   				<= UNDEFINED_32;
							id_record_ex.index_b2			<= UNDEFINED_5;
							id_record_ex.dst2 				<= ZERO_27 & decoder_record_regfile2.destination;
							id_record_ex.index_dst2			<= decoder_record_regfile2.destination;
							id_record_ex.immediate2			<= func_sign_extend(decoder_record_regfile2.immediate, decoder_record_regfile2.opcode);
							id_record_ex.branch_offset2	<= UNDEFINED_32;				
							id_record_ex.pc2					<= decoder_record_regfile2.PC;
				
				
				-- BRANCH OPERATIONS
				when 	OPCODE_BEQ | OPCODE_BGT | OPCODE_BHI | OPCODE_BAL | OPCODE_BLAL =>
							
							id_record_ex.opcode2     		<= decoder_record_regfile2.opcode;
							id_record_ex.a2  					<= UNDEFINED_32;
							id_record_ex.index_a2			<= UNDEFINED_5;
							id_record_ex.b2	   			<= UNDEFINED_32;
							id_record_ex.index_b2			<= UNDEFINED_5;
							id_record_ex.dst2 				<= UNDEFINED_32;
							id_record_ex.index_dst2			<= UNDEFINED_5;
							id_record_ex.immediate2			<= UNDEFINED_32;
							id_record_ex.branch_offset2	<= func_offset_extend(decoder_record_regfile2.offset);
							id_record_ex.pc2					<= decoder_record_regfile2.PC;
							
				when 	OPCODE_STOP =>
							
							id_record_ex.opcode2     		<= decoder_record_regfile2.opcode;
							id_record_ex.a2	   			<= UNDEFINED_32;
							id_record_ex.index_a2			<= UNDEFINED_5;
							id_record_ex.b2	   			<= UNDEFINED_32;
							id_record_ex.index_b2			<= UNDEFINED_5;
							id_record_ex.dst2 				<= UNDEFINED_32;
							id_record_ex.index_dst2			<= UNDEFINED_5;
							id_record_ex.immediate2			<= UNDEFINED_32;
							id_record_ex.branch_offset2	<= UNDEFINED_32;		
							id_record_ex.pc2					<= decoder_record_regfile2.PC;
				
				--WHEN INSTRUCTION IS NOT VALID
				when others =>	
							id_record_ex.opcode2     		<= UNDEFINED_5;
							id_record_ex.a2	   			<= UNDEFINED_32;
							id_record_ex.index_a2			<= UNDEFINED_5;
							id_record_ex.b2   				<= UNDEFINED_32;
							id_record_ex.index_b2			<= UNDEFINED_5;
							id_record_ex.dst2 				<= UNDEFINED_32;
							id_record_ex.index_dst2			<= UNDEFINED_5;
							id_record_ex.immediate2			<= UNDEFINED_32;
							id_record_ex.branch_offset2	<= UNDEFINED_32;										
							id_record_ex.pc2					<= UNDEFINED_32;
			end case;		
		end if;

		end process;
			
		process(record_in_crls.clk) begin
			--Warnings !!!
			--Instruction 1
			if (rising_edge(record_in_crls.clk) and wb_record_id.write_enable = '1') then
				register_array(TO_INTEGER(UNSIGNED(wb_record_id.reg_adr(4 downto 0)))) := wb_record_id.data;
			end if;
			
			--Instruction 2
			if (rising_edge(record_in_crls.clk) and wb_record_id.write_enable2 = '1') then
				register_array(TO_INTEGER(UNSIGNED(wb_record_id.reg_adr2(4 downto 0)))) := wb_record_id.data2;
			end if;
		end process;
end arch;