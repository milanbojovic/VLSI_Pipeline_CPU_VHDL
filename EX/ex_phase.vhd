-- EX Phase --
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;

entity EX_PHASE is
	port
	(	
		-- Input ports
		record_in_crls 		: in CRLS_RCD;		--Clock, Reset, Load, Store		
		id_record_ex			: in ID_EX_RCD;
		
		--NOVI REKORDI
		wb_record_ex			: in WB_EX_RCD;
		mem_record_ex			: in MEM_EX_RCD;
		
		-- Output ports
		-- IF_PHASE
		ex_record_if			: out EX_IF_RCD;
		
		-- ID_PHASE
		ex_record_id			: out EX_ID_RCD;
		
		-- MEM_PHASE
		ex_record_mem			: out EX_MEM_RCD
		
	);
end EX_PHASE;

architecture arch of EX_PHASE is
	-- REGISTERS
	signal reg_opcode 				: OPCODE_TYPE;
	signal reg_pc						: REG_TYPE;
	signal reg_a, reg_b				: REG_TYPE;
	signal reg_immediate				: REG_TYPE;
	signal reg_branch_offset		: REG_TYPE;
	signal reg_destionation			: REG_TYPE;
	signal reg_index_a				: REG_ADDR_TYPE;
	signal reg_index_b				: REG_ADDR_TYPE;
	signal reg_index_dst				: REG_ADDR_TYPE;
	-- SIGNALS
	-- Mux_A
	signal sig_regA_to_muxA			: REG_TYPE;
	signal sig_regPc_to_muxA		: REG_TYPE;
	signal sig_muxA_to_aluA			: REG_TYPE;
	
	-- MUX_B0
	signal sig_regB_to_muxB0		: REG_TYPE;
	signal sig_regImm_to_muxB0		: REG_TYPE;
	signal sig_muxB0_to_muxB1		: REG_TYPE;
	
	-- MUX_B1
	signal sig_rebBrOff_to_muxB1	: REG_TYPE;
	signal sig_muxB1_to_aluB		: REG_TYPE;
	
	--Mux selector signals
	signal sig_Imm						: SIGNAL_BIT_TYPE;
	signal sig_branch_instruction : SIGNAL_BIT_TYPE;
	
	
	signal sig_opcode					: OPCODE_TYPE;
	signal sig_cond 					: SIGNAL_BIT_TYPE;
	
	signal sig_record_control_out	: EX_CONTROL_FLUSH_HALT_OUT;
	
	--Ako me ne bude mrzelo mogu da pretvorim signale n, z, v, c u rekorde ako sto je zakomentarisano ovde ispod
	--signal sig_record_csr_out	: CSR_RCD;
	--signal sig_record_csr_in		: CSR_RCD;
	
	signal sig_csr_negative_in 	: SIGNAL_BIT_TYPE;
	signal sig_csr_carry_in	 		: SIGNAL_BIT_TYPE;
	signal sig_csr_overflow_in 	: SIGNAL_BIT_TYPE;
	signal sig_csr_zero_in 	 		: SIGNAL_BIT_TYPE;
	
	signal sig_csr_negative_out	: SIGNAL_BIT_TYPE;
	signal sig_csr_carry_out		: SIGNAL_BIT_TYPE;
	signal sig_csr_overflow_out	: SIGNAL_BIT_TYPE;
	signal sig_csr_zero_out 		: SIGNAL_BIT_TYPE;
	
	signal sig_alu_out				: REG_TYPE := ZERO_32;

begin
		
		COMP_MUX_A	 		: entity work.MUX_2_IN_1(arch) 	port map (sig_regA_to_muxA, sig_regPc_to_muxA, sig_branch_instruction, sig_muxA_to_aluA);	
		COMP_MUX_B0 		: entity work.MUX_2_IN_1(arch) 	port map (sig_regB_to_muxB0, sig_regImm_to_muxB0, sig_Imm, sig_muxB0_to_muxB1);
		COMP_MUX_B1 		: entity work.MUX_2_IN_1(arch) 	port map (sig_muxB0_to_muxB1, sig_rebBrOff_to_muxB1, sig_branch_instruction, sig_muxB1_to_aluB);
		
		COMP_ALU		 		: entity work.ALU(arch) 			port map (sig_opcode, sig_muxA_to_aluA, sig_muxB1_to_aluB,
																						 sig_csr_negative_out, sig_csr_carry_out, sig_csr_overflow_out, sig_csr_zero_out,
																						 sig_alu_out,
																						 sig_csr_negative_in, sig_csr_carry_in, sig_csr_overflow_in, sig_csr_zero_in
																						);
																					
		COMP_CSR_REG			: entity work.CSR(arch) 		port map (record_in_crls.load, record_in_crls.reset, 
																						 sig_csr_negative_in,  sig_csr_carry_in,  sig_csr_overflow_in,  sig_csr_zero_in,
																						 sig_csr_negative_out, sig_csr_carry_out, sig_csr_overflow_out, sig_csr_zero_out
																						);
																					
		COMP_FORWARDING_UNIT : entity work.FORWARDING_UNIT (arch) port map ( record_in_crls,mem_record_ex,wb_record_ex,
																									sig_opcode,
																									reg_index_a, reg_index_b, reg_index_dst, reg_a, reg_b,	
																									sig_csr_negative_out, sig_csr_carry_out, sig_csr_overflow_out, sig_csr_zero_out,
																									sig_branch_instruction, sig_Imm, sig_cond, sig_record_control_out, 
																									sig_regA_to_muxA, sig_regB_to_muxB0
																								 );
																						
		sig_opcode 						<= reg_opcode;
		sig_regPc_to_muxA 			<= reg_pc;
		sig_regImm_to_muxB0			<= reg_immediate;
		sig_rebBrOff_to_muxB1		<=	reg_branch_offset;
		
		ex_record_mem.alu_out 		<= sig_alu_out;
		ex_record_mem.opcode  		<= sig_opcode;
		ex_record_mem.dst				<= reg_destionation;
		ex_record_mem.pc				<= reg_pc;
		ex_record_mem.index_dst		<= reg_index_dst;
		
		ex_record_if.branch_cond 	<= sig_cond;
		ex_record_if.flush_out		<= sig_record_control_out.flush_out;
		ex_record_if.halt_out		<= sig_record_control_out.halt_out;
		
		ex_record_id.flush_out		<= sig_record_control_out.flush_out;

	
	--Process for setting signals which are not needed by certain instructions
	process (record_in_crls.clk) begin
		case reg_opcode is
		
			when OPCODE_BEQ | OPCODE_BGT | OPCODE_BHI | OPCODE_BAL | OPCODE_BLAL =>
				ex_record_if.pc 		<= sig_alu_out;
			when others =>
				ex_record_if.pc 		<= UNDEFINED_32;
		end case;					
	end process;
	
		
	process (record_in_crls.load, record_in_crls.reset) begin 
		if (record_in_crls.reset = '0') and (record_in_crls.load = '1') then 		
			reg_opcode 			<= id_record_ex.opcode;
			reg_pc				<=	id_record_ex.pc;
			reg_a					<=	id_record_ex.a;
			reg_index_a			<= id_record_ex.index_a;
			reg_b					<=	id_record_ex.b;
			reg_index_b			<= id_record_ex.index_b;
			reg_immediate		<=	id_record_ex.immediate;
			reg_branch_offset	<=	id_record_ex.branch_offset;
			reg_destionation	<= id_record_ex.dst;
			reg_index_dst		<= id_record_ex.index_dst;
			
		elsif	(record_in_crls.reset = '1') then
			reg_opcode 			<= UNDEFINED_5	;
			reg_pc				<=	UNDEFINED_32;
			reg_a					<=	UNDEFINED_32;
			reg_b					<=	UNDEFINED_32;
			reg_immediate		<=	UNDEFINED_32;
			reg_branch_offset	<=	UNDEFINED_32;
			reg_destionation	<= UNDEFINED_32;
			reg_index_a       <= UNDEFINED_5;
			reg_index_b 		<= UNDEFINED_5;
			reg_index_dst		<= UNDEFINED_5;

		end if;
	end process;
end arch;
