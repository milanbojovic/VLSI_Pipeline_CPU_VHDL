-- WB Phase --
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
		wb_record_id			: out WB_ID_RCD;
		wb_record_ex			: out WB_EX_RCD
		
	);
end WB_PHASE;

architecture arch of WB_PHASE is
	-- REGISTERS
	--Instruction 1
	signal reg_opcode 		: OPCODE_TYPE;
	signal reg_alu_out		: REG_TYPE;
	signal reg_dst	 			: REG_TYPE;
	signal reg_lmd	 			: REG_TYPE;
	signal reg_pc				: REG_TYPE; 
	signal reg_index_dst		: REG_ADDR_TYPE;
	
	--Instruction 2
	signal reg_opcode2 		: OPCODE_TYPE;
	signal reg_alu_out2		: REG_TYPE;
	signal reg_dst2	 		: REG_TYPE;
	signal reg_lmd2	 		: REG_TYPE;
	signal reg_pc2				: REG_TYPE; 
	signal reg_index_dst2	: REG_ADDR_TYPE;
	
begin


	process (record_in_crls.load, record_in_crls.reset) begin 
		if (record_in_crls.reset = '0' and record_in_crls.load = '1') then
				--Instruction 1
				reg_opcode 		<= mem_record_wb.opcode;
				reg_alu_out		<=	mem_record_wb.alu_out;
				reg_dst			<=	mem_record_wb.dst;
				reg_lmd			<= mem_record_wb.lmd;
				reg_pc			<=	mem_record_wb.pc;
				reg_index_dst  <= mem_record_wb.index_dst;
		
				--Instruction 2
				reg_opcode2 	<= mem_record_wb.opcode2;
				reg_alu_out2	<=	mem_record_wb.alu_out2;
				reg_dst2			<=	mem_record_wb.dst2;
				reg_lmd2			<= mem_record_wb.lmd2;
				reg_pc2			<=	mem_record_wb.pc2;
				reg_index_dst2 <= mem_record_wb.index_dst2;
		
		
		elsif record_in_crls.reset = '1' then
				--Instruction 1
				reg_opcode 		<= UNDEFINED_5;
				reg_alu_out		<=	UNDEFINED_32;
				reg_dst			<=	UNDEFINED_32;
				reg_lmd			<= UNDEFINED_32;
				reg_pc			<=	UNDEFINED_32;
				reg_index_dst  <= UNDEFINED_5;
				
				--Instruction 2
				reg_opcode2 	<= UNDEFINED_5;
				reg_alu_out2	<=	UNDEFINED_32;
				reg_dst2			<=	UNDEFINED_32;
				reg_lmd2			<= UNDEFINED_32;
				reg_pc2			<=	UNDEFINED_32;
				reg_index_dst2 <= UNDEFINED_5;
				
		end if;
	end process;	

	WB_PROCESS:
	process(record_in_crls.reset, record_in_crls.clk) is 
	begin
		if record_in_crls.reset = '0' then
			if rising_edge(record_in_crls.clk) then
				case reg_opcode is
					-- ALU INSTRUCTION REG/IMM (EXCEPT CMP)
					when OPCODE_AND | OPCODE_SUB	| OPCODE_ADD | OPCODE_ADC | OPCODE_SBC |
						  OPCODE_SSUB| OPCODE_SADD| OPCODE_SADC| OPCODE_SSBC| OPCODE_MOV |
						  OPCODE_NOT | OPCODE_SL  | OPCODE_SR  | OPCODE_ASR | OPCODE_UMOV| OPCODE_SMOV =>
						
						--Instruction 1
						wb_record_id.data				<= reg_alu_out;
						wb_record_id.reg_adr			<= reg_dst;
						wb_record_id.write_enable	<= '1';
						wb_record_ex.index_dst		<= reg_index_dst;
						wb_record_ex.dst				<= reg_alu_out;
						
						--Instruction 2
						wb_record_id.data				<= reg_alu_out2;
						wb_record_id.reg_adr			<= reg_dst2;
						wb_record_id.write_enable	<= '1';
						wb_record_ex.index_dst2		<= reg_index_dst2;
						wb_record_ex.dst2				<= reg_alu_out2;
						
					when OPCODE_LOAD =>
						--Instruction 1
						wb_record_id.data				<= reg_lmd;
						wb_record_id.reg_adr			<= reg_dst;
						wb_record_id.write_enable	<= '1';
						wb_record_ex.dst				<= reg_lmd;
						wb_record_ex.index_dst		<= reg_dst(4 downto 0);
						
						--Instruction 2
						wb_record_id.data				<= reg_lmd2;
						wb_record_id.reg_adr			<= reg_dst2;
						wb_record_id.write_enable	<= '1';
						wb_record_ex.dst2				<= reg_lmd2;
						wb_record_ex.index_dst2		<= reg_dst2(4 downto 0);
						
					when OPCODE_BLAL =>
						--Instruction 1
						wb_record_id.data				<= reg_pc;
						wb_record_id.reg_adr			<= LINK_ADDR;   -- Reg 31 (link reg)
						wb_record_id.write_enable	<= '1';
						wb_record_ex.index_dst 		<= UNDEFINED_5;
						wb_record_ex.dst				<= UNDEFINED_32;
						
						--Instruction 2
						wb_record_id.data				<= reg_pc2;
						wb_record_id.reg_adr			<= LINK_ADDR;   -- Reg 31 (link reg)
						wb_record_id.write_enable	<= '1';
						wb_record_ex.index_dst2 	<= UNDEFINED_5;
						wb_record_ex.dst2				<= UNDEFINED_32;
						
					when others =>
						-- NOTHING - ALL UNDEFINED
						--Instruction 1
						wb_record_id.data				<= UNDEFINED_32;
						wb_record_id.reg_adr			<= UNDEFINED_32;
						wb_record_id.write_enable	<= '0';
						wb_record_ex.dst				<= UNDEFINED_32;
						wb_record_ex.index_dst		<= UNDEFINED_5;
						
						--Instruction 2
						wb_record_id.data				<= UNDEFINED_32;
						wb_record_id.reg_adr			<= UNDEFINED_32;
						wb_record_id.write_enable	<= '0';
						wb_record_ex.dst2				<= UNDEFINED_32;
						wb_record_ex.index_dst2		<= UNDEFINED_5;
						
				end case;
			end if;
		else 
		-- RESET = 1;
			--Instruction 1
			wb_record_id.data				<= UNDEFINED_32;
			wb_record_id.reg_adr			<= UNDEFINED_32;
			wb_record_id.write_enable	<= '0';
			wb_record_ex.dst				<= UNDEFINED_32;
			wb_record_ex.index_dst		<= UNDEFINED_5;
			
			--Instruction 2
			wb_record_ex.dst2				<= UNDEFINED_32;
			wb_record_ex.index_dst2		<= UNDEFINED_5;
		end if;
	end process;
	
end arch;