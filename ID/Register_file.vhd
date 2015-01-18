library IEEE; 
library WORK;

use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use WORK.CPU_LIB.all;


entity REG_FILE is

	port
	(
		
		-- Input ports
		DPR      	   		: in STD_LOGIC; 						-- Extract the registers data acording to the DPR instruction's requirements
		DPI						: in STD_LOGIC;						-- Extract the registers data acording to the DPR instruction's requirements
		BRANCH					: in STD_LOGIC;						-- Extract the registers data acording to the DPR instruction's requirements
		LOAD						: in STD_LOGIC;
		STORE						: in STD_LOGIC;
		write_enable			: in STD_LOGIC; 						-- Write enable when data is ready to be writen into the particular register
		operand_A_index		: in REG_ADDR_TYPE; 					-- Operand_A address in register file 
		operand_B_index		: in REG_ADDR_TYPE; 					-- Operand_B address in register file 
		destination_index    : in REG_ADDR_TYPE; 					-- Register index in the register file where the result will be put
		mem_address_index	   : in REG_ADDR_TYPE;					-- Register index which contains the address in memmmory when doing LOAD/STORE instructions 
		store_data_index		: in REG_ADDR_TYPE;					-- Reguster index which contains the data wich will be put in memory with STORE instruction
		input_data				: in REG_TYPE; 						-- Data that would be writen to the register specified by the destination address or store destination
		opcode					: in OPCODE_TYPE;
		immediate				: in IMMEDIATE_TYPE;
		offset					: in BRANCH_OFFSET_TYPE;
		destination_wb			: in REG_TYPE;
		
		
		-- Output ports
		operand_A_out			: out REG_TYPE;
		operand_B_out			: out REG_TYPE;
	   destination_out		: out REG_TYPE;
		immediate_out			: out REG_TYPE;
		offset_out				: out REG_TYPE;
		opcode_out				: out OPCODE_TYPE
		
	);
	
end REG_FILE;


architecture REG_ARCH of REG_FILE is

	shared variable register_array     : REG_FILE_TYPE := init_regs;
	shared variable destination_wb_var : REG_ADDR_TYPE;	
	
begin
		
		
		
		process(DPI, DPR, BRANCH, LOAD, STORE)
			begin	
				if(DPI = '1') then
				
					--Operation with immediate value 
					operand_A_out    <= register_array(TO_INTEGER(UNSIGNED(operand_A_index)));
					destination_out  <= register_array(TO_INTEGER(UNSIGNED(destination_index)));
					
					opcode_out       <= opcode;
					immediate_out    <= func_sign_extend(immediate);
					
				elsif (DPR = '1') then
				
					--Operation with registers
					operand_A_out   <= register_array(TO_INTEGER(UNSIGNED(operand_A_index)));
					operand_B_out   <= register_array(TO_INTEGER(UNSIGNED(operand_B_index)));
					destination_out <= register_array(TO_INTEGER(UNSIGNED(destination_index)));
					
					opcode_out       <= opcode;
					
				elsif (LOAD = '1') then
				
					--Load operation 
					operand_A_out <= register_array(TO_INTEGER(UNSIGNED(mem_address_index)));
					destination_out <= register_array(TO_INTEGER(UNSIGNED(destination_index)));
					
					opcode_out       <= opcode;
					
				elsif (STORE = '1') then
				
					--Store operation 
					destination_out <= register_array(TO_INTEGER(UNSIGNED(store_data_index))); --VIDI DA LI OVO TREBA U JEDAN OD A/B REGISTARA ZA INTERFEJS KA BOJKETU
					operand_A_out <= register_array(TO_INTEGER(UNSIGNED(mem_address_index)));
					
					opcode_out       <= opcode;
					
				elsif (BRANCH = '1') then
					-- BRANCH operation 
					offset_out       <= func_offset_extend(offset);
					
					opcode_out       <= opcode;
					
				end if; 
		end process;
			
		process(write_enable) begin
			if (write_enable = '1') then
				destination_wb_var := destination_wb(4 downto 0);
				register_array(TO_INTEGER(UNSIGNED(destination_wb_var))) := input_data;
			end if;
		end process;

		
end REG_ARCH;

