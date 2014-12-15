library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_LIB.all;

entity WB_PHASE is
	port(
	 	-- CONTROL
		clk		: STD_LOGIC;
		load	: STD_LOGIC;
		reset	: STD_LOGIC;
		stall	: STD_LOGIC;

		-- MEM_PHASE
		mem_instruction_type 	: INSTRUCTION_TYPE_TYPE;
		mem_load_store			: STD_LOGIC;
		mem_opcode				: OPCODE_TYPE;
		mem_link_flag			: STD_LOGIC;
		mem_branch				: STD_LOGIC;
		
		mem_rd_1				: REG_TYPE;
		mem_rd_1_addr			: REG_ADDR_TYPE;
		mem_rd_2				: REG_TYPE;
		mem_rd_2_addr			: REG_ADDR_TYPE;

		-- ID_PHASE
		rd_1_addr_id 	: out REG_ADDR_TYPE;
		rd_1_id 		: out REG_TYPE;
		we_1_id 		: out STD_LOGIC;

		rd_2_addr_id 	: out REG_ADDR_TYPE;
		rd_2_id 		: out REG_TYPE;
		we_2_id 		: out STD_LOGIC;

		instruction_type : out INSTRUCTION_TYPE_TYPE
	);
end entity WB_PHASE;

architecture STR of WB_PHASE is
	component REG_WB is
		port(
			-- Input ports
			load  : STD_LOGIC;
			reset : STD_LOGIC;
			stall : STD_LOGIC;

			instruction_type_in 	: INSTRUCTION_TYPE_TYPE;
			load_store_in			: STD_LOGIC;
			opcode_in				: OPCODE_TYPE;
			link_flag_in			: STD_LOGIC;
			branch_in				: STD_LOGIC;
			rd_1_in					: REG_TYPE;
			rd_2_in					: REG_TYPE;
			rd_1_addr_in			: REG_ADDR_TYPE;
			rd_2_addr_in			: REG_ADDR_TYPE;
			
			-- Output ports
			instruction_type_out 	: out INSTRUCTION_TYPE_TYPE;
			load_store_out			: out STD_LOGIC;
			opcode_out				: out OPCODE_TYPE;
			link_flag_out			: out STD_LOGIC;
			branch_out				: out STD_LOGIC;
			rd_1_out				: out REG_TYPE;
			rd_2_out				: out REG_TYPE;
			rd_1_addr_out			: out REG_ADDR_TYPE;
			rd_2_addr_out			: out REG_ADDR_TYPE
		);
	end component;
	
	-- REG_WB
	signal reg_instruction_type : INSTRUCTION_TYPE_TYPE;
	signal reg_load_store		: STD_LOGIC;
	signal reg_opcode			: OPCODE_TYPE;
	signal reg_link_flag		: STD_LOGIC;
	signal reg_branch			: STD_LOGIC;


	signal reg_rd_1				: REG_TYPE;
	signal reg_rd_2				: REG_TYPE;
	signal reg_rd_1_addr		: REG_ADDR_TYPE;
	signal reg_rd_2_addr		: REG_ADDR_TYPE;
begin
	U_REG_WB: REG_WB port map(
							load => load,
							reset => reset, 
							stall => stall, 
		
							-- Input ports
							instruction_type_in 	=> mem_instruction_type,
							load_store_in 			=> mem_load_store,
							opcode_in 				=> mem_opcode,
							link_flag_in 			=> mem_link_flag,
							branch_in				=> mem_branch,	 
							rd_1_in 				=> mem_rd_1,
							rd_2_in 				=> mem_rd_2,
							rd_1_addr_in 			=> mem_rd_1_addr,
							rd_2_addr_in 			=> mem_rd_2_addr,
		
							-- Output ports
							instruction_type_out 	=> reg_instruction_type,
							load_store_out 			=> reg_load_store,
							opcode_out				=> reg_opcode,
							link_flag_out			=> reg_link_flag,
							branch_out				=> reg_branch,
							rd_1_out				=> reg_rd_1,
							rd_2_out				=> reg_rd_2,
							rd_1_addr_out 			=> reg_rd_1_addr,
							rd_2_addr_out 			=> reg_rd_2_addr	
	);
	process(clk) is
	begin
		if (rising_edge(clk)) then
			if ((reg_instruction_type = INSTRUCTION_TYPE_DP_R and reg_opcode /= OPCODE_CMP)
				or
				(reg_instruction_type = INSTRUCTION_TYPE_DP_I  and reg_opcode /= OPCODE_CMP)
				or
				(
					reg_instruction_type = INSTRUCTION_TYPE_L_S and 
					reg_load_store = L_MEMORY_LOAD
				)
			) then
				rd_1_id <= reg_rd_1;
				rd_1_addr_id <= reg_rd_1_addr;
				we_1_id <= '1';
			else
				rd_1_id <= UNDEFINED_32;
				rd_1_addr_id <= UNDEFINED_4;
				we_1_id <= '0';
			end if;

			-- if it's swap operetion we need to write second operand 
			-- into reg file 
			if ((reg_instruction_type = INSTRUCTION_TYPE_DP_R and 
				reg_opcode = OPCODE_SWAP) or
				(reg_instruction_type = INSTRUCTION_TYPE_B_BL and
				 reg_branch = '1' and
				 reg_link_flag = '1')
			) then
				rd_2_id <= reg_rd_2;
				rd_2_addr_id <= reg_rd_2_addr;
				we_2_id <= '1';
			else
				rd_2_id <= UNDEFINED_32;
				rd_2_addr_id <= UNDEFINED_4;
				we_2_id <= '0';
			end if;
		end if;
	end process;

	instruction_type <= reg_instruction_type;
end architecture STR;