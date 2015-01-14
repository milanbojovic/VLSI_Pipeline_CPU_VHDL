--IF Phase--
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
use WORK.EX_IF_PKG.all;
use WORK.IF_ID_pkg.all;
use IEEE.STD_LOGIC_ARITH.all;

entity IF_PHASE is
	port
	(	
		-- Input ports
		record_in_crls 		: in CRLS_RCD;	--Clock, Reset, Load, Store
		
		-- EX_PHASE
		ex_record_if			: in EX_IF_RCD;
				
		-- Output to ID phase
		if_record_id			: out IF_ID_RCD
	);
end IF_PHASE;

architecture arch of IF_PHASE is
	
	--Instruction Cache signals 
	signal cache_addr1: ADDR_TYPE;
	signal cache_addr2: ADDR_TYPE;
	signal cache_ctrl	: STD_LOGIC_VECTOR(2 downto 0);
	signal cache_data1: WORD_TYPE;
	signal cache_data2: WORD_TYPE;
	
	--Register PC (Program Counter)
	signal pc					: REG_TYPE := read_pc_from_file;
	signal ir, ir2				: REG_TYPE;
	
	shared variable pc_plus_one		: REG_TYPE;
	shared variable next_pc				: REG_TYPE;-- := read_pc_plus_one_from_file;
begin
		COMP_INSTR_CACHE 	: entity work.INSTRUCTION_CACHE(arch) 	port map (record_in_crls, cache_addr1, cache_addr2, cache_ctrl, cache_data1, cache_data2);

		if_record_id.pc<= pc;
		cache_ctrl		<= "001";
		cache_addr1 	<= pc;
		cache_addr2		<= pc;
		ir 				<= cache_data1;
		ir2				<= cache_data2;
		if_record_id.ir<= ir;
		
	process(record_in_crls.reset, record_in_crls.clk) is 
		-- Declaration(s) 
	begin 
		if(record_in_crls.reset = '1') then
			-- Asynchronous Sequential Statement(s) 
			--next_pc := read_pc_from_file;
		elsif(rising_edge(record_in_crls.clk)) then
			-- Synchronous Sequential Statement(s)
			pc <= next_pc;					
		
		elsif(falling_edge(record_in_crls.clk)) then	
			
			case ex_record_if.branch_cond is
				when '0'	=>
						next_pc :=	pc_plus_one;
				when others =>
						next_pc :=	ex_record_if.pc;
			end case;			
		end if;
	end process;
	
	ADDER :
	process(pc) is
	begin
		pc_plus_one := signed(pc) + 1;
	end process;
	
end arch;