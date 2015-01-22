--IF Phase--
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
use IEEE.STD_LOGIC_ARITH.all;

entity IF_PHASE is
	port
	(	
		--Clock, Reset, Load, Store
		record_in_crls 		: in CRLS_RCD;	
		
		-- EX_PHASE
		ex_record_if			: in EX_IF_RCD;
				
		-- Output to ID phase
		if_record_id			: out IF_ID_RCD;	
		
		-- INSTRUCTION CACHE CONNECTIONS
		if_record_instr_cache	: out		IFPHASE_INSTCACHE_RCD;
		instr_cache_record_if	: in		INSTCACHE_IFPHASE_RCD
	);
end IF_PHASE;

architecture arch of IF_PHASE is		
	
	--Register PC (Program Counter)
	signal reg_next_pc						: REG_TYPE ;
	signal reg_ir1, reg_ir2					: REG_TYPE ;
	signal reg_pc								: REG_TYPE := read_pc_from_file;
	
	shared variable sig_next_pc			: REG_TYPE ;--:= read_pc_plus_one_from_file;
begin		
		if_record_instr_cache.control		<= "011";
		if_record_instr_cache.address1 	<= reg_pc;
		if_record_instr_cache.address2	<= reg_pc;
		reg_ir1									<= instr_cache_record_if.data1;
		reg_ir2									<= instr_cache_record_if.data2;
		if_record_id.pc						<= signed(reg_pc) + 1;
		if_record_id.ir1						<= reg_ir1;
		if_record_id.ir2						<= reg_ir2;
		
	pc_register:
	process(record_in_crls.clk, record_in_crls.load, record_in_crls.reset) is 
	begin 	
		if rising_edge(record_in_crls.clk) then
			if (record_in_crls.load = '1') then
					reg_pc <= reg_next_pc;
			end if;
		end if;
	end process;
	
	
--	proc_reset:
--	process(record_in_crls.reset) is 
--	begin 	
--		if(record_in_crls.reset = '1') then
--			reg_pc <= read_pc_from_file;
--		end if;
--	end process;
	
	
	
	
	next_pc:
	process(record_in_crls.clk) is
	begin				
			if rising_edge(record_in_crls.clk) then
				reg_next_pc <= sig_next_pc;
			end if;
	end process;	
	
	
	process_mux_logic:
	process(ex_record_if.branch_cond, ex_record_if.pc, reg_pc) is
	begin				
		case (ex_record_if.branch_cond) is
			when '0'	=>
					sig_next_pc := signed(reg_pc) + 1;
			when others =>
					sig_next_pc := ex_record_if.pc;
		end case;					
	end process;	
	
end arch;