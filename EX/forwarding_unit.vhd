-- CONTROL_UNIT --
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_LIB.all;
use WORK.CPU_PKG.all;

entity FORWARDING_UNIT is
  port
    (
		-- Input ports
		record_in_crls 			: in CRLS_RCD;
		mem_record_ex				: in MEM_EX_RCD;	-- MEM_PHASE -> EX
		wb_record_ex				: in WB_EX_RCD;	-- WB_PHASE -> EX
		
		alu_1_out					: in REG_TYPE;
		alu_2_out					: in REG_TYPE;

		--Instruction 1
		opcode 						: in OPCODE_TYPE;
		id_index_a					: in REG_ADDR_TYPE;
		id_index_b					: in REG_ADDR_TYPE;
		id_index_dst				: in REG_ADDR_TYPE;
		id_reg_a						: in REG_TYPE;
		id_reg_b						: in REG_TYPE;
		N, C, V, Z					: in std_logic;
		
		--Instruction 2
		opcode2 						: in OPCODE_TYPE;
		id_index_a2					: in REG_ADDR_TYPE;
		id_index_b2					: in REG_ADDR_TYPE;
		id_index_dst2				: in REG_ADDR_TYPE;
		id_reg_a2					: in REG_TYPE;
		id_reg_b2					: in REG_TYPE;
		
		
		-- Output ports			
		--Instruction 1
		branch_instruction		: out SIGNAL_BIT_TYPE;
		imm 							: out SIGNAL_BIT_TYPE;
		out_reg_a, out_reg_b 	: out REG_TYPE;
		out_index_dst				: out REG_ADDR_TYPE;
		
		--Instruction 2
		branch_instruction2		: out SIGNAL_BIT_TYPE;
		imm2 							: out SIGNAL_BIT_TYPE;
		out_reg_a2, out_reg_b2 	: out REG_TYPE;
		out_index_dst2				: out REG_ADDR_TYPE;
		
		--Instruction 1 & 2
		branch_cond					: out SIGNAL_BIT_TYPE;
		ex_pc_if						: out REG_TYPE;
		sig_record_control_out	: out EX_CONTROL_FLUSH_HALT_OUT
		
    ); 
	 
	 function function_forward_data_to_register1(source_index: REG_ADDR_TYPE; source_value: REG_TYPE;
															  mem_record_ex: MEM_EX_RCD; wb_record_ex: WB_EX_RCD) return REG_TYPE; 
															  
	 function function_forward_data_to_register2( source_index: REG_ADDR_TYPE; source_value: REG_TYPE;
															    mem_record_ex: MEM_EX_RCD; wb_record_ex: WB_EX_RCD;
																 alu1_index_dst : REG_ADDR_TYPE;  alu1_out : REG_TYPE
															  ) return REG_TYPE;
end FORWARDING_UNIT;

architecture arch of FORWARDING_UNIT is	

 
	 --Function used to forward value from mem, wb phase to ex_a or ex_b registers
	 function function_forward_data_to_register1(source_index: REG_ADDR_TYPE; source_value: REG_TYPE;
															  mem_record_ex: MEM_EX_RCD; wb_record_ex: WB_EX_RCD) return REG_TYPE is 
		variable result : REG_TYPE;
	 begin
		if (source_index = mem_record_ex.index_dst2) then 
				result := mem_record_ex.dst2;
	
		elsif (source_index = mem_record_ex.index_dst)  then
				result := mem_record_ex.dst;
				
		elsif (source_index = wb_record_ex.index_dst2) then
				result := wb_record_ex.dst2;
				
		elsif (source_index = wb_record_ex.index_dst) then
				result := wb_record_ex.dst;
				
		else 
				result := source_value;
				
		end if;
		return result;
    end function_forward_data_to_register1;
	 
	 
	 function function_forward_data_to_register2( source_index: REG_ADDR_TYPE; source_value: REG_TYPE;
															    mem_record_ex: MEM_EX_RCD; wb_record_ex: WB_EX_RCD;
																 alu1_index_dst : REG_ADDR_TYPE;  alu1_out : REG_TYPE
															  ) return REG_TYPE is 
		variable result : REG_TYPE;
	 begin
	 	if (source_index = alu1_index_dst) then 
				result := alu1_out;
				
		elsif (source_index = mem_record_ex.index_dst2) then 
				result := mem_record_ex.dst2;
	
		elsif (source_index = mem_record_ex.index_dst)  then
				result := mem_record_ex.dst;
				
		elsif (source_index = wb_record_ex.index_dst2) then
				result := wb_record_ex.dst2;
				
		elsif (source_index = wb_record_ex.index_dst) then
				result := wb_record_ex.dst;
				
		else 
				result := source_value;
				
		end if;
		return result;
    end function_forward_data_to_register2;
	 
	 
	
	shared variable flush_out1, flush_out2, halt_out1, halt_out2, branch_cond1, branch_cond2	: SIGNAL_BIT_TYPE := '0';	
	
begin	

	set_branch_instruction1:
	process(opcode)
	begin
		if(opcode = OPCODE_BEQ or opcode = OPCODE_BGT or opcode = OPCODE_BHI or opcode = OPCODE_BAL or opcode = OPCODE_BLAL)then
			branch_instruction <= '1';
		else
			branch_instruction<= '0';
		end if;
	end process;
	
	set_branch_instruction2:
	process(opcode2)
	begin
		if(opcode2 = OPCODE_BEQ or opcode2 = OPCODE_BGT or opcode2 = OPCODE_BHI or opcode2 = OPCODE_BAL or opcode2 = OPCODE_BLAL)then
			branch_instruction2 <= '1';
		else
			branch_instruction2<= '0';
		end if;
	end process;
	
	
	set_imm1:
	process(opcode) is		
	begin
		if (opcode = OPCODE_UMOV or opcode = OPCODE_SMOV) then
			imm <= '1';
		else 
			imm <= '0';
		end if;
	end process;
	
	set_imm2:
	process(opcode2) is		
	begin
		if (opcode2 = OPCODE_UMOV or opcode2 = OPCODE_SMOV) then
			imm2 <= '1';
		else 
			imm2 <= '0';
		end if;
	end process;
	
	
	set_control_signals1:
	process(opcode, N, C, V, Z, record_in_crls.clk, record_in_crls.reset) is		
	begin
			if rising_edge(record_in_crls.clk) then 
				if record_in_crls.reset = '1' then
					branch_cond1:= '0';
					flush_out1	:= '0';
					halt_out1	:= '0';
					
				else
					case opcode is
						when OPCODE_BEQ =>
							if(Z = '1') then
								branch_cond1:= '1';
								flush_out1	:= '1';
								halt_out1	:= '0';
								
							else
								branch_cond1:= '0';
								flush_out1	:= '0';
								halt_out1	:= '0';
							end if;
						when OPCODE_BGT =>
							if(N = V and Z = '0') then
								branch_cond1:= '1';
								flush_out1	:= '1';						
								halt_out1	:= '0';
							else
								branch_cond1:= '0';
								flush_out1	:= '0';						
								halt_out1	:= '0';
							end if;
						when OPCODE_BHI =>
							if(C = '0' and Z = '0') then
								branch_cond1:= '1';
								flush_out1	:= '1';
								halt_out1	:= '0';
							else
								branch_cond1:= '0';
								flush_out1	:= '0';
								halt_out1	:= '0';
							end if;
							
						when OPCODE_BAL =>
							branch_cond1:= '1';
							flush_out1	:= '1';
							halt_out1	:= '0';
							
						when OPCODE_BLAL =>
							branch_cond1:= '1';
							flush_out1	:= '1';
							halt_out1	:= '0';
						
						when OPCODE_STOP =>
							branch_cond1:= '0';
							flush_out1	:= '1';
							halt_out1	:= '1';
						when others =>
							branch_cond1:= '0';
							flush_out1	:= '0';
							-- HALT should not be changed because when CPU is halted it should not continue to process instrucitons
					end case;
				end if;
			end if;
	end process;
	
	
	
	set_control_signals2:
	process(opcode2, N, C, V, Z, record_in_crls.clk, record_in_crls.reset) is		
	begin
			if rising_edge(record_in_crls.clk) then 
				if record_in_crls.reset = '1' then
					branch_cond2:= '0';
					flush_out2	:= '0';
					halt_out2	:= '0';
				else
					case opcode2 is
						when OPCODE_BEQ =>
							if(Z = '1') then
								branch_cond2:= '1';
								flush_out2	:= '1';
								halt_out2	:= '0';
								
							else
								branch_cond2:= '0';
								flush_out2	:= '0';
								halt_out2	:= '0';
							end if;
						when OPCODE_BGT =>
							if(N = V and Z = '0') then
								branch_cond2:= '1';
								flush_out2	:= '1';						
								halt_out2	:= '0';
							else
								branch_cond2:= '0';
								flush_out2	:= '0';						
								halt_out2	:= '0';
							end if;
						when OPCODE_BHI =>
							if(C = '0' and Z = '0') then
								branch_cond2:= '1';
								flush_out2	:= '1';
								halt_out2	:= '0';
							else
								branch_cond2:= '0';
								flush_out2	:= '0';
								halt_out2	:= '0';
							end if;
							
						when OPCODE_BAL =>
							branch_cond2:= '1';
							flush_out2	:= '1';
							halt_out2	:= '0';
							
						when OPCODE_BLAL =>
							branch_cond2:= '1';
							flush_out2	:= '1';
							halt_out2	:= '0';
						
						when OPCODE_STOP =>
							branch_cond2:= '0';
							flush_out2	:= '1';
							halt_out2	:= '1';
						when others =>
							branch_cond2:= '0';
							flush_out2	:= '0';
							-- HALT should not be changed because when CPU is halted it should not continue to process instrucitons
					end case;
				end if;
			end if;
	end process;
	
	BRANCH_COND_PROCESS: --which sets branch condition and PC
	process (record_in_crls.clk) 
	variable bc_var :	SIGNAL_BIT_TYPE;
	begin
		sig_record_control_out.halt_out 	<= halt_out1		or 	halt_out2;
		sig_record_control_out.flush_out <= flush_out1		or 	flush_out2;
		bc_var		 							:= branch_cond1	or 	branch_cond2;
		branch_cond 							<= bc_var;
		
		if(bc_var = '0') then
			ex_pc_if 		<= UNDEFINED_32;
		else
			if (branch_cond1 = '1') then
				ex_pc_if 	<= alu_1_out;
			else
				ex_pc_if 	<= alu_2_out;
			end if;
		end if;
	end process;
	
	
	forwarding_process:
	process(record_in_crls.clk, record_in_crls.reset) is		
	begin
			if rising_edge(record_in_crls.clk) then 
				if record_in_crls.reset = '1' then
					
					out_reg_a <= "00000000000000000000000000000000";
					out_reg_b <= "00000000000000000000000000000000";
					
					out_reg_a2 <= "00000000000000000000000000000000";
					out_reg_b2 <= "00000000000000000000000000000000";
					
					out_index_dst  <= "00000";
					out_index_dst2 <= "00000";
				else
					--Instruction 1
					if (opcode /= OPCODE_LOAD) and (opcode /= OPCODE_STORE) then
							--For all instructions except LOAD/STORE
							out_reg_a <= function_forward_data_to_register1(id_index_a, id_reg_a, mem_record_ex, wb_record_ex);
							out_reg_b <= function_forward_data_to_register1(id_index_b, id_reg_b, mem_record_ex, wb_record_ex);
							out_index_dst <= id_index_dst;
					else
							--For LOAD/STORE instructions
							out_reg_a <= id_reg_a;
							out_reg_b <= id_reg_b;
							out_index_dst <= function_forward_data_to_register1(id_index_dst, ZERO_27 & id_index_dst, mem_record_ex, wb_record_ex)(4  downto 0);
					end if;
					--Instruction 2
					if (opcode2 /= OPCODE_LOAD) and (opcode2 /= OPCODE_STORE) then
							--For all instructions except LOAD/STORE					
							out_reg_a2 <= function_forward_data_to_register2(id_index_a2,  id_reg_a2, mem_record_ex,
																							 wb_record_ex, id_index_dst, alu_1_out
																							 );																 
							out_reg_b2 <= function_forward_data_to_register2(id_index_b2,  id_reg_b2, mem_record_ex, 
																							 wb_record_ex, id_index_dst, alu_1_out
																							 );
							out_index_dst2 <= id_index_dst2;
					else
							--For LOAD/STORE instructions
							out_reg_a2 <= id_reg_a2;
							out_reg_b2 <= id_reg_b2;
							out_index_dst2 <= function_forward_data_to_register1(id_index_dst2, ZERO_27 & id_index_dst2, mem_record_ex, wb_record_ex)(4  downto 0);
					end if;
				end if;
			end if;
	end process;
end arch;