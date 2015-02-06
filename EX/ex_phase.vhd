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
	
	--Instruction 1 
	--signal alu1_enable	: SIGNAL_BIT_TYPE;
	signal alu2_enable	: SIGNAL_BIT_TYPE;
	
	--Instruction 1
	signal reg_opcode 				: OPCODE_TYPE;
	signal reg_pc						: REG_TYPE;
	signal reg_a, reg_b				: REG_TYPE;
	signal reg_immediate				: REG_TYPE;
	signal reg_branch_offset		: REG_TYPE;
	signal reg_destionation			: REG_TYPE;
	signal reg_index_a				: REG_ADDR_TYPE;
	signal reg_index_b				: REG_ADDR_TYPE;
	signal reg_index_dst				: REG_ADDR_TYPE;
	
	--Instruction 2
	signal reg_opcode2 				: OPCODE_TYPE;
	signal reg_pc2						: REG_TYPE;
	signal reg_a2, reg_b2			: REG_TYPE;
	signal reg_immediate2			: REG_TYPE;
	signal reg_branch_offset2		: REG_TYPE;
	signal reg_destionation2		: REG_TYPE;
	signal reg_index_a2				: REG_ADDR_TYPE;
	signal reg_index_b2				: REG_ADDR_TYPE;
	signal reg_index_dst2			: REG_ADDR_TYPE;
	
	-- SIGNALS
	-- Mux_A
	--Instruction 1
	signal sig_regA_to_muxA			: REG_TYPE;
	signal sig_regPc_to_muxA		: REG_TYPE;
	signal sig_muxA_to_aluA			: REG_TYPE;
	
	--Instruction 2
	signal sig_regA2_to_muxA2		: REG_TYPE;
	signal sig_regPc2_to_muxA2		: REG_TYPE;
	signal sig_muxA2_to_aluA2		: REG_TYPE;
	
	-- MUX_B0
	--Instruction 1
	signal sig_regB_to_muxB0		: REG_TYPE;
	signal sig_regImm_to_muxB0		: REG_TYPE;
	signal sig_muxB0_to_muxB1		: REG_TYPE;
	
	--Instruction 2
	signal sig_regB2_to_muxB20		: REG_TYPE;
	signal sig_regImm2_to_muxB20	: REG_TYPE;
	signal sig_muxB20_to_muxB21	: REG_TYPE;
	
	
	-- MUX_B1
	--Instruction 1
	signal sig_regBrOff_to_muxB1	: REG_TYPE;
	signal sig_muxB1_to_aluB		: REG_TYPE;
	
	--Instruction 2
	signal sig_regBrOff2_to_muxB21: REG_TYPE;
	signal sig_muxB21_to_aluB2		: REG_TYPE;
	
	--Mux selector signals
	--Instruction 1
	signal sig_Imm						: SIGNAL_BIT_TYPE;
	signal sig_branch_instruction : SIGNAL_BIT_TYPE;
	
	--Instruction 2
	signal sig_Imm2					: SIGNAL_BIT_TYPE;
	signal sig_branch_instruction2: SIGNAL_BIT_TYPE;
	
	--Instruction 1
	signal sig_opcode					: OPCODE_TYPE;
	
	--Instruction 2
	signal sig_opcode2				: OPCODE_TYPE;
	
	
	signal sig_cond 					: SIGNAL_BIT_TYPE;
	signal sig_ex_pc_if				: REG_TYPE;
	signal sig_record_control_out	: EX_CONTROL_FLUSH_HALT_OUT;
	
	--Ako me ne bude mrzelo mogu da pretvorim signale n, z, v, c u rekorde kao sto je zakomentarisano ovde ispod
	--signal sig_record_csr_out	: CSR_RCD;
	--signal sig_record_csr_in		: CSR_RCD;
	
	--Instruction 1
	signal sig_csr_negative_in 	: SIGNAL_BIT_TYPE;
	signal sig_csr_carry_in	 		: SIGNAL_BIT_TYPE;
	signal sig_csr_overflow_in 	: SIGNAL_BIT_TYPE;
	signal sig_csr_zero_in 	 		: SIGNAL_BIT_TYPE;
	
	signal sig_csr_negative_out	: SIGNAL_BIT_TYPE;
	signal sig_csr_carry_out		: SIGNAL_BIT_TYPE;
	signal sig_csr_overflow_out	: SIGNAL_BIT_TYPE;
	signal sig_csr_zero_out 		: SIGNAL_BIT_TYPE;
	
	--Instruction 2
	signal sig_csr_negative_in2 	: SIGNAL_BIT_TYPE;
	signal sig_csr_carry_in2 		: SIGNAL_BIT_TYPE;
	signal sig_csr_overflow_in2 	: SIGNAL_BIT_TYPE;
	signal sig_csr_zero_in2	 		: SIGNAL_BIT_TYPE;
	
	--Instruction 1
	signal sig_alu_out				: REG_TYPE := ZERO_32;
	--Instruction 2
	signal sig_alu_out2				: REG_TYPE := ZERO_32;
	
	signal sig_index_dst 			: OPCODE_TYPE;
	signal sig_index_dst2 			: OPCODE_TYPE;
begin

		--Instruction 1
		COMP_MUX_A	 		: entity work.MUX_2_IN_1(arch) 	port map (sig_regA_to_muxA, sig_regPc_to_muxA, sig_branch_instruction, sig_muxA_to_aluA);	
		COMP_MUX_B0 		: entity work.MUX_2_IN_1(arch) 	port map (sig_regB_to_muxB0, sig_regImm_to_muxB0, sig_Imm, sig_muxB0_to_muxB1);
		COMP_MUX_B1 		: entity work.MUX_2_IN_1(arch) 	port map (sig_muxB0_to_muxB1, sig_regBrOff_to_muxB1, sig_branch_instruction, sig_muxB1_to_aluB);
		
		COMP_ALU		 		: entity work.ALU(arch) 			port map (sig_opcode, sig_muxA_to_aluA, sig_muxB1_to_aluB,
																						 sig_csr_negative_out, sig_csr_carry_out, sig_csr_overflow_out, sig_csr_zero_out,
																						 sig_alu_out,
																						 sig_csr_negative_in, sig_csr_carry_in, sig_csr_overflow_in, sig_csr_zero_in
																						);
	
		--Instruction 2
		COMP_MUX_A2	 		: entity work.MUX_2_IN_1(arch) 	port map (sig_regA2_to_muxA2, sig_regPc2_to_muxA2, sig_branch_instruction2, sig_muxA2_to_aluA2);		
		COMP_MUX_B20 		: entity work.MUX_2_IN_1(arch) 	port map (sig_regB2_to_muxB20, sig_regImm2_to_muxB20, sig_Imm2, sig_muxB20_to_muxB21);
		COMP_MUX_B21 		: entity work.MUX_2_IN_1(arch) 	port map (sig_muxB20_to_muxB21, sig_regBrOff2_to_muxB21, sig_branch_instruction2, sig_muxB21_to_aluB2);
		
		COMP_ALU2	 		: entity work.ALU(arch) 			port map (sig_opcode2, sig_muxA2_to_aluA2, sig_muxB21_to_aluB2,
																						 sig_csr_negative_out, sig_csr_carry_out, sig_csr_overflow_out, sig_csr_zero_out,
																						 sig_alu_out2,
																						 sig_csr_negative_in2, sig_csr_carry_in2, sig_csr_overflow_in2, sig_csr_zero_in2
																						);

		COMP_CSR_REG			: entity work.CSR(arch) 		port map (record_in_crls.load, record_in_crls.reset, alu2_enable,
																						 sig_csr_negative_in,  sig_csr_carry_in,  sig_csr_overflow_in,  sig_csr_zero_in,
																						 sig_csr_negative_in2, sig_csr_carry_in2, sig_csr_overflow_in2, sig_csr_zero_in2,
																						 sig_csr_negative_out, sig_csr_carry_out, sig_csr_overflow_out, sig_csr_zero_out
																						);



	
		COMP_FORWARDING_UNIT : entity work.FORWARDING_UNIT (arch) port map ( record_in_crls,mem_record_ex,wb_record_ex,
																									sig_alu_out, sig_alu_out2, 
																									sig_opcode,
																									reg_index_a, reg_index_b, reg_index_dst, reg_a, reg_b,	
																									sig_csr_negative_out, sig_csr_carry_out, sig_csr_overflow_out, sig_csr_zero_out,
																									sig_opcode2,
																									reg_index_a2, reg_index_b2, reg_index_dst2, reg_a2, reg_b2,
																									sig_branch_instruction,  sig_Imm,	sig_regA_to_muxA,   sig_regB_to_muxB0, sig_index_dst,
																									sig_branch_instruction2, sig_Imm2,	sig_regA2_to_muxA2, sig_regB2_to_muxB20, sig_index_dst2,
																									sig_cond, sig_ex_pc_if, sig_record_control_out
																								 );		
		--Instruction 1
		sig_opcode 						<= reg_opcode;
		sig_regPc_to_muxA 			<= reg_pc;
		sig_regImm_to_muxB0			<= reg_immediate;
		sig_regBrOff_to_muxB1		<=	reg_branch_offset;
		
		ex_record_mem.alu_out 		<= sig_alu_out;
		ex_record_mem.opcode  		<= sig_opcode;
		ex_record_mem.dst				<= ZERO_27 & sig_index_dst;
		ex_record_mem.pc				<= reg_pc;
		ex_record_mem.index_dst		<= reg_index_dst;
		
		--Instruction 2
		sig_opcode2						<= reg_opcode2;
		sig_regPc2_to_muxA2 			<= reg_pc2;
		sig_regImm2_to_muxB20		<= reg_immediate2;
		sig_regBrOff2_to_muxB21		<=	reg_branch_offset2;
		
		ex_record_mem.alu_out2 		<= sig_alu_out2;
		ex_record_mem.opcode2 		<= sig_opcode2;
		ex_record_mem.dst2			<= ZERO_27 & sig_index_dst2;
		ex_record_mem.pc2				<= reg_pc2;
		ex_record_mem.index_dst2	<= reg_index_dst2;


		ex_record_if.branch_cond 	<= sig_cond;
		ex_record_if.flush_out		<= sig_record_control_out.flush_out;
		ex_record_if.halt_out		<= sig_record_control_out.halt_out;
		ex_record_id.flush_out		<= sig_record_control_out.flush_out;
		
		
	process (record_in_crls.load, record_in_crls.reset) begin 
		if (record_in_crls.reset = '0') and (record_in_crls.load = '1') and (sig_record_control_out.flush_out = '0') then 		
		
			--Instruction 1
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
			
			--Instruction 2
			reg_opcode2			<= id_record_ex.opcode2;
			reg_pc2				<=	id_record_ex.pc2;
			reg_a2				<=	id_record_ex.a2;
			reg_index_a2		<= id_record_ex.index_a2;
			reg_b2				<=	id_record_ex.b2;
			reg_index_b2		<= id_record_ex.index_b2;
			reg_immediate2		<=	id_record_ex.immediate2;
			reg_branch_offset2<=	id_record_ex.branch_offset2;
			reg_destionation2	<= id_record_ex.dst2;
			reg_index_dst2		<= id_record_ex.index_dst2;
			
		elsif	(record_in_crls.reset = '1') then
			
			--Instruction 1
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
			
			--Instruction 2
			reg_opcode2			<= UNDEFINED_5;
			reg_pc2				<=	UNDEFINED_32;
			reg_a2				<=	UNDEFINED_32;
			reg_b2				<=	UNDEFINED_32;
			reg_immediate2		<=	UNDEFINED_32;
			reg_branch_offset2<=	UNDEFINED_32;
			reg_destionation2	<= UNDEFINED_32;
			reg_index_a2		<= UNDEFINED_5;
			reg_index_b2		<= UNDEFINED_5;
			reg_index_dst2		<= UNDEFINED_5;
			
		elsif (sig_record_control_out.flush_out = '1') then 
			--Logic to flush only one instruction from EX phase which need's to be flushed !!!
			if (sig_ex_pc_if = sig_alu_out) then
				-- If 1st instruction jumps ==> flush instruction2!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				
				--Instruction 1
--				reg_opcode 			<= UNDEFINED_5;
--				reg_pc 				<=	UNDEFINED_32;
--				reg_a 				<=	UNDEFINED_32;
--				reg_b 				<=	UNDEFINED_32;
--				reg_immediate 		<=	UNDEFINED_32;
--				reg_branch_offset <=	UNDEFINED_32;
--				reg_destionation 	<= UNDEFINED_32;
--				reg_index_a 		<= UNDEFINED_5;
--				reg_index_b 		<= UNDEFINED_5;
--				reg_index_dst 		<= UNDEFINED_5;
				
				--Instruction 2
				if (reg_opcode2 /= OPCODE_STOP) then
				--Stop instruction should continue to next stage
					reg_opcode2			<= UNDEFINED_5;
					reg_pc2				<=	UNDEFINED_32;
					reg_a2				<=	UNDEFINED_32;
					reg_b2				<=	UNDEFINED_32;
					reg_immediate2		<=	UNDEFINED_32;
					reg_branch_offset2<=	UNDEFINED_32;
					reg_destionation2	<= UNDEFINED_32;
					reg_index_a2		<= UNDEFINED_5;
					reg_index_b2		<= UNDEFINED_5;
					reg_index_dst2		<= UNDEFINED_5;
				end if;
			end if;
		end if;
	end process;
end arch;
