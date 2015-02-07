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
	signal reg_pc1								: REG_TYPE := read_pc_from_file;
	--signal reg_pc2								: REG_TYPE ;
	
	shared variable sig_next_pc			: REG_TYPE ;
begin		
		if_record_instr_cache.control		<= "011";
		if_record_instr_cache.address1 	<= reg_pc1;
		if_record_instr_cache.address2	<= signed(reg_pc1) + 1;
		reg_ir1									<= instr_cache_record_if.data1;
		reg_ir2									<= instr_cache_record_if.data2;

		
	flush_signal_daemon:
	process(record_in_crls.clk, ex_record_if.flush_out) is 
	begin 	
		if rising_edge(record_in_crls.clk) then
			if (ex_record_if.flush_out = '1' or ex_record_if.halt_out = '1') then
				--if_record_id.pc						<= UNDEFINED_32;
				--if_record_id.pc2						<= UNDEFINED_32;
				if_record_id.ir1						<= UNDEFINED_32;
				if_record_id.ir2						<= UNDEFINED_32;
			else 
				if_record_id.pc						<= signed(reg_pc1) + 1;
				if_record_id.pc2						<= signed(reg_pc1) + 2;
				if_record_id.ir1						<= reg_ir1;
				if_record_id.ir2						<= reg_ir2;
			end if;
		end if;
	end process;
		
		
	pc_register:
	process(record_in_crls.load, record_in_crls.reset, ex_record_if.halt_out, record_in_crls.clk) is 
	variable tmp_reg								: REG_TYPE ;
	begin
		if rising_edge(record_in_crls.clk) then
			if (record_in_crls.reset = '1') then
				tmp_reg := read_pc_from_file;
				reg_pc1 <= tmp_reg;
				--reg_pc2 <= signed(tmp_reg) + 1;
			elsif (record_in_crls.load = '1' and  ex_record_if.halt_out /= '1') then
				reg_pc1 <= reg_next_pc;
				--reg_pc2 <= signed(reg_next_pc) + 1;
			end if;
		end if;
	end process;
	
	
	next_pc:
	process(record_in_crls.clk, ex_record_if.halt_out) is
	begin				
		if (rising_edge(record_in_crls.clk) and  ex_record_if.halt_out /= '1') then
			reg_next_pc <= sig_next_pc;
		end if;
	end process;	
	
	
	process_mux_logic:
	process(record_in_crls.clk) is
	begin	
		if(rising_edge(record_in_crls.clk)) then 
			case (ex_record_if.branch_cond) is
				when '0'	=>
						sig_next_pc := signed(reg_pc1) + 2;
				when others =>
						sig_next_pc := ex_record_if.pc;
						--reg_pc1 		<= ex_record_if.pc;
			end case;					
		end if;
	end process;	
	
end arch;