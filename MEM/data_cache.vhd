-- DATA CACHE --
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

entity DATA_CACHE is
  port
    (
		-- Input ports
		record_in_crls 			: in	CRLS_RCD;
		mem_record_data_cache	: in  MEMPHASE_DATACACHE_RCD;
		
		opcode					 	: in  OPCODE_TYPE;
		
		-- Output ports	
		data_cache_record_mem	: out	DATACACHE_MEMPHASE_RCD
    );
end DATA_CACHE;

architecture arch of DATA_CACHE is

	function init_cache return DATA_CACHE_TYPE is 
		file 		input_file					: text;
		variable input_line					: line;
		variable input_addr, input_data 	: WORD_TYPE;-- address and data read from input file
		variable tmp_mem : DATA_CACHE_TYPE := (others => (others => '0'));
		
	begin
		-- Init DATA cache from file
		
		file_open(input_file, data_input_file_path, read_mode);
		
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
	
		shared variable data_cache: DATA_CACHE_TYPE := init_cache;
		
--	-- Function for memory testing !!!
	procedure test_mem_procedure is

		file 		content												: text;
		variable current_line										: line;
		variable addr, data 											: WORD_TYPE;
		variable expected_data, data_cache_data				: WORD_TYPE;
		
		variable int_data, int_addr								: integer;
		variable test_result											: integer := 1;
		variable int_expected_data, int_data_cache_data		: integer;

		
		begin
		
			file_open(content, expected_output_file, read_mode);
		
			report 	"                                                                            "&
						"[TEST MEMORY FUNCTION] - Memory test started:";
			
			loop
				exit when endfile(content);

				READLINE(content, current_line);

				HREAD(current_line, addr);
				READ(current_line, expected_data);
				
				
				int_addr 				:= TO_INTEGER(UNSIGNED(addr(addr'RANGE))) ;
				
				data_cache_data		:= data_cache(int_addr) ;
				
				int_expected_data		:= TO_INTEGER(UNSIGNED(expected_data(expected_data'RANGE))) ; 
				int_data_cache_data	:= TO_INTEGER(UNSIGNED(data_cache_data(data_cache_data'RANGE))) ; 
									
				report "                                                                            "&
						 "[TEST MEMORY FUNCTION]         memory(" 	& integer'image(int_addr) & ") = " 	 & integer'image(int_data_cache_data) &
						 "  -->  expected(" & integer'image(int_expected_data) & ")";
				
				assert expected_data = data_cache_data
				report 	"                                                                           "&
							"[TEST MEMORY FUNCTION]         Error at memory(" & integer'image(int_addr) & ")"
				severity ERROR;
				
				if (expected_data /= data_cache_data) and test_result = 1 then 
					test_result := 0;
				end if;				
			end loop;

			file_close(content);
			
			if test_result = 1 then 
					report 	"                                                                            "&
								"[TEST MEMORY FUNCTION] - Test status: SUCCESS ";
			else 
					report 	"                                                                            "&					
								"[TEST MEMORY FUNCTION] - Test status:  FAIL";
			end if;

			report 	"                                                                            "&
						"[TEST MEMORY FUNCTION] - Memory test FINISHED";
		end;
	
begin	
	-- Checking control lines:
	-- 0001 - Write to memory	 MEM[address]	= dataIn
	-- 0010 - Read from memory	 dataOut 		= MEM[address]
	-- Nothing in other cases !!!
	
	process(record_in_crls.clk, mem_record_data_cache.control)
	begin
		if rising_edge(record_in_crls.clk)  then
			case mem_record_data_cache.control is

				--Write to memory
				when "0001" =>	
						
						data_cache(TO_INTEGER(UNSIGNED(mem_record_data_cache.address(ADDR_WIDTH - 1 downto 0)))) := mem_record_data_cache.dataIn;
						data_cache_record_mem.dataOut	<= UNDEFINED_32;
						
				--Read from memory
				when "0010" =>
						
						data_cache_record_mem.dataOut <= data_cache(TO_INTEGER(UNSIGNED(mem_record_data_cache.address(ADDR_WIDTH - 1 downto 0))));
						
				when others =>
						data_cache_record_mem.dataOut	<= UNDEFINED_32;
			end case;
		
		end if;
	end process;
	
	mem_test:process (record_in_crls.clk, record_in_crls.reset) is
		variable isExecuted : integer := 0;
	begin
		if (rising_edge(record_in_crls.reset)) then
			isExecuted := 0;
		elsif (rising_edge(record_in_crls.clk) and opcode = OPCODE_STOP) then
			if(isExecuted = 0) then 				
				test_mem_procedure;
				isExecuted := 1;
			end if;
		end if;
	end process;
	
end arch;