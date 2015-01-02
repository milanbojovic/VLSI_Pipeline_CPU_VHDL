--INSTRUCTION CACHE
library IEEE;
library WORK;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use IEEE.numeric_std.all;
use STD.TEXTIO.all;
use WORK.CPU_LIB.all;

entity INSTRUCTION_CACHE is
  port
    (
    -- Input ports
      clk		: in STD_LOGIC;
      reset		: in STD_LOGIC;
--    load 		: STD_LOGIC;
--    stall 	: STD_LOGIC;
		address1 : in ADDR_TYPE;
		address2 : in ADDR_TYPE;
		control	: in STD_LOGIC_VECTOR(2 downto 0);

		-- Output ports	
		data1		: out WORD_TYPE;
		data2		: out WORD_TYPE

    );
end INSTRUCTION_CACHE;

-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture arch of INSTRUCTION_CACHE is
	shared variable instr_cache: CACHE_TYPE;
begin
	
-- Initialise instruction cache
			
	init_cache: process(clk, reset)
	
	file 		input_file					: text;
	variable input_line					: line;
	variable input_addr, input_data 	: WORD_TYPE;-- address and data read from input file
	variable i								: natural;	-- used as destination address in instruction cache
		
	begin
		if rising_edge(clk) then
			if reset = '1' then
			
				-- load program to execute
				file_open(input_file, input_file_path, read_mode);
				
				i := 0;
				while i < INSTR_CACHE_SIZE loop
					--initialise memory
					instr_cache(i) := (31 downto 0 => '0');
					i := i + 1;
				end loop;	
				
				loop
						exit when endfile(input_file);				
						
						READLINE(input_file, input_line);  	--Read the line from the file
						HREAD(input_line, input_addr);		--Read first word (adress)
						READ(input_line, input_data);			--Read second word (value for memory location )
						
						instr_cache(TO_INTEGER(UNSIGNED(input_addr(ADDR_WIDTH - 1 downto 0)))) := input_data;
						
				end loop;

				file_close(input_file);  --after reading all the lines close the file. 				
			end if;
		end if;
	end process init_cache;
	
			-- Checking control lines:
			-- 001 - Take address from line address1 and return instruction on data1
			-- 010 - Take address from line address2 and return instruction on data2
			-- 011 - Take address from line address1 and address2 and return instruction on data1 and data2

	adr1: process(clk)
	begin
		if (rising_edge(clk) AND control = "001") OR (rising_edge(clk) AND control = "011") then
			data1 <= instr_cache(to_integer(signed(address1)));
		end if;
	end process adr1;
	
	adr2: process(clk)
	begin
		if (rising_edge(clk) AND control = "010") OR (rising_edge(clk) AND control = "011") then
			data2 <= instr_cache(to_integer(signed(address2)));
		end if;
	end process adr2;	
	
end arch;