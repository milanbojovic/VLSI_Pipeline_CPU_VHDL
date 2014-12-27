library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;

use WORK.CPU_LIB.all;


entity REGISTERS is
	port 
	(	
		clk			: STD_LOGIC;
		reset		: STD_LOGIC;

		rn_addr		: REG_ADDR_TYPE;
		rm_addr		: REG_ADDR_TYPE;
		rs_addr		: REG_ADDR_TYPE;
		rd_addr		: REG_ADDR_TYPE;

		in_1_addr	: REG_ADDR_TYPE;
		in_1 		: REG_TYPE;
		we_1		: STD_LOGIC;

		in_2_addr	: REG_ADDR_TYPE;
		in_2 		: REG_TYPE;
		we_2		: STD_LOGIC;

		pc_in 		: REG_TYPE;
		
		rn			: out REG_TYPE;
		rs			: out REG_TYPE;
		rm			: out REG_TYPE;
		rd			: out REG_TYPE;

		pc_out		: out REG_TYPE
	);

end REGISTERS;

architecture RTL of REGISTERS is

	function pc_from_file
		return REG_TYPE is 

		file content : text open read_mode is input_file;
		variable current_line : line;
		variable pc : REG_TYPE;
	begin 
		report "PC load!";

		READLINE(content, current_line);
		HREAD(current_line, pc);

		file_close(content);

		return pc;
	end;
	
	-- Build a 2-D array type for the RAM
	type MEMORY_TYPE is array(2**REG_ADDR_TYPE'length-1 downto 0) of REG_TYPE;

	function init_ram
		return MEMORY_TYPE is 
		variable tmp : MEMORY_TYPE := (others => (others => '0'));
	begin 
		for addr_pos in 0 to 2**REG_ADDR_TYPE'length - 1 loop 
			-- Initialize each address with the address itself
			tmp(addr_pos) := STD_LOGIC_VECTOR(TO_UNSIGNED(addr_pos + 1, REG_TYPE'length));
		end loop;
		return tmp;
	end;	 

	-- Declare the RAM 
	signal ram : MEMORY_TYPE := init_ram;
begin	

	process(clk, rn_addr, ram, rm_addr, rs_addr, rd_addr)
		variable PC_START : REG_TYPE := pc_from_file;
	begin
		if (falling_edge(clk)) then
			if (reset = '1') then
				ram(PC_ADDR) <= PC_START;
			else 
				ram(PC_ADDR) <= pc_in;

				if (we_1 = '1' and in_1_addr /= UNDEFINED_4) then
					ram(TO_INTEGER(UNSIGNED(in_1_addr))) <= in_1;
				end if;

				if (we_2 = '1' and in_2_addr /= UNDEFINED_4) then
					ram(TO_INTEGER(UNSIGNED(in_2_addr))) <= in_2;
				end if;
			end if;
		end if;

		if (rn_addr /= UNDEFINED_4) then
			rn <= ram(TO_INTEGER(UNSIGNED(rn_addr)));
		else 
			rn <= UNDEFINED_32;
		end if;

		if (rm_addr /= UNDEFINED_4) then
			rm <= ram(TO_INTEGER(UNSIGNED(rm_addr)));
		else 
			rm <= UNDEFINED_32;
		end if;

		if (rs_addr /= UNDEFINED_4) then
			rs <= ram(TO_INTEGER(UNSIGNED(rs_addr)));
		else 
			rs <= UNDEFINED_32;
		end if;

		if (rd_addr /= UNDEFINED_4) then
			rd <= ram(TO_INTEGER(UNSIGNED(rd_addr)));
		else 
			rd <= UNDEFINED_32;
		end if;
		
		pc_out <= ram(PC_ADDR);
	end process;
end RTL;