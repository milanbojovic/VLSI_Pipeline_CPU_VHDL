-- INSTRUCTION CACHE --
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

entity INSTRUCTION_CACHE is
  port
    (
		-- Input ports
		record_in_crls 			: in CRLS_RCD;
		if_record_instr_cache	: in   IFPHASE_INSTCACHE_RCD;
		
		-- Output ports
		instr_cache_record_if	: out  INSTCACHE_IFPHASE_RCD
    );
end INSTRUCTION_CACHE;

architecture arch of INSTRUCTION_CACHE is
	function init_cache return INSTR_CACHE_TYPE is 
		file 		input_file					: text;
		variable input_line					: line;
		variable input_addr, input_data 	: WORD_TYPE;-- address and data read from input file
		variable tmp_mem : INSTR_CACHE_TYPE := (others => (others => '0'));
	begin
		-- Init instruction cache from file

		file_open(input_file, instr_input_file_path, read_mode);

		READLINE(input_file, input_line);  	--Skip first line with PC register

		loop
				exit when endfile(input_file);

				READLINE(input_file, input_line);  	--Read the line from the file
				HREAD(input_line, input_addr);		--Read first word (adress)
				READ(input_line, input_data);			--Read second word (value for memory location )

				tmp_mem(TO_INTEGER(UNSIGNED(input_addr(input_addr'RANGE)))) := input_data;

		end loop;

		file_close(input_file);  --after reading all the lines close the file

		return tmp_mem;
	end;

	shared variable instr_cache: INSTR_CACHE_TYPE := init_cache;

begin
	-- Checking control lines:
	-- 001 - Take address from line address1 and return instruction on data1
	-- 010 - Take address from line address2 and return instruction on data2
	-- 011 - Take address from line address1 and address2 and return instruction on data1 and data2

	adr1: process(record_in_crls.clk, if_record_instr_cache.control)
	begin
		if (rising_edge(record_in_crls.clk) AND if_record_instr_cache.control = "001") OR (rising_edge(record_in_crls.clk) AND if_record_instr_cache.control = "011") then
			instr_cache_record_if.data1 <= instr_cache(to_integer(signed(if_record_instr_cache.address1)));
		end if;
	end process adr1;

	adr2: process(record_in_crls.clk, if_record_instr_cache.control)
	begin
		if (rising_edge(record_in_crls.clk) AND if_record_instr_cache.control = "010") OR (rising_edge(record_in_crls.clk) AND if_record_instr_cache.control = "011") then
			instr_cache_record_if.data2 <= instr_cache(to_integer(signed(if_record_instr_cache.address2)));
		end if;
	end process adr2;

end arch;
