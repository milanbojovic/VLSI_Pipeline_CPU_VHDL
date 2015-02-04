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
		
		-- MEM -> EX_Phase
		mem_record_ex			: out MEM_EX_RCD;

		-- DATA CACHE CONNECTIONS

		mem_record_data_cache	: out MEMPHASE_DATACACHE_RCD;
		data_cache_record_mem	: in  DATACACHE_MEMPHASE_RCD
	);
end MEM_PHASE;


architecture arch of MEM_PHASE is
	-- REGISTERS
	--Instruction 1
	shared variable reg_opcode 				: OPCODE_TYPE;
	shared variable reg_pc						: REG_TYPE;
	shared variable reg_alu_out				: REG_TYPE;
	shared variable reg_dest					: REG_TYPE;
	shared variable reg_index_dst				: REG_ADDR_TYPE;
	shared variable reg_lmd						: REG_TYPE := UNDEFINED_32;
	
	--Instruction 2
	shared variable reg_opcode2 				: OPCODE_TYPE;
	shared variable reg_pc2						: REG_TYPE;
	shared variable reg_alu_out2				: REG_TYPE;
	shared variable reg_dest2					: REG_TYPE;
	shared variable reg_index_dst2			: REG_ADDR_TYPE;
	shared variable reg_lmd2					: REG_TYPE := UNDEFINED_32;

begin	

	Load_to_registers :
	process (record_in_crls.load, record_in_crls.reset) begin

		if (record_in_crls.reset = '0') and (record_in_crls.load = '1') then
			--Instruction 1
			reg_opcode 						:= ex_record_mem.opcode;
			reg_pc							:=	ex_record_mem.pc;
			reg_alu_out						:=	ex_record_mem.alu_out;
			reg_dest							:=	ex_record_mem.dst;
			reg_index_dst					:= ex_record_mem.index_dst;

			--Instruction 2
			reg_opcode2 					:= ex_record_mem.opcode2;
			reg_pc2							:=	ex_record_mem.pc2;
			reg_alu_out2					:=	ex_record_mem.alu_out2;
			reg_dest2						:=	ex_record_mem.dst2;
			reg_index_dst2					:= ex_record_mem.index_dst2;
			
		elsif record_in_crls.reset = '1' then
			--Instruction 1
			reg_opcode 			:= UNDEFINED_5;
			reg_pc				:=	UNDEFINED_32;
			reg_alu_out			:=	UNDEFINED_32;
			reg_dest				:=	UNDEFINED_32;
			reg_index_dst		:= UNDEFINED_5;
			
			--Instruction 2
			reg_opcode2 		:= UNDEFINED_5;
			reg_pc2				:=	UNDEFINED_32;
			reg_alu_out2		:=	UNDEFINED_32;
			reg_dest2			:=	UNDEFINED_32;
			reg_index_dst2		:= UNDEFINED_5;
			
		end if;
	end process;

	mem_phase_process:
	process(record_in_crls.reset, record_in_crls.reset, record_in_crls.clk) is
		variable step : INTEGER := PHASE_DURATION - 1;
	begin
		--Instruction 1
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
			
						
			
			--Instruction 2
			if (reg_opcode2 = OPCODE_LOAD OR reg_opcode2 = OPCODE_STORE) then
			  case step is
				 when 3 =>
					mem_record_data_cache.address <= reg_alu_out2;

					if (reg_opcode2 = OPCODE_LOAD) then
					  --Load Instruction
					  mem_record_data_cache.control <= "0010";
					else
					  --Store Instruction
					  mem_record_data_cache.control <= "0001";
					  mem_record_data_cache.dataIn  <= reg_dest2;
					end if;
				 when 5 =>
					if (reg_opcode2 = OPCODE_LOAD) then
					  --Load Instruction
					  reg_lmd2 := data_cache_record_mem.dataOut;
					elsif reg_opcode2 = OPCODE_STORE then
					  reg_lmd2 := UNDEFINED_32;
					end if;
				 when others  =>
				 --nothing
			  end case;
			else
				 -- For any other instruction except load/store
				 reg_lmd2 := UNDEFINED_32;
			end if;
			
			
			--Signals to register connections
			--Instruction 1
			mem_record_wb.opcode 		<= reg_opcode;
			mem_record_wb.dst 			<= reg_dest;
			mem_record_wb.alu_out		<= reg_alu_out;
			mem_record_wb.lmd 			<= reg_lmd;
			mem_record_wb.pc				<= reg_pc;
			mem_record_wb.index_dst		<= reg_index_dst;
			
			mem_record_ex.index_dst		<= reg_index_dst;
			mem_record_ex.dst				<= reg_alu_out;

			--Instruction 2
			mem_record_wb.opcode2 		<= reg_opcode2;
			mem_record_wb.dst2 			<= reg_dest2;
			mem_record_wb.alu_out2		<= reg_alu_out2;
			mem_record_wb.lmd2 			<= reg_lmd2;
			mem_record_wb.pc2				<= reg_pc2;
			mem_record_wb.index_dst2	<= reg_index_dst2;
			
			mem_record_ex.index_dst2	<= reg_index_dst2;
			mem_record_ex.dst2			<= reg_alu_out2;
			
		elsif (record_in_crls.reset = '1') then
			--RESET
			--Instruction 1
			mem_record_wb.opcode 		<= UNDEFINED_5;
			mem_record_wb.dst 			<= UNDEFINED_32;
			mem_record_wb.alu_out		<= UNDEFINED_32;
			mem_record_wb.lmd 			<= UNDEFINED_32;
			mem_record_wb.pc				<= UNDEFINED_32;
			mem_record_wb.index_dst		<= UNDEFINED_5;
			
			mem_record_ex.index_dst		<= UNDEFINED_5;
			mem_record_ex.dst				<= UNDEFINED_32;
			
			--Instruction 2
			mem_record_wb.opcode2 		<= UNDEFINED_5;
			mem_record_wb.dst2 			<= UNDEFINED_32;
			mem_record_wb.alu_out2		<= UNDEFINED_32;
			mem_record_wb.lmd2 			<= UNDEFINED_32;
			mem_record_wb.pc2				<= UNDEFINED_32;
			mem_record_wb.index_dst2	<= UNDEFINED_5;
			
			mem_record_ex.index_dst2	<= UNDEFINED_5;
			mem_record_ex.dst2			<= UNDEFINED_32;
		end if;
	end process;

end arch;
