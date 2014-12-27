library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;

use WORK.CPU_LIB.all;


entity CPU_ALL is
	
	generic 
	(
		DATA_WIDTH : NATURAL := 32;
		ADDR_WIDTH : NATURAL := 32
	);
	
	port(
		signal clk: in STD_LOGIC;
		signal reset : in STD_LOGIC;
		signal we : out STD_LOGIC;
		signal halt : out STD_LOGIC;
		signal addr : out WORD_TYPE;
		signal data : inout WORD_TYPE
	);
end entity CPU_ALL;

--------------------------------------------------------------------------------

architecture STR of CPU_ALL is

	component CACHE is
		port (
			clk			: STD_LOGIC;
			flash		: STD_LOGIC;
			reset		: STD_LOGIC;
			flashed		: out STD_LOGIC;

			addr		: ADDR_TYPE;
			addr_ram 	: out ADDR_TYPE;

			we			: STD_LOGIC := '1';
			we_ram		: out STD_LOGIC := '1';

			data		: inout REG_TYPE;
			data_ram	: inout REG_TYPE;

			miss		: out STD_LOGIC
		);
	end component;

	component IF_PHASE is
		port(
			-- CONTROL
			clk		: STD_LOGIC;
			reset	: STD_LOGIC;
			load 	: STD_LOGIC;
			stall 	: STD_LOGIC;

			-- MEMORY
			we 		: out STD_LOGIC;
			addr 	: out WORD_TYPE;
			data 	: inout WORD_TYPE;

			-- ID_PHASE
			id_pc			: REG_TYPE;
			pc_id 			: out REG_TYPE;
			instruction_id 	: out REG_TYPE;

			-- EX_PHASE
			ex_pc		: REG_TYPE;
			ex_branch 	: STD_LOGIC := '0'
		);
	end component;
	
	component ID_PHASE is
		port(
			-- CONTROL
			clk		: STD_LOGIC;
			load	: STD_LOGIC;
			reset	: STD_LOGIC;
			stall	: STD_LOGIC;

			-- IF_PHASE
			if_pc 			: REG_TYPE;
			if_instruction 	: REG_TYPE;

			-- IF_PHASE, EX_PHASE
			pc_if_ex : out REG_TYPE;

			-- EX_PHASE [instruction info]
			instruction_type_ex : out INSTRUCTION_TYPE_TYPE;
			opcode_ex			: out OPCODE_TYPE;
			cond_ex				: out COND_TYPE;
			branch_offset_ex	: out BRANCH_OFFSET_TYPE;
			is_signed_ex		: out STD_LOGIC;
			load_store_ex 		: out STD_LOGIC;
			shift_operation_ex	: out STD_LOGIC;
			shift_type_ex		: out SHIFT_TYPE_TYPE;
			immidiate_ex		: out REG_TYPE;
			link_flag_ex		: out STD_LOGIC;

			-- EX_PHASE [reg addresses]
			rd_addr_ex 			: out REG_ADDR_TYPE;
			rn_addr_ex			: out REG_ADDR_TYPE;
			rm_addr_ex			: out REG_ADDR_TYPE;
			rs_addr_ex			: out REG_ADDR_TYPE;

			-- EX_PHASE [registers]
			rn_ex	: out REG_TYPE;
			rs_ex	: out REG_TYPE;
			rm_ex	: out REG_TYPE;
			rd_ex   : out REG_TYPE;

			-- WB_PHASE
			wb_rd_1_addr 	: REG_ADDR_TYPE;
			wb_rd_1 		: REG_TYPE;
			wb_we_1 		: STD_LOGIC;

			wb_rd_2_addr 	: REG_ADDR_TYPE;
			wb_rd_2 		: REG_TYPE;
			wb_we_2 		: STD_LOGIC
		);
	end component;

	component EX_PHASE is
		port(
			-- CONTROL
			clk		: STD_LOGIC;
			load	: STD_LOGIC;
			reset	: STD_LOGIC;
			stall	: STD_LOGIC;

			-- IF_PHASE [branch]
			branch_if_mem : out std_logic;

			-- ID_PHASE [pc]
			id_pc : REG_TYPE;

			-- ID_PHASE [instruction info]
			id_instruction_type : INSTRUCTION_TYPE_TYPE;
			id_opcode			: OPCODE_TYPE;
			id_cond				: COND_TYPE;
			id_branch_offset	: BRANCH_OFFSET_TYPE;
			id_is_signed		: STD_LOGIC;
			id_link_flag		: STD_LOGIC;
			id_load_store		: STD_LOGIC;
			id_shift_operation	: STD_LOGIC;
			id_shift_type		: SHIFT_TYPE_TYPE;
			id_immidiate		: REG_TYPE;

			-- ID_PHASE [reg addresses]
			id_rd_addr 			: REG_ADDR_TYPE;
			id_rn_addr 			: REG_ADDR_TYPE;
			id_rm_addr 			: REG_ADDR_TYPE;
			id_rs_addr 			: REG_ADDR_TYPE;
			
			-- ID_PHASE [registers]
			id_rn		: REG_TYPE;
			id_rs		: REG_TYPE;
			id_rm		: REG_TYPE;
			id_rd 		: REG_TYPE;

			-- MEM_PHASE
			rn_mem 				: out REG_TYPE;
			rn_addr_mem			: out REG_ADDR_TYPE;
			load_store_mem 		: out STD_LOGIC;
			opcode_mem 			: out OPCODE_TYPE;
			link_flag_mem 		: out STD_LOGIC;
			instructon_type_mem : out INSTRUCTION_TYPE_TYPE;
			reset_mem			: out STD_LOGIC;

			rd_1_if_mem 		: out REG_TYPE;
			rd_1_addr_mem 		: out REG_ADDR_TYPE;
			rd_2_mem			: out REG_TYPE;
			rd_2_addr_mem 		: out REG_ADDR_TYPE;

			-- MEM_PHASE [HAZARDS]
			mem_instruction_type 	: INSTRUCTION_TYPE_TYPE;
			mem_load_store			: STD_LOGIC;
			mem_opcode				: OPCODE_TYPE;
			mem_link_flag			: STD_LOGIC;
			mem_branch				: STD_LOGIC;
			
			mem_rd_1				: REG_TYPE;
			mem_rd_1_addr			: REG_ADDR_TYPE;
			mem_rd_2				: REG_TYPE;
			mem_rd_2_addr			: REG_ADDR_TYPE;

			-- WB_PHASE [HAZARDS]
			wb_rd_1_addr 	: REG_ADDR_TYPE;
			wb_rd_1 		: REG_TYPE;
			wb_we_1 		: STD_LOGIC;

			wb_rd_2_addr 	: REG_ADDR_TYPE;
			wb_rd_2			: REG_TYPE;
			wb_we_2 		: STD_LOGIC
		);
	end component;

	component MEM_PHASE is
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
			ex_link_flag 		: STD_LOGIC;
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
	end component;

	component WB_PHASE is
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
	end component;

	-- IF -> ID
	signal if_pc_id 			: REG_TYPE;
	signal if_instruction_id 	: REG_TYPE;

	-- ID -> IF
	signal id_pc_if_ex 			: REG_TYPE;

	-- ID -> EX
	signal id_instruction_type_ex 	: INSTRUCTION_TYPE_TYPE;
	signal id_opcode_ex				: OPCODE_TYPE;
	signal id_cond_ex				: COND_TYPE;
	signal id_branch_offset_ex		: BRANCH_OFFSET_TYPE;
	signal id_is_signed_ex			: STD_LOGIC;
	signal id_link_flag_ex			: STD_LOGIC;
	signal id_load_store_ex			: STD_LOGIC;
	signal id_shift_operation_ex	: STD_LOGIC;
	signal id_shift_type_ex			: SHIFT_TYPE_TYPE;
	signal id_immidiate_ex			: REG_TYPE;

	signal id_rn_ex			: REG_TYPE;
	signal id_rs_ex			: REG_TYPE;
	signal id_rm_ex			: REG_TYPE;
	signal id_rd_ex			: REG_TYPE;

	signal id_rd_addr_ex : REG_ADDR_TYPE;
	signal id_rn_addr_ex : REG_ADDR_TYPE;
	signal id_rm_addr_ex : REG_ADDR_TYPE;
	signal id_rs_addr_ex : REG_ADDR_TYPE;

	-- EX -> IF
	signal ex_branch_if_mem : STD_LOGIC := '0';

	-- EX -> IF, MEM
	signal ex_rd_1_if_mem : REG_TYPE;

	-- EX -> MEM
	signal ex_rd_1_addr_mem 		: REG_ADDR_TYPE;
	signal ex_rd_2_addr_mem 		: REG_ADDR_TYPE;
	signal ex_rd_2_mem 				: REG_TYPE;

	signal ex_rn_mem 				: REG_TYPE;
	--signal ex_rn_addr_mem			: REG_ADDR_TYPE;
	signal ex_load_store_mem 		: STD_LOGIC;
	signal ex_link_flag_mem 		: STD_LOGIC;
	signal ex_opcode_mem			: OPCODE_TYPE;
	signal ex_instruction_type_mem 	: INSTRUCTION_TYPE_TYPE;
	signal ex_reset_mem		 		: STD_LOGIC;

	-- MEM -> WB
	signal mem_rd_1_wb 				: REG_TYPE;
	signal mem_rd_2_wb 				: REG_TYPE;
	signal mem_rd_1_addr_wb 		: REG_ADDR_TYPE;
	signal mem_rd_2_addr_wb 		: REG_ADDR_TYPE;
	signal mem_instruction_type_wb 	: INSTRUCTION_TYPE_TYPE;
	signal mem_load_store_wb		: STD_LOGIC;
	signal mem_opcode_wb			: OPCODE_TYPE;
	signal mem_link_flag_wb			: STD_LOGIC;
	signal mem_branch_wb			: STD_LOGIC;

	-- WB -> ID
	signal wb_rd_1_addr_id 	: REG_ADDR_TYPE;
	signal wb_rd_1_id 		: REG_TYPE;
	signal wb_we_1_id 		: STD_LOGIC;

	signal wb_rd_2_addr_id 	: REG_ADDR_TYPE;
	signal wb_rd_2_id 		: REG_TYPE;
	signal wb_we_2_id 		: STD_LOGIC;

	-- IF -> RAM
	signal if_we_ram 		: STD_LOGIC;
	signal if_addr_ram 		: WORD_TYPE;
	signal if_data_ram 		: WORD_TYPE;

	-- MEM -> RAM
	signal mem_we_ram 		: STD_LOGIC;
	signal mem_addr_ram 	: WORD_TYPE;
	signal mem_data_ram 	: WORD_TYPE;

	signal load : STD_LOGIC := '0';
	signal run : STD_LOGIC := '0';
	signal miss : STD_LOGIC := '0';
	signal clk_internal : STD_LOGIC := '0';

	signal stall_id 	: STD_LOGIC;
	signal stall_ex		: STD_LOGIC;
	signal stall_mem	: STD_LOGIC;
	signal stall_wb		: STD_LOGIC;

	signal stall_id_s	: STD_LOGIC := '0';
	signal stall_ex_s	: STD_LOGIC := '0';
	signal stall_mem_s	: STD_LOGIC := '0';
	signal stall_wb_s	: STD_LOGIC := '0';

	signal stall 		: STD_LOGIC := '0';

	signal data_cache 	: WORD_TYPE := UNDEFINED_32;
	signal addr_cache	: WORD_TYPE := UNDEFINED_32;
	signal we_cache		: STD_LOGIC := UNDEFINED_1;

	signal wb_instruction_type : INSTRUCTION_TYPE_TYPE;
begin
	
	U_IF : IF_PHASE 	port map (
								-- CTRL
								clk	 	=> clk,
								load 	=> load,
								reset 	=> reset,
								stall 	=> stall,
								

								-- RAM
								we 		=> if_we_ram,
								addr 	=> if_addr_ram,
								data 	=> if_data_ram,

								-- ID
								id_pc 	=> id_pc_if_ex,
								pc_id 	=> if_pc_id,

								instruction_id => if_instruction_id,

								-- EX
								ex_pc => ex_rd_1_if_mem,
								ex_branch => ex_branch_if_mem
						  	);
	
	U_ID : ID_PHASE 	port map (
								-- CTRL
								clk 	=> clk,
								load 	=> load,
								reset 	=> reset,
								stall 	=> stall_id,

								-- IF
								pc_if_ex 	=> id_pc_if_ex,
								if_pc 		=> if_pc_id,

								if_instruction => if_instruction_id,

								-- EX 
								instruction_type_ex => id_instruction_type_ex,
								opcode_ex => id_opcode_ex,
								cond_ex => id_cond_ex,
								branch_offset_ex => id_branch_offset_ex,
								is_signed_ex => id_is_signed_ex,
								link_flag_ex => id_link_flag_ex,
								load_store_ex => id_load_store_ex,
								shift_operation_ex => id_shift_operation_ex,
								shift_type_ex => id_shift_type_ex,
								immidiate_ex => id_immidiate_ex,

								rd_addr_ex => id_rd_addr_ex,
								rn_addr_ex => id_rn_addr_ex,
								rm_addr_ex => id_rm_addr_ex,
								rs_addr_ex => id_rs_addr_ex,

								rn_ex => id_rn_ex,
								rs_ex => id_rs_ex,
								rm_ex => id_rm_ex,
								rd_ex => id_rd_ex,

								-- WB
								wb_rd_1_addr 	=> wb_rd_1_addr_id,
								wb_rd_1 		=> wb_rd_1_id,
								wb_we_1 		=> wb_we_1_id,

								wb_rd_2_addr 	=> wb_rd_2_addr_id,
								wb_rd_2 		=> wb_rd_2_id,
								wb_we_2 		=> wb_we_2_id
						  	);

	U_EX : EX_PHASE 	port map (
								-- CTRL
								clk 	=> clk,
								load 	=> load,
								reset 	=> reset,
								stall 	=> stall_ex,

								-- IF
								branch_if_mem => ex_branch_if_mem,
								
								-- ID
								id_pc => id_pc_if_ex,						
								
								id_instruction_type => id_instruction_type_ex,
								id_opcode => id_opcode_ex,
								id_cond => id_cond_ex,
								id_branch_offset => id_branch_offset_ex,
								id_is_signed => id_is_signed_ex,
								id_link_flag => id_link_flag_ex,
								id_load_store => id_load_store_ex,
								id_shift_operation => id_shift_operation_ex,
								id_shift_type => id_shift_type_ex,
								id_immidiate => id_immidiate_ex,

								id_rd_addr => id_rd_addr_ex,
								id_rn_addr => id_rn_addr_ex,
								id_rm_addr => id_rm_addr_ex,
								id_rs_addr => id_rs_addr_ex,

								id_rn => id_rn_ex,
								id_rs => id_rs_ex,
								id_rm => id_rm_ex,
								id_rd => id_rd_ex,

								-- MEM
								rd_1_if_mem => ex_rd_1_if_mem,
								rd_2_mem => ex_rd_2_mem,
								rd_1_addr_mem => ex_rd_1_addr_mem,
								rd_2_addr_mem => ex_rd_2_addr_mem,

								rn_mem 				=> ex_rn_mem,
								--rn_addr_mem 		=> ex_rn_addr_mem,
								opcode_mem 			=> ex_opcode_mem,
								link_flag_mem 		=> ex_link_flag_mem,
								load_store_mem 		=> ex_load_store_mem,
								instructon_type_mem => ex_instruction_type_mem,
								reset_mem 			=> ex_reset_mem,

								-- MEM [HAZARDS]
								mem_rd_1 				=> mem_rd_1_wb,
								mem_rd_2 				=> mem_rd_2_wb,
								mem_rd_1_addr 			=> mem_rd_1_addr_wb,
								mem_rd_2_addr 			=> mem_rd_2_addr_wb,
								mem_instruction_type 	=> mem_instruction_type_wb,
								mem_load_store 			=> mem_load_store_wb,
								mem_opcode 				=> mem_opcode_wb,
								mem_link_flag 			=> mem_link_flag_wb,
								mem_branch 				=> mem_branch_wb,

								-- WB [HAZARDS]
								wb_rd_1_addr 	=> wb_rd_1_addr_id,
								wb_rd_1 		=> wb_rd_1_id,
								wb_we_1 		=> wb_we_1_id,

								wb_rd_2_addr 	=> wb_rd_2_addr_id,
								wb_rd_2 		=> wb_rd_2_id,
								wb_we_2 		=> wb_we_2_id
					      	);

	U_MEM : MEM_PHASE 	port map (
								-- CTRL
								clk		=> clk,
								load 	=> load,
								reset 	=> reset,
								stall 	=> stall_mem,

								-- EX
								ex_rd_1 			=> ex_rd_1_if_mem,
								ex_rd_2 			=> ex_rd_2_mem,
								ex_rd_1_addr 		=> ex_rd_1_addr_mem,
								ex_rd_2_addr 		=> ex_rd_2_addr_mem,

								ex_rn 				=> ex_rn_mem,
								--ex_rn_addr			=> ex_rn_addr_mem,
								ex_branch 			=> ex_branch_if_mem,
								ex_opcode			=> ex_opcode_mem,
								ex_link_flag 		=> ex_link_flag_mem,
								ex_load_store 		=> ex_load_store_mem,
								ex_instruction_type => ex_instruction_type_mem,
								ex_reset 			=> ex_reset_mem,

								-- RAM
								we 		=> mem_we_ram,
								addr 	=> mem_addr_ram,
								data 	=> mem_data_ram,

								-- WB
								rd_1_wb 			=> mem_rd_1_wb,
								rd_2_wb 			=> mem_rd_2_wb,
								rd_1_addr_wb 		=> mem_rd_1_addr_wb,
								rd_2_addr_wb 		=> mem_rd_2_addr_wb,

								instruction_type_wb => mem_instruction_type_wb,
								load_store_wb		=> mem_load_store_wb,
								opcode_wb			=> mem_opcode_wb,
								link_flag_wb		=> mem_link_flag_wb,
								branch_wb			=> mem_branch_wb
							);
	
	U_WB : WB_PHASE 	port map (
								-- CTRL
								clk		=> clk,
								load 	=> load,
								reset 	=> reset,
								stall 	=> stall_wb,

								-- MEM
								mem_rd_1 				=> mem_rd_1_wb,
								mem_rd_2 				=> mem_rd_2_wb,
								mem_rd_1_addr 			=> mem_rd_1_addr_wb,
								mem_rd_2_addr 			=> mem_rd_2_addr_wb,
								mem_instruction_type 	=> mem_instruction_type_wb,
								mem_load_store 			=> mem_load_store_wb,
								mem_opcode 				=> mem_opcode_wb,
								mem_link_flag 			=> mem_link_flag_wb,
								mem_branch 				=> mem_branch_wb,

								-- ID
								rd_1_addr_id 	=> wb_rd_1_addr_id,
								rd_1_id 		=> wb_rd_1_id,
								we_1_id 		=> wb_we_1_id,

								rd_2_addr_id 	=> wb_rd_2_addr_id,
								rd_2_id 		=> wb_rd_2_id,
								we_2_id 		=> wb_we_2_id,

								instruction_type => wb_instruction_type
							);

	U_CACHE : CACHE 	port map (
								clk => clk,
								reset => reset,
								flash => stall_wb_s,
								flashed => halt,
								
								addr 	=> addr_cache,
								we 		=> we_cache,
								data 	=> data_cache,

								addr_ram => addr,
								data_ram => data,
								we_ram   => we,

								miss => stall
							);

	stall_id	<= stall or stall_ex 	or stall_id_s;
	stall_ex	<= stall or stall_mem 	or stall_ex_s or ex_reset_mem;
	stall_mem	<= stall or stall_wb 	or stall_mem_s;
	stall_wb	<= stall or stall_wb_s;

	stall_watch : process (reset, id_instruction_type_ex, ex_instruction_type_mem, mem_instruction_type_wb, wb_instruction_type) is
	begin
		--if (reset = '1') then
			--stall_id_s <= '0';
		--elsif (id_instruction_type_ex = INSTRUCTION_TYPE_S) then
			--stall_id_s <= '1';
		--end if;

		stall_id_s <= '0';

		if (reset = '1') then
			stall_ex_s <= '0';
		elsif (ex_instruction_type_mem = INSTRUCTION_TYPE_S) then
			stall_ex_s <= '1';
		end if;

		if (reset = '1') then
			stall_mem_s <= '0';
		elsif (mem_instruction_type_wb = INSTRUCTION_TYPE_S) then
			stall_mem_s <= '1';
		end if;

		if (reset = '1') then
			stall_wb_s <= '0';
		elsif (wb_instruction_type = INSTRUCTION_TYPE_S) then
			stall_wb_s <= '1';
		end if;

	end process;

	load_signal : process (clk) 
		variable count : NATURAL := 0;
	begin
		if (rising_edge(clk)) then
			if (count < PHASE_DURATION/2) then
				load <= '1';
			else 
				load <= '0';
			end if;

			count := (count + 1) mod PHASE_DURATION;
		end if;
	end process;

	arbitrator : process (clk, mem_we_ram, mem_data_ram, mem_addr_ram, if_addr_ram, if_we_ram, if_data_ram) 
		variable step : INTEGER := PHASE_DURATION - 1;
	begin
		if (falling_edge(clk) and stall = '0') then
			step := (step + 1) mod PHASE_DURATION;

			addr_cache <= UNDEFINED_32;
			we_cache <= UNDEFINED_1;

			data_cache <= HIGH_Z_32;
			mem_data_ram <= HIGH_Z_32;
			if_data_ram <= HIGH_Z_32;

			case step is
				when 1 =>
					we_cache <= mem_we_ram;
					addr_cache <= mem_addr_ram;

					if (mem_we_ram = '1') then
						data_cache <= mem_data_ram; 
					end if;

				when 2 =>
					mem_data_ram <= data_cache;

				when 3 =>
					we_cache <= if_we_ram;
					addr_cache <= if_addr_ram;

					if (if_we_ram = '1') then
						data_cache <= if_data_ram; 
					end if;

				when 4 =>
					if_data_ram <= data_cache;

				when others  =>
			end case;
		end if;
		
	end process;
	
end architecture STR;