-- MEM Phase --
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
use IEEE.STD_LOGIC_ARITH.all;

entity WB_PHASE is
	port
	(	
		-- Input ports
		record_in_crls 		: in CRLS_RCD;	--Clock, Reset, Load, Store
				
		-- MEM Phase
		mem_record_wb			: in MEM_WB_RCD;
		
		-- ID Phase
		wb_record_id			: out WB_ID_RCD
		
	);
end WB_PHASE;

architecture arch of WB_PHASE is
	-- REGISTERS
	
	shared variable reg_opcode 		: OPCODE_TYPE;
	shared variable reg_alu_out		: REG_TYPE;
	shared variable reg_dst	 		: REG_TYPE;
	shared variable reg_lmd	 		: REG_TYPE;
	shared variable reg_pc			: REG_TYPE; 
	
begin

	process(record_in_crls.clk) is 
	begin 
		if rising_edge(record_in_crls.clk) then
			reg_opcode 		:= mem_record_wb.opcode;
			reg_alu_out		:=	mem_record_wb.alu_out;
			reg_dst			:=	mem_record_wb.dst;
			reg_lmd			:= mem_record_wb.lmd;
			reg_pc			:=	mem_record_wb.pc;
		end if;
	end process;
	

	WB_PROCESS:
	process(record_in_crls.clk) is 
	begin 
		if rising_edge(record_in_crls.clk) then
		
		case reg_opcode is
		
			-- ALU INSTRUCTION REG/IMM (EXCEPT CMP)
			when OPCODE_AND | OPCODE_SUB	| OPCODE_ADD | OPCODE_ADC | OPCODE_SBC |
				  OPCODE_SSUB| OPCODE_SADD| OPCODE_SADC| OPCODE_SSBC| OPCODE_MOV |
				  OPCODE_NOT | OPCODE_SL  | OPCODE_SR  | OPCODE_ASR | OPCODE_UMOV| OPCODE_SMOV =>
				
				wb_record_id.data				<= reg_alu_out;
				wb_record_id.reg_adr			<= reg_dst;
				wb_record_id.write_enable	<= '1';
				
			when OPCODE_LOAD =>
				wb_record_id.data				<= reg_lmd;
				wb_record_id.reg_adr			<= reg_dst;
				wb_record_id.write_enable	<= '1';
			
			when OPCODE_BLAL =>
				wb_record_id.data				<= reg_pc;
				wb_record_id.reg_adr			<= LINK_ADDR;   -- Reg 31 (link reg)
				wb_record_id.write_enable	<= '1';
				
			when others =>
				-- NOTHING - ALL UNDEFINED
				wb_record_id.data				<= UNDEFINED_32;
				wb_record_id.reg_adr			<= UNDEFINED_32;
				wb_record_id.write_enable	<= '0';
		end case;
	
		end if;
	end process;	
end arch;