library IEEE; 
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
use IEEE.STD_LOGIC_ARITH.all;

entity INSTRUCTION_DECODER_2 is

	port
	(
		-- Input ports
		instruction	: in REG_TYPE;
		pc 			: in REG_TYPE;
		-- Output ports
		decoder_record_regfile2 : out DECODER_REGFILE_RCD_2
		);
end INSTRUCTION_DECODER_2;

architecture arch of INSTRUCTION_DECODER_2 is

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
		
						decoder_record_regfile2.opcode 			<= opcode_var;
						decoder_record_regfile2.operand_A   	<= DECODE_R1(instruction);
						decoder_record_regfile2.operand_B   	<= DECODE_R2(instruction);
						decoder_record_regfile2.destination 	<= DECODE_R3(instruction);
						decoder_record_regfile2.immediate		<= UNDEFINED_17;
						decoder_record_regfile2.offset			<= UNDEFINED_27;
						decoder_record_regfile2.pc					<= pc;
			
			when 	OPCODE_UMOV | OPCODE_SMOV	=>
				
						decoder_record_regfile2.opcode 			<= opcode_var;
						decoder_record_regfile2.operand_A   	<= UNDEFINED_5;
						decoder_record_regfile2.operand_B   	<= UNDEFINED_5;
						decoder_record_regfile2.destination		<= DECODE_R3(instruction);
						decoder_record_regfile2.immediate		<= DECODE_IMMEDIATE(instruction);
						decoder_record_regfile2.offset			<= UNDEFINED_27;
						decoder_record_regfile2.pc					<= pc;
			
			when 	OPCODE_BEQ | OPCODE_BGT | OPCODE_BHI | OPCODE_BAL | OPCODE_BLAL =>
						
						decoder_record_regfile2.opcode 			<= opcode_var;
						decoder_record_regfile2.operand_A   	<= UNDEFINED_5;
						decoder_record_regfile2.operand_B   	<= UNDEFINED_5;
						decoder_record_regfile2.destination 	<= UNDEFINED_5;
						decoder_record_regfile2.immediate		<= UNDEFINED_17;
						decoder_record_regfile2.offset			<= DECODE_OFFSET(instruction);
						decoder_record_regfile2.pc					<= pc;
						
			when 	OPCODE_STOP =>
						decoder_record_regfile2.opcode 			<= opcode_var;
						decoder_record_regfile2.operand_A   	<= UNDEFINED_5;
						decoder_record_regfile2.operand_B   	<= UNDEFINED_5;
						decoder_record_regfile2.destination 	<= UNDEFINED_5;
						decoder_record_regfile2.immediate		<= UNDEFINED_17;
						decoder_record_regfile2.offset			<= UNDEFINED_27;
						decoder_record_regfile2.pc					<= pc;
			
			--WHEN INSTRUCTION IS NOT VALID
			when others =>	
						decoder_record_regfile2.opcode			<= UNDEFINED_5;
						decoder_record_regfile2.operand_A		<= UNDEFINED_5;
						decoder_record_regfile2.operand_B		<= UNDEFINED_5;
						decoder_record_regfile2.immediate		<= UNDEFINED_17;
						decoder_record_regfile2.destination		<= UNDEFINED_5;
						decoder_record_regfile2.offset			<= UNDEFINED_27;
						decoder_record_regfile2.pc					<= UNDEFINED_32;
		end case;	
	end process;
end arch;
