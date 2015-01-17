-- EX Phase --
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
use WORK.ID_EX_PKG.all;
use WORK.EX_IF_PKG.all;
use WORK.EX_MEM_PKG.all;

entity EX_PHASE is
	port
	(	
		-- Input ports
		record_in_crls 		: in CRLS_RCD;		--Clock, Reset, Load, Store		
		id_record_ex			: in ID_EX_RCD;
		
		-- Output ports
		-- IF_PHASE
		ex_record_if			: out EX_IF_RCD;
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
																					
		COMP_CSR_REG		: entity work.CSR(arch) 			port map (record_in_crls.clk, record_in_crls.load, record_in_crls.reset, 
																						 sig_csr_negative_in,  sig_csr_carry_in,  sig_csr_overflow_in,  sig_csr_zero_in,
																						 sig_csr_negative_out, sig_csr_carry_out, sig_csr_overflow_out, sig_csr_zero_out
																						);
																					
		COMP_CONTROL_UNIT	: entity work.CONTROL_UNIT(arch) port map (sig_opcode, 
																						 sig_csr_negative_out, sig_csr_carry_out, sig_csr_overflow_out, sig_csr_zero_out,
																						 sig_branch_instruction, sig_Imm, sig_cond
																						);
		sig_opcode <= reg_opcode;
		sig_regPc_to_muxA 			<= reg_pc;
		sig_regA_to_muxA 				<= reg_a;
		sig_regB_to_muxB0				<= reg_b;
		sig_regImm_to_muxB0			<= reg_immediate;
		sig_rebBrOff_to_muxB1		<=	reg_branch_offset;
		
		ex_record_if.pc 				<= sig_alu_out;
		ex_record_mem.alu_out 		<= sig_alu_out;
		ex_record_mem.opcode  		<= sig_opcode;
		
		ex_record_if.branch_cond 	<= sig_cond;
		ex_record_mem.dst				<= reg_destionation;
		ex_record_mem.pc				<= reg_pc;
		
	load_to_registers:
	process(record_in_crls.clk, id_record_ex) is 
		-- Declaration(s) 
	begin 
		if record_in_crls.clk = '1' then
			reg_opcode 			<= id_record_ex.opcode;
			reg_pc				<=	id_record_ex.pc;
			reg_a					<=	id_record_ex.a;
			reg_b					<=	id_record_ex.b;
			reg_immediate		<=	id_record_ex.immediate;
			reg_branch_offset	<=	id_record_ex.branch_offset;
			reg_destionation	<= id_record_ex.dst;
		end if;
	end process;

end arch;