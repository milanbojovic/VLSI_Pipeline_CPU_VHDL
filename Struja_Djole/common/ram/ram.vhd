-- Quartus II VHDL Template
-- Single port RAM with single read/write address 

library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;

use WORK.CPU_LIB.all;

entity ram is

	generic 
	(
		ADDR_WIDTH 			: NATURAL := 32;
		OPERATION_LENGTH 	: NATURAL := 12
	);

	port 
	(
		clk		: in STD_LOGIC;
		halt	: in STD_LOGIC;
		addr	: in ADDR_TYPE;
		data	: inout REG_TYPE;
		we		: in STD_LOGIC := '1'
	);

end entity;

architecture rtl of ram is

	-- Build a 2-D array type for the RAM
	type MEMORY_TYPE is array(2**ADDR_WIDTH-1 downto 0) of WORD_TYPE;

	function init_ram
		return MEMORY_TYPE is 
		variable tmp : MEMORY_TYPE := (others => (others => '0'));
	begin 
		--tmp(0) := B"000_0010_0110_0110_0_0110_0000_0_11_11111";	-- SUB R6, R6, R6	//R6 <= 0 + zero flag ;
		tmp(0) := B"010_1_000_0101_0101_00000000000000000";			-- LOAD R5,R5	//R6 <= MEM[R6]
		--tmp(0) := B"000_1000_0000_0110_0_0101_0000_0_11_11111";		-- SWAP R6, R5
		tmp(1) := B"001_0010_0101_0101_0_0000000000000110";			-- SUB R5,R5,#6 	//R5 <= -1 + v + c
		--tmp(2) := B"000_0101_0000_0011_0_0110_0000_0_00_11111";	-- ADC R3, R0, R5
		--tmp(2) := B"100_00_1_1111111111_1111111111111101";		-- JMP EQ -3
		tmp(2) := B"010_0_000_0101_0101_00000000000000000";			-- STORE R5, R5
		tmp(3) := B"010_1_000_0110_0110_00000000000000000";			-- LOAD R6,R6	//R6 <= MEM[R6]
		tmp(4) := B"010_1_000_0100_0011_00000000000000000";			-- LOAD R3,R4	//R5 <= MEM[R6]
		tmp(5) := B"000_0000_0001_0010_0_0110_0000_0_11_11111";     -- AND R2, R1, R6 			
		--tmp(2) := B"001_0011_0111_0101_1_0000000000000101";
		tmp(6) := B"100_01_1_11111111111111111111111110";			-- GT B #-2
		tmp(7) := B"010_0_000_0111_0101_00000000000000000";			-- STORE R5,R7 //MEM[R6] <= R5
		tmp(8) := B"000_1101_1001_1010_0_0010_0000_0_11_11111";		-- MOV 
		tmp(9) := B"000_1010_0010_0001_0_1000_0000_0_11_11111";		-- CMP
		tmp(4) := B"101_00000000000000000000000000000";				-- STOP

		return tmp;
	end;


	function init_ram_incremental
		return MEMORY_TYPE is 
		variable tmp : MEMORY_TYPE := (others => (others => '0'));
	begin 
		for addr_pos in 0 to 2**ADDR_WIDTH - 1 loop 
			-- Initialize each address with the address itself
			tmp(addr_pos) := STD_LOGIC_VECTOR(TO_UNSIGNED(addr_pos, WORD_WIDTH));
		end loop;
		return tmp;
	end;	 

	function init_ram_file
		return MEMORY_TYPE is 

		file content : text open read_mode is input_file;
		variable tmp : MEMORY_TYPE := (others => (others => '0'));
		variable current_line : line;
		variable addr, data : WORD_TYPE;
	begin 
		report "RAM init!";

		READLINE(content, current_line);
		READLINE(content, current_line);
		
		loop
			exit when endfile(content);

			READLINE(content, current_line);

			HREAD(current_line, addr);
			READ(current_line, data);

			tmp(TO_INTEGER(UNSIGNED(addr(ADDR_WIDTH - 1 downto 0)))) := data;
		end loop;

		file_close(content);
		return tmp;
	end;
	 
	signal ram : MEMORY_TYPE := init_ram_file;
	
	procedure test_memory  is
		file content : text open read_mode is output_file;
		variable tmp : MEMORY_TYPE := (others => (others => '0'));
		variable current_line : line;
		variable addr, data : WORD_TYPE;

   		begin
			loop
				exit when endfile(content);

				READLINE(content, current_line);

				HREAD(current_line, addr);
				READ(current_line, data);

		        assert ram(TO_INTEGER(UNSIGNED(addr(ADDR_WIDTH - 1 downto 0)))) = data 
		        report "Result mismatch!"
				severity ERROR;
			end loop;

			file_close(content);

		  	report "Test end!";
	end test_memory;
	
begin
	process(clk)
		variable put : NATURAL := 0;
		variable get : NATURAL := 1;

		type REG_ARRAY_TYPE is array (OPERATION_LENGTH - 1 downto 0) of REG_TYPE;
		type REG_ADDR_ARRAY_TYPE is array (OPERATION_LENGTH - 1 downto 0) of NATURAL;
		type FLAG_ARRAY_TYPE is array (OPERATION_LENGTH - 1 downto 0) of STD_LOGIC;

		variable req_data 	: REG_ARRAY_TYPE;
		variable req_addr 	: REG_ADDR_ARRAY_TYPE;
		variable req_we 	: FLAG_ARRAY_TYPE;
		variable req_valid	: FLAG_ARRAY_TYPE;
	begin
		if (falling_edge(clk)) then
			-- proccessing request from buffer
			if (req_valid(get) = '1') then
				if (req_we(get) = '1') then
					ram(req_addr(get)) <= req_data(get);
					data <= HIGH_Z_32;
				else 
					data <= ram(req_addr(get));
				end if;
			else
				data <= HIGH_Z_32;
			end if;

			-- putting request
			if (addr /= UNDEFINED_32) then
				req_addr(put) := TO_INTEGER(UNSIGNED(addr(ADDR_WIDTH - 1 downto 0)));
				req_data(put) := data;
				req_we(put) := we;
				req_valid(put) := '1';
			else
				req_valid(put) := '0';
			end if;
			
			-- next step
			put := (put + 1) mod OPERATION_LENGTH;
			get := (get + 1) mod OPERATION_LENGTH;
		end if;
	end process;

	process (halt) is
	begin
		if (rising_edge(halt)) then
			test_memory;
		end if;
	end process;
end rtl;
