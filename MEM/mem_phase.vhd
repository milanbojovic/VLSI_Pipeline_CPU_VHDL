-- MEM Phase --
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
use IEEE.STD_LOGIC_ARITH.all;

entity MEM_PHASE is
	port
	(	
		-- Input ports
		record_in_crls 		: in CRLS_RCD;	--Clock, Reset, Load, Store
		
		-- EX_Phase
		ex_record_mem			: in EX_MEM_RCD;
				
		-- WB Phase
		mem_record_wb			: out MEM_WB_RCD;
		
		-- DATA CACHE CONNECTIONS
		
		mem_record_data_cache	: out MEMPHASE_DATACACHE_RCD;
		data_cache_record_mem	: in  DATACACHE_MEMPHASE_RCD
	);
end MEM_PHASE;


architecture arch of MEM_PHASE is
	-- REGISTERS
	shared variable reg_opcode 				: OPCODE_TYPE;
	shared variable reg_pc						: REG_TYPE;
	shared variable reg_alu_out				: REG_TYPE;
	shared variable reg_dest					: REG_TYPE;	
	shared variable reg_lmd						: REG_TYPE := UNDEFINED_32;
	
begin
	Load_to_registers :
	process (record_in_crls.load, record_in_crls.reset) begin 

		if (record_in_crls.reset = '0') and (record_in_crls.load = '1') then 		
			reg_opcode 			:= ex_record_mem.opcode;
			reg_pc				:=	ex_record_mem.pc;
			reg_alu_out			:=	ex_record_mem.alu_out;
			reg_dest				:=	ex_record_mem.dst;

		elsif record_in_crls.reset = '1' then
			reg_opcode 			:= UNDEFINED_5;
			reg_pc				:=	UNDEFINED_32;
			reg_alu_out			:=	UNDEFINED_32;
			reg_dest				:=	UNDEFINED_32;		
		end if;
	end process;
	
	mem_phase_process:
	process(record_in_crls.reset, record_in_crls.reset, record_in_crls.clk) is 
		variable step : INTEGER := PHASE_DURATION - 1;
	begin 
		if (record_in_crls.reset = '0') and (rising_edge(record_in_crls.clk)) then
			step := (step + 1) mod PHASE_DURATION;			
			
			if (reg_opcode = OPCODE_LOAD OR reg_opcode = OPCODE_STORE) then
				case step is
					when 0 =>
						mem_record_data_cache.address <= reg_alu_out;
						
						if (reg_opcode = OPCODE_LOAD) then
							--Load Instruction
							mem_record_data_cache.control <= "0010";
						else
							--Store Instruction
							mem_record_data_cache.control <= "0001";
							mem_record_data_cache.dataIn  <= reg_dest;
						end if;
					when 2 =>
						if (reg_opcode = OPCODE_LOAD) then
							--Load Instruction
							reg_lmd := data_cache_record_mem.dataOut;
						elsif reg_opcode = OPCODE_STORE then
							reg_lmd := UNDEFINED_32;
						end if;
					when others  =>
					--nothing
				end case;
			else 
					-- For any other instruction except load/store
					reg_lmd := UNDEFINED_32;
			end if;
			--Signals to register connections
			mem_record_wb.opcode <= reg_opcode;
			mem_record_wb.dst 	<= reg_dest;
			mem_record_wb.alu_out<= reg_alu_out;
			mem_record_wb.lmd 	<= reg_lmd;
			mem_record_wb.pc		<= reg_pc;
			
		elsif record_in_crls.reset = '1' then
		--RESET
			mem_record_wb.opcode <= UNDEFINED_5;
			mem_record_wb.dst 	<= UNDEFINED_32;
			mem_record_wb.alu_out<= UNDEFINED_32;
			mem_record_wb.lmd 	<= UNDEFINED_32;
			mem_record_wb.pc		<= UNDEFINED_32;
		end if;
	end process;	

end arch;