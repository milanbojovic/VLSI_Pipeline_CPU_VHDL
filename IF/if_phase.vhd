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
	signal reg_pc							: REG_TYPE ;
	signal reg_ir1, reg_ir2				: REG_TYPE ;
	
	shared variable pc_plus_one		: REG_TYPE := UNDEFINED_32;
	shared variable next_pc				: REG_TYPE := read_pc_from_file;--:= read_pc_plus_one_from_file;
begin		
		if_record_instr_cache.control			<= "001";
		if_record_instr_cache.address1 		<= reg_pc;
		if_record_instr_cache.address2		<= reg_pc;
		reg_ir1				<= instr_cache_record_if.data1;
		reg_ir2				<= instr_cache_record_if.data2;
		
		if_record_id.ir1	<= reg_ir1;
		if_record_id.ir2	<= reg_ir2;
		
	process(record_in_crls.reset, record_in_crls.clk) is 
		-- Declaration(s) 
	begin 
		if(record_in_crls.reset = '1') then
			-- Asynchronous Sequential Statement(s) 
			--next_pc := read_pc_from_file;
		elsif(falling_edge(record_in_crls.clk)) then
			-- Synchronous Sequential Statement(s)
			reg_pc <= next_pc;					
		elsif(rising_edge(record_in_crls.clk)) then	
			case ex_record_if.branch_cond is
				when '0'	=>
						next_pc := pc_plus_one;
				when others =>
						next_pc := ex_record_if.pc;
			end case;			
		end if;
	end process;
	
	ADDER :
	process(reg_pc) is
	begin
		pc_plus_one := signed(reg_pc) + 1;
	end process;
	
	process_record_next_pc :
	process(record_in_crls.clk) is
	begin
		if rising_edge(record_in_crls.clk) then
			if_record_id.pc<= next_pc;
		end if;
	end process;
end arch;