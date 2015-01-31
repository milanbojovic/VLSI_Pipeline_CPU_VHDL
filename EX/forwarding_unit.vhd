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
		
		opcode 						: in OPCODE_TYPE;
		id_index_a					: in REG_ADDR_TYPE;
		id_index_b					: in REG_ADDR_TYPE;
		id_index_dst				: in REG_ADDR_TYPE;
		id_reg_a						: in REG_TYPE;
		id_reg_b						: in REG_TYPE;
		N, C, V, Z					: in std_logic;
		
		-- Output ports			
		branch_instruction		: out SIGNAL_BIT_TYPE;
		imm 							: out SIGNAL_BIT_TYPE;
		branch_cond					: out SIGNAL_BIT_TYPE;
		sig_record_control_out	: out EX_CONTROL_FLUSH_HALT_OUT;	
		out_reg_a, out_reg_b 	: out REG_TYPE
		
    ); 
	 
	 function function_forward_data_to_register(source_index: REG_ADDR_TYPE; source_value: REG_TYPE;
															  mem_record_ex: MEM_EX_RCD; wb_record_ex: WB_EX_RCD) return REG_TYPE; 
	 
end FORWARDING_UNIT;

architecture arch of FORWARDING_UNIT is	

 
	 --Function used to forward value from mem, wb phase to ex_a or ex_b registers
	 function function_forward_data_to_register(source_index: REG_ADDR_TYPE; source_value: REG_TYPE;
															  mem_record_ex: MEM_EX_RCD; wb_record_ex: WB_EX_RCD) return REG_TYPE is 
		variable result : REG_TYPE;
	 begin
		if (source_index = mem_record_ex.index_dst) then 
				result := mem_record_ex.dst;
		
		elsif (source_index = wb_record_ex.index_dst) then
				result := wb_record_ex.dst;
		
		else 
				result := source_value;
		
		end if;
		return result;
    end function_forward_data_to_register;
	
begin	

	set_branch_instruction:
	process(opcode)
	begin
		if(opcode = OPCODE_BEQ or opcode = OPCODE_BGT or opcode = OPCODE_BHI or opcode = OPCODE_BAL or opcode = OPCODE_BLAL)then
			branch_instruction <= '1';
		else
			branch_instruction<= '0';
		end if;
	end process;
	
	
	set_imm:
	process(opcode) is		
	begin
		if (opcode = OPCODE_UMOV or opcode = OPCODE_SMOV) then
			imm <= '1';
		else 
			imm <= '0';
		end if;
	end process;
	
	
	set_control_signals:
	process(opcode, N, C, V, Z, record_in_crls.clk, record_in_crls.reset) is		
	begin
			if rising_edge(record_in_crls.clk) then 
				if record_in_crls.reset = '1' then
					branch_cond <= '0';
					sig_record_control_out.flush_out	<= '0';
					sig_record_control_out.halt_out	<= '0';
					
				else
					case opcode is
						when OPCODE_BEQ =>
							if(Z = '1') then
								branch_cond <= '1';
								sig_record_control_out.flush_out	<= '1';
								sig_record_control_out.halt_out	<= '0';
								
							else
								branch_cond <= '0';
								sig_record_control_out.flush_out	<= '0';
								sig_record_control_out.halt_out	<= '0';
							end if;
						when OPCODE_BGT =>
							if(N = V and Z = '0') then
								branch_cond <= '1';
								sig_record_control_out.flush_out	<= '1';						
								sig_record_control_out.halt_out	<= '0';
							else
								branch_cond <= '0';
								sig_record_control_out.flush_out	<= '0';						
								sig_record_control_out.halt_out	<= '0';
							end if;
						when OPCODE_BHI =>
							if(C = '0' and Z = '0') then
								branch_cond <= '1';
								sig_record_control_out.flush_out	<= '1';
								sig_record_control_out.halt_out	<= '0';
							else
								branch_cond <= '0';
								sig_record_control_out.flush_out	<= '0';
								sig_record_control_out.halt_out	<= '0';
							end if;
							
						when OPCODE_BAL =>
							branch_cond <= '1';
							sig_record_control_out.flush_out	<= '1';
							sig_record_control_out.halt_out	<= '0';
							
						when OPCODE_BLAL =>
							branch_cond <= '1';
							sig_record_control_out.flush_out	<= '1';
							sig_record_control_out.halt_out	<= '0';
						
						when OPCODE_STOP =>
							branch_cond <= '0';
							sig_record_control_out.flush_out	<= '1';
							sig_record_control_out.halt_out	<= '1';
						when others =>
							branch_cond <= '0';
							sig_record_control_out.flush_out	<= '0';
							-- HALT should not be changed because when CPU is halted it should not continue to process instrucitons
					end case;
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
				else
					out_reg_a <= function_forward_data_to_register(id_index_a, id_reg_a, mem_record_ex, wb_record_ex);
					out_reg_b <= function_forward_data_to_register(id_index_b, id_reg_b, mem_record_ex, wb_record_ex);
				end if;
			end if;
	end process;
end arch;