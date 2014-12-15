library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;

use WORK.CPU_LIB.all;

entity IF_PHASE is
    port(
		-- CONTROL
		clk		: STD_LOGIC;
		reset	: STD_LOGIC;
		load 	: STD_LOGIC;
		stall 	: STD_LOGIC;

		-- MEMORY
		we 		: out STD_LOGIC := UNDEFINED_1;
		addr 	: out WORD_TYPE;
		data 	: inout WORD_TYPE;

		-- ID_PHASE
		id_pc 			: REG_TYPE;
		pc_id 			: out REG_TYPE;
		instruction_id 	: out REG_TYPE;

		-- EX_PHASE
		ex_pc		: REG_TYPE;
		ex_branch 	: STD_LOGIC := '0'
	);
end entity IF_PHASE;

architecture STR of IF_PHASE is

	component ADDER is
		port
		(
			input: in REG_TYPE;
			output: out REG_TYPE
		);
	end component;

	signal pc : REG_TYPE;
begin
	U_ADD : ADDER 	port map (
						input => pc,
						output => pc_id
					);

	read_instuction : process (clk, ex_branch, ex_pc, id_pc) 
		variable step : INTEGER := PHASE_DURATION - 1;
	begin
		if (rising_edge(clk) and stall = '0') then
			step := (step + 1) mod PHASE_DURATION;

			addr <= UNDEFINED_32;
			
			case step is
				when 3 =>
					if (ex_branch = '0') then
						addr <= id_pc;
					else 
						addr <= ex_pc;
					end if;
				when 5 =>
					instruction_id <= data;
				when others  =>
			end case;
		end if;

		if (ex_branch = '1') then
			pc <= ex_pc;
		else 
			pc <= id_pc;
		end if;
	end process;
	
	we <= '0';
	data <= HIGH_Z_32;
end architecture STR;