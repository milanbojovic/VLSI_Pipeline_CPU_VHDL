library IEEE; 
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
use IEEE.STD_LOGIC_ARITH.all;

entity INSTRUCTION_DECODER is

	port
	(
		-- Input ports
		instruction	: in REG_TYPE;
		pc 			: in REG_TYPE;
		-- Output ports
		decoder_record_regfile : out DECODER_REGFILE_RCD
		);
end INSTRUCTION_DECODER;

architecture arch of INSTRUCTION_DECODER is

	shared variable opcode_var : OPCODE_TYPE;

begin
	process(instruction)
	begin
		
		opcode_var := DECODE_OPCODE(instruction);
	
		case opcode_var is
			when 	OPCODE_AND | OPCODE_SUB |OPCODE_ADD  | OPCODE_ADC | OPCODE_SBC |
					OPCODE_CMP | OPCODE_SSUB| OPCODE_SADD| OPCODE_SADC| OPCODE_SSBC|
					OPCODE_MOV | OPCODE_NOT | OPCODE_SL  | OPCODE_SR  | OPCODE_ASR | OPCODE_LOAD | OPCODE_STORE
					=>
		
						decoder_record_regfile.opcode 		<= opcode_var;
						decoder_record_regfile.operand_A   	<= DECODE_R1(instruction);
						decoder_record_regfile.operand_B   	<= DECODE_R2(instruction);
						decoder_record_regfile.destination 	<= DECODE_R3(instruction);
						decoder_record_regfile.immediate		<= UNDEFINED_17;
						decoder_record_regfile.offset			<= UNDEFINED_27;
						decoder_record_regfile.pc				<= pc;
			
			when 	OPCODE_UMOV | OPCODE_SMOV	=>
				
						decoder_record_regfile.opcode 		<= opcode_var;
						decoder_record_regfile.operand_A   	<= UNDEFINED_5;
						decoder_record_regfile.operand_B   	<= UNDEFINED_5;
						decoder_record_regfile.destination	<= DECODE_R3(instruction);
						decoder_record_regfile.immediate		<= DECODE_IMMEDIATE(instruction);
						decoder_record_regfile.offset			<= UNDEFINED_27;
						decoder_record_regfile.pc				<= pc;
			
			when 	OPCODE_BEQ | OPCODE_BGT | OPCODE_BHI | OPCODE_BAL | OPCODE_BLAL =>
						
						decoder_record_regfile.opcode 		<= opcode_var;
						decoder_record_regfile.operand_A   	<= UNDEFINED_5;
						decoder_record_regfile.operand_B   	<= UNDEFINED_5;
						decoder_record_regfile.destination 	<= UNDEFINED_5;
						decoder_record_regfile.immediate		<= UNDEFINED_17;
						decoder_record_regfile.offset			<= DECODE_OFFSET(instruction);
						decoder_record_regfile.pc				<= pc;
						
			when 	OPCODE_STOP =>
						decoder_record_regfile.opcode 		<= opcode_var;
						decoder_record_regfile.operand_A   	<= UNDEFINED_5;
						decoder_record_regfile.operand_B   	<= UNDEFINED_5;
						decoder_record_regfile.destination 	<= UNDEFINED_5;
						decoder_record_regfile.immediate		<= UNDEFINED_17;
						decoder_record_regfile.offset			<= UNDEFINED_27;
						decoder_record_regfile.pc				<= pc;
			
			--WHEN INSTRUCTION IS NOT VALID
			when others =>	
						decoder_record_regfile.opcode			<= UNDEFINED_5;
						decoder_record_regfile.operand_A		<= UNDEFINED_5;
						decoder_record_regfile.operand_B		<= UNDEFINED_5;
						decoder_record_regfile.immediate		<= UNDEFINED_17;
						decoder_record_regfile.destination	<= UNDEFINED_5;
						decoder_record_regfile.offset			<= UNDEFINED_27;
						decoder_record_regfile.pc				<= UNDEFINED_32;
		end case;	
	end process;
end arch;
