library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;

use WORK.CPU_LIB.all;

entity ID_PHASE is
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
		is_signed_ex		: out STD_LOGIC;
		load_store_ex		: out STD_LOGIC;
		shift_operation_ex	: out STD_LOGIC;
		shift_type_ex		: out SHIFT_TYPE_TYPE;
		immidiate_ex		: out REG_TYPE;
		branch_offset_ex 	: out BRANCH_OFFSET_TYPE;
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
		rd_ex 	: out REG_TYPE;

		-- WB_PHASE
		wb_rd_1_addr 	: REG_ADDR_TYPE;
		wb_rd_1 		: REG_TYPE;
		wb_we_1 		: STD_LOGIC;

		wb_rd_2_addr 	: REG_ADDR_TYPE;
		wb_rd_2 		: REG_TYPE;
		wb_we_2 		: STD_LOGIC
	);
	

end entity ID_PHASE;

architecture STR of ID_PHASE is
	component REG_ID is
		port
		(
				-- Input ports
			load : STD_LOGIC;
			reset : STD_LOGIC;
			stall	: STD_LOGIC;

			pc_in: REG_TYPE;
			instruction_in : REG_TYPE;
		
			-- Output ports
			pc_out : out REG_TYPE;
			instruction_out : out REG_TYPE
		);
	end component;

	component INSTRUCTION_DECODER is
		port
		(
			-- Input ports
			instruction	: in REG_TYPE;

			-- Output ports
			instruction_type : out INSTRUCTION_TYPE_TYPE;
			opcode: out OPCODE_TYPE;
			cond: out COND_TYPE;
			branch_offset: out BRANCH_OFFSET_TYPE;
		
			is_signed: out STD_LOGIC;
			load_store: out STD_LOGIC;
			link_flag: out STD_LOGIC;
		
			RnAddr: out REG_ADDR_TYPE;
			RdAddr: out REG_ADDR_TYPE;
			RmAddr: out REG_ADDR_TYPE;
			RsAddr: out REG_ADDR_TYPE;
		
			shift_operation: out STD_LOGIC;
			shift_type: out SHIFT_TYPE_TYPE;
		
			immidiate: out IMMIDIATE_TYPE
		);
	end component;

	component REGISTERS is
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

	end component;

	component SIGN_EXTEND is
		port
		(
			a : in IMMIDIATE_TYPE;
			result : out REG_TYPE
		);
	end component;

	-- SIGNALS
	signal rn_addr : REG_ADDR_TYPE;
	signal rm_addr : REG_ADDR_TYPE;
	signal rs_addr : REG_ADDR_TYPE;
	signal rd_addr : REG_ADDR_TYPE;

	signal reg_instruction : REG_TYPE;
	signal reg_pc : REG_TYPE;
		
	signal immidiate_16 : IMMIDIATE_TYPE;


begin
	U_REG_ID: REG_ID port map (
								-- Input ports
								load => load, --TODO replace this with next_step counter output
								reset => reset,
								stall => stall,
		
								pc_in => if_pc,
								instruction_in => if_instruction,
		
								-- Output ports
								pc_out => reg_pc,
								instruction_out => reg_instruction
		);
	U_ID: INSTRUCTION_DECODER 	port map (
										instruction => reg_instruction,				--in REG_ID.instruction_out

										RnAddr => rn_addr,							--out REGISTERS.RnAddr
										RmAddr => rm_addr,							--out REGISTERS.RmAddr
										RsAddr => rs_addr,							--out REGISTERS.RsAddr
										RdAddr => rd_addr,							--out 

										instruction_type 	=> instruction_type_ex, --out ID_PHASE.instruction_type
										opcode 				=> opcode_ex,			--out ID_PHASE.opcode
										cond 				=> cond_ex,				--out ID_PHASE.cond
										is_signed 			=> is_signed_ex,		--out ID_PHASE.is_signed
										load_store 			=> load_store_ex,		--out ID_PHASE.load_store
										branch_offset       => branch_offset_ex,	--out ID_PHASE.branch_offset 

										link_flag => link_flag_ex,					--out ID_PHASE.link_flag_ex

										shift_operation => shift_operation_ex,		--out ID_PHASE.shift_operation 
										shift_type 		=> shift_type_ex,			--out ID_PHASE.shift_type

										immidiate => immidiate_16					--out SIGN_EXTEND.a
					  				);

	U_R: REGISTERS port map (
							clk 		=> clk, 			--in ID_PHASE.clk 
							reset 		=> reset, 			--in ID_PHASE.reset 

							pc_in 		=> reg_pc, 			--in REG_ID.pc 
							pc_out 		=> pc_if_ex, 		--out ID_PHASE.pc 

							in_1 		=> wb_rd_1, 		--in ID_PHASE.wb_rd_1
							we_1 		=> wb_we_1,			--in ID_PHASE.wb_we_1
							in_1_addr	=> wb_rd_1_addr,	--in ID_PHASE.wb_rd_addr_1

							in_2 		=> wb_rd_2, 		--in ID_PHASE.wb_rd_2
							we_2 		=> wb_we_2,			--in ID_PHASE.wb_we_2
							in_2_addr	=> wb_rd_2_addr,	--in ID_PHASE.wb_rd_addr_2

							rn_addr 	=> rn_addr,			--in INSTRUCTION_DECODER.rn_addr
							rm_addr 	=> rm_addr,			--in INSTRUCTION_DECODER.rm_addr
							rs_addr 	=> rs_addr,			--in INSTRUCTION_DECODER.rs_addr
							rd_addr 	=> rd_addr,			--in INSTRUCTION_DECODER.rs_addr

							rn 			=> rn_ex,			--out ID_PHASE.rn_ex
							rs 			=> rs_ex,			--out ID_PHASE.rs_ex
							rm 			=> rm_ex,			--out ID_PHASE.rm_ex
							rd 			=> rd_ex			--out ID_PHASE.rd_ex
						);

	U_SE: SIGN_EXTEND 	port map (
								a => immidiate_16, 			--in INSTRUCTION_DECODER.immidiate
								result => immidiate_ex 		--out ID_PHASE.immidiate
							);

	rd_addr_ex <= rd_addr;
	rn_addr_ex <= rn_addr;
	rm_addr_ex <= rm_addr;
	rs_addr_ex <= rs_addr;
end architecture STR;

