library IEEE;
library WORK;

use ieee.std_logic_1164.all;
use work.cpu_lib.all;

use STD.TEXTIO.all;
use IEEE.STD_LOGIC_TEXTIO.all;


entity REG_ID is
	port(
	
		-- Input ports
		load : std_logic;
		stall : STD_LOGIC;

		reset : std_logic;
		
		pc_in: REG_TYPE;
		instruction_in : REG_TYPE;
		
		-- Output ports
		pc_out : out REG_TYPE;
		instruction_out : out REG_TYPE
		
	);
end entity REG_ID;

architecture BHV of REG_ID is
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

begin
	process(load) is
		variable PC_START : REG_TYPE := pc_from_file;
	begin
		if (rising_edge(load)) then
			if (reset = '1') then
				pc_out <= PC_START;
				instruction_out <=  INSTRUCTION_TYPE_NOOP & ZERO_32(28 downto 0);
			elsif (stall = '0') then
				pc_out <= pc_in;
				instruction_out <= instruction_in;
			end if;
		end if;
	end process;
end architecture;