library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use WORK.CPU_LIB.all;

entity MEM_PHASE is
	port(
		-- CONTROL
		clk		: STD_LOGIC;
		load	: STD_LOGIC;
		reset	: STD_LOGIC;
		stall	: STD_LOGIC;

		-- EX_PHASE
		ex_rd_1 			: REG_TYPE;
		ex_rd_2 			: REG_TYPE;
		ex_rd_1_addr 		: REG_ADDR_TYPE;
		ex_rd_2_addr 		: REG_ADDR_TYPE;
		ex_rn 				: REG_TYPE;
		--ex_rn_addr			: REG_ADDR_TYPE;
		ex_branch           : STD_LOGIC;
		ex_opcode			: OPCODE_TYPE;
		ex_link_flag		: STD_LOGIC;
		ex_load_store 		: STD_LOGIC;
		ex_instruction_type : INSTRUCTION_TYPE_TYPE;
		ex_reset			: STD_LOGIC;

		-- WB_PHASE
		rd_1_wb 			: out REG_TYPE;
		rd_2_wb				: out REG_TYPE;
		rd_1_addr_wb 		: out REG_ADDR_TYPE;
		rd_2_addr_wb 		: out REG_ADDR_TYPE;
		instruction_type_wb : out INSTRUCTION_TYPE_TYPE;
		load_store_wb		: out STD_LOGIC;
		branch_wb			: out STD_LOGIC;
		opcode_wb			: out OPCODE_TYPE;
		link_flag_wb		: out STD_LOGIC;

		-- MEMORY
		we 		: out STD_LOGIC;
		addr 	: out WORD_TYPE;
		data 	: inout WORD_TYPE
	);
end entity MEM_PHASE;

architecture STR of MEM_PHASE is
	component REG_MEM is
		port
		(
		-- Input ports
		load 	: STD_LOGIC;
		reset	: STD_LOGIC;
		stall	: STD_LOGIC;
		
		rd_1_in 				: REG_TYPE;
		rd_2_in 				: REG_TYPE;
		rd_1_addr_in 			: REG_ADDR_TYPE;
		rd_2_addr_in 			: REG_ADDR_TYPE;
		rn_in 					: REG_TYPE;
		--rn_addr_in				: REG_ADDR_TYPE;
		load_store_in 			: STD_LOGIC;
		link_flag_in			: STD_LOGIC;
		branch_in				: STD_LOGIC;
		opcode_in				: OPCODE_TYPE;
		instruction_type_in 	: INSTRUCTION_TYPE_TYPE;

		-- Output ports
		rd_1_out 				: out REG_TYPE;
		rd_2_out 				: out REG_TYPE;
		rd_1_addr_out 			: out REG_ADDR_TYPE;
		rd_2_addr_out 			: out REG_ADDR_TYPE;
		rn_out 					: out REG_TYPE;
		--rn_addr_out				: out REG_ADDR_TYPE;
		load_store_out 			: out STD_LOGIC;
		branch_out				: out STD_LOGIC;
		link_flag_out			: out STD_LOGIC;
		opcode_out				: out OPCODE_TYPE;
		instruction_type_out 	: out INSTRUCTION_TYPE_TYPE
		);
	end component;

	signal reg_rd_1				: REG_TYPE;
	signal reg_rd_2				: REG_TYPE;
	signal reg_rd_1_addr		: REG_ADDR_TYPE;
	signal reg_rd_2_addr 		: REG_ADDR_TYPE;
	signal reg_rn 				: REG_TYPE;
	signal reg_rn_addr			: REG_ADDR_TYPE;
	signal reg_link_flag 		: STD_LOGIC;
	signal reg_branch 			: STD_LOGIC;
	signal reg_opcode 			: OPCODE_TYPE;
	signal reg_load_store 		: STD_LOGIC;
	signal reg_instruction_type : INSTRUCTION_TYPE_TYPE;

	signal reset_reg			: STD_LOGIC;
begin
	U_REG_MEM: REG_MEM port map(
							load => load,
							reset => reset_reg,
							stall => stall,

							-- Input ports
							rd_1_in 				=> ex_rd_1,
							rd_2_in 				=> ex_rd_2,
							rd_1_addr_in 			=> ex_rd_1_addr,
							rd_2_addr_in 			=> ex_rd_2_addr,
							rn_in 					=> ex_rn,
							--rn_addr_in				=> ex_rn_addr,
							load_store_in 			=> ex_load_store,
							branch_in 				=> ex_branch,
							link_flag_in			=> ex_link_flag,
							opcode_in				=> ex_opcode,
							instruction_type_in 	=> ex_instruction_type,

							-- Output ports
							rd_1_out 				=> reg_rd_1,
							rd_2_out 				=> reg_rd_2,
							rd_1_addr_out 			=> reg_rd_1_addr,
							rd_2_addr_out 			=> reg_rd_2_addr,
							rn_out 					=> reg_rn,
							--rn_addr_out				=> reg_rn_addr,
							branch_out 				=> reg_branch,
							link_flag_out 			=> reg_link_flag,
							opcode_out				=> reg_opcode,
							load_store_out 			=> reg_load_store,
							instruction_type_out 	=> reg_instruction_type
						);
	
	load_store : process (clk) 
		variable step : INTEGER := PHASE_DURATION - 1;
	begin
		if (rising_edge(clk) and stall = '0') then
			step := (step + 1) mod PHASE_DURATION;

			--empty state
			we <= UNDEFINED_1;
			addr <= UNDEFINED_32;
			data <= HIGH_Z_32;

			if (reg_instruction_type = INSTRUCTION_TYPE_L_S) then
				case step is
					when 1 =>
						addr <= reg_rn;

						if (reg_load_store = L_MEMORY_LOAD) then
							we <= '0';
						else
							we <= '1';
							data <= reg_rd_1;
						end if;
					when 3 =>
						if (reg_load_store = L_MEMORY_LOAD) then
							rd_1_wb <= data;
						else
							rd_1_wb <= reg_rd_1;
						end if;
					when others  =>
				end case;
			else 
				rd_1_wb <= reg_rd_1;
			end if;
			
		end if;
	end process;


	reset_reg <= reset or (ex_reset and not stall);
	
	instruction_type_wb <= reg_instruction_type;
	load_store_wb <= reg_load_store;
	link_flag_wb <= reg_link_flag;
	opcode_wb <= reg_opcode;
	branch_wb <= reg_branch;

	rd_1_addr_wb <= reg_rd_1_addr;
	
	rd_2_wb <= reg_rd_2;
	rd_2_addr_wb <= reg_rd_2_addr;

end architecture STR;