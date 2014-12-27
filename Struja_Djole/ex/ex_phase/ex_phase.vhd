library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;  
use WORK.CPU_LIB.all;

entity EX_PHASE is
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
		link_flag_mem		: out STD_LOGIC;
		opcode_mem			: out OPCODE_TYPE;
		instructon_type_mem : out INSTRUCTION_TYPE_TYPE;
		reset_mem			: out STD_LOGIC;

		-- MEM_PHASE[alu_out], IF_PHASE[pc]
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
end entity EX_PHASE;

architecture STR of EX_PHASE is
	procedure HAZARD(
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
		wb_we_2 		: STD_LOGIC;

		reg_in			: REG_TYPE;
		reg_addr 		: REG_ADDR_TYPE;

		signal reg_out 		: out REG_TYPE
	) is
	begin
		if (mem_rd_1_addr = reg_addr and 
			(mem_instruction_type = INSTRUCTION_TYPE_DP_R or mem_instruction_type = INSTRUCTION_TYPE_DP_I) and
			mem_opcode /= OPCODE_CMP
		) then
			-- MEM[rd1]
			reg_out <= mem_rd_1;
		elsif (mem_rd_2_addr = reg_addr and 
			((mem_instruction_type = INSTRUCTION_TYPE_DP_R and  mem_opcode = OPCODE_SWAP) or
			(mem_instruction_type = INSTRUCTION_TYPE_B_BL and mem_branch = '1' and mem_link_flag = '1'))
		) then
			-- MEM[rd2]
			reg_out <= mem_rd_2;
		elsif (wb_rd_1_addr = reg_addr and wb_we_1 = '1') then
			-- WB[rd1]
			reg_out <= wb_rd_1;
		elsif (wb_rd_2_addr = reg_addr and wb_we_2 = '1') then
			-- WB[rd2]
			reg_out <= wb_rd_2;
		else 
			-- reg_in
			reg_out <= reg_in;			
		end if;
	end HAZARD;

	component REG_EX is
		port
		(
		-- Input ports
		load : STD_LOGIC;
		reset : STD_LOGIC;
		stall : STD_LOGIC;
		
        pc_in : REG_TYPE;

		instruction_type_in : INSTRUCTION_TYPE_TYPE;
		opcode_in			: OPCODE_TYPE;
		cond_in				: COND_TYPE;
		branch_offset_in	: BRANCH_OFFSET_TYPE;
		is_signed_in		: STD_LOGIC;
		link_flag_in		: STD_LOGIC;
		load_store_in		: STD_LOGIC;
		shift_operation_in	: STD_LOGIC;
		shift_type_in		: SHIFT_TYPE_TYPE;
		immidiate_in		: REG_TYPE;

		rd_addr_in 			: REG_ADDR_TYPE;
		rn_addr_in 			: REG_ADDR_TYPE;
		rm_addr_in 			: REG_ADDR_TYPE;
		rs_addr_in 			: REG_ADDR_TYPE;
		
		rn_in		: REG_TYPE;
		rs_in		: REG_TYPE;
		rm_in		: REG_TYPE;
		rd_in 		: REG_TYPE;
			
		-- Output ports
        pc_out		: out REG_TYPE;

		instruction_type_out 	: out INSTRUCTION_TYPE_TYPE;
		opcode_out			 	: out OPCODE_TYPE;
		cond_out				: out COND_TYPE;
		branch_offset_out		: out BRANCH_OFFSET_TYPE;
		is_signed_out			: out STD_LOGIC;
		link_flag_out			: out STD_LOGIC;
		load_store_out			: out STD_LOGIC;
		shift_operation_out		: out STD_LOGIC;
		shift_type_out			: out SHIFT_TYPE_TYPE;
		immidiate_out			: out REG_TYPE;

		rd_addr_out 			: out REG_ADDR_TYPE;
		rn_addr_out 			: out REG_ADDR_TYPE;
		rm_addr_out 			: out REG_ADDR_TYPE;
		rs_addr_out 			: out REG_ADDR_TYPE;
		
		rn_out		: out REG_TYPE;
		rs_out		: out REG_TYPE;
		rm_out		: out REG_TYPE;
		rd_out 		: out REG_TYPE
	);
	end component;
	component MUX_2_IN_1 is
		port
		(
			a	: in  REG_TYPE;
			b	: in  REG_TYPE;
			sel	: in  STD_LOGIC;

			z	: out REG_TYPE
		);
	end component;

	component ALU is
		port
		(
			clk : STD_LOGIC;

			opcode		: OPCODE_TYPE;
			is_signed 	: STD_LOGIC;

			a : REG_TYPE;
			b : REG_TYPE;
		
			carry_in 	: STD_LOGIC;
			zero_in 	: STD_LOGIC;
			overflow_in : STD_LOGIC;
			negative_in : STD_LOGIC;

			-- output ports
			result : out REG_TYPE;
			
			carry_out		: out STD_LOGIC;
			zero_out 		: out STD_LOGIC;
			overflow_out 	: out STD_LOGIC;
			negative_out 	: out STD_LOGIC
		); 
	end component;

	component SHIFTER is
		port 
		(
        	shift_operation: STD_LOGIC;
        	shift_type: SHIFT_TYPE_TYPE;
      
        	Rn: REG_TYPE;
        	Rs: REG_TYPE;

        	result : out REG_TYPE
    	);
	end component;

	component BRANCH is
		port 
		(
			instruction_type : INSTRUCTION_TYPE_TYPE;
			N, C, V, Z: STD_LOGIC;
			cond : COND_TYPE;
		
			branch_taken : out STD_LOGIC
    	);
	end component;
	
	component CSR is
		port
		(
			-- Input ports 
			load 	: STD_LOGIC;
			reset 	: STD_LOGIC;

			n_in : STD_LOGIC;
			c_in : STD_LOGIC;
			v_in : STD_LOGIC;
			z_in : STD_LOGIC;
		
			-- Output ports
			n_out : out STD_LOGIC;
			c_out : out STD_LOGIC;
			v_out : out STD_LOGIC;
			z_out : out STD_LOGIC
	);
	end component;

	
	signal mux_a_out : REG_TYPE;
	signal mux_b_out : REG_TYPE;
	signal mux_jmp_out : REG_TYPE;
	signal branch_taken : std_logic; -- branch_taken
	signal shift_res: REG_TYPE;
	signal imm : std_logic;
	signal branch_offset : std_logic;
	signal csr_n_flag, csr_c_flag, csr_v_flag, csr_z_flag: STD_LOGIC;
	signal alu_n_flag, alu_c_flag, alu_v_flag, alu_z_flag: STD_LOGIC;

	signal reg_pc 				: REG_TYPE;
	signal reg_instruction_type : INSTRUCTION_TYPE_TYPE;
	signal reg_opcode			: OPCODE_TYPE;
	signal reg_cond				: COND_TYPE;
	signal reg_branch_offset	: BRANCH_OFFSET_TYPE;
	signal reg_is_signed		: STD_LOGIC;
	signal reg_link_flag		: STD_LOGIC;
	signal reg_load_store		: STD_LOGIC;
	signal reg_shift_operation	: STD_LOGIC;
	signal reg_shift_type		: SHIFT_TYPE_TYPE;
	signal reg_immidiate		: REG_TYPE;

	signal reg_rd_addr 			: REG_ADDR_TYPE;	
	signal reg_rn_addr 			: REG_ADDR_TYPE;	
	signal reg_rm_addr 			: REG_ADDR_TYPE;	
	signal reg_rs_addr 			: REG_ADDR_TYPE;	
		
	signal reg_rn				: REG_TYPE;
	signal reg_rs				: REG_TYPE;
	signal reg_rm				: REG_TYPE;
	signal reg_rd 				: REG_TYPE;

	signal rd_hz				: REG_TYPE;
	signal rn_hz				: REG_TYPE;
	signal rm_hz				: REG_TYPE;
	signal rs_hz 				: REG_TYPE;

	signal alu_out 				: REG_TYPE;

	signal reg_reset			: STD_LOGIC;
	signal mov_branch 			: STD_LOGIC;
	signal swap_pc 				: STD_LOGIC;
begin
	U_REG_EX: REG_EX port map (
								load  => load, 									--in EX_PHASE.load
								reset => reg_reset,
								stall => stall,

								pc_in => id_pc,									--in ID_PHASE.id

								instruction_type_in => id_instruction_type,		--in ID_PHASE.instruction_type
								opcode_in => id_opcode,							--in ID_PHASE.opcode
								cond_in => id_cond,								--in ID_PHASE.cond
								branch_offset_in => id_branch_offset,			--in ID_PHASE.branch_offset
								is_signed_in => id_is_signed,					--in ID_PHASE.is_signed
								link_flag_in => id_link_flag,					--in ID_PHASE.id_link_flag
								load_store_in => id_load_store,					--in ID_PHASE.load_store
								shift_operation_in => id_shift_operation,		--in ID_PHASE.shift_operation
								shift_type_in => id_shift_type,					--in ID_PHASE.shift_type
								immidiate_in => id_immidiate, 					--in ID_PHASE.immediate

								rd_addr_in => id_rd_addr,						--in ID_PHASE.rd_addr
								rn_addr_in => id_rn_addr,						--in ID_PHASE.rn_addr
								rm_addr_in => id_rm_addr,						--in ID_PHASE.rm_addr
								rs_addr_in => id_rs_addr,						--in ID_PHASE.rs_addr
		
								rn_in => id_rn,									--in ID_PHASE.rn
								rs_in => id_rs,									--in ID_PHASE.rs
								rm_in => id_rm,									--in ID_PHASE.rm
								rd_in => id_rd,									--in ID_PHASE.rd
		
								-- Output ports
        						pc_out => reg_pc,								--out MUX_A.a 

								instruction_type_out => reg_instruction_type,	--out MEM_instruction_type
								opcode_out => reg_opcode,						--out ALU.opcode
								cond_out => reg_cond,							--out BRANCH.cond
								branch_offset_out => reg_branch_offset,			--out MUX_JMP_OFFSET.a
								is_signed_out => reg_is_signed,					--out ALU.is_signed
								link_flag_out => reg_link_flag,					--out ALU.is_signed
								load_store_out => reg_load_store,				--out MEM_PHASE.load_store
								shift_operation_out	=> reg_shift_operation,		--out SHIFTER.shift_operation
								shift_type_out => reg_shift_type,				--out SHIFTER.shift_type
								immidiate_out => reg_immidiate,					--out MUX_B.b

								rd_addr_out => reg_rd_addr,						--out MEM_PHASE.rd_addr
								rn_addr_out => reg_rn_addr,						--out MEM_PHASE.rn_addr
								rm_addr_out => reg_rm_addr,						--out MEM_PHASE.rm_addr
								rs_addr_out => reg_rs_addr,						--out MEM_PHASE.rs_addr
		
								rn_out => reg_rn,								--out SHIFTER.rn
								rs_out => reg_rs,								--out SHIFTER.rs
								rm_out => reg_rm,								--out MUX_B.a
								rd_out => reg_rd								--out MUX_B.a

		);
	U_MUX_A: MUX_2_IN_1 port map(
								a => shift_res,									--in REG_EX.pc				
								b => reg_pc,									--in SHIFT.result
								sel => branch_taken,							--in BRANCH.branch_taken 
								z => mux_a_out									--out ALU.a
							);

	U_MUX_JMP_OFFSET: MUX_2_IN_1 port map(
								a => reg_branch_offset,							--in REG_EX.branch_offset
								b => reg_immidiate,								--in REG_EX.immediate
								sel => imm,										--in EX_PHASE.imm
								z => mux_jmp_out								--out MUX_B.b
							);

	U_MUX_B: MUX_2_IN_1 port map(
								a => rm_hz,										--in REG_EX.Rm
								b => mux_jmp_out,								--in REG_EX.immediate
								sel => branch_offset,							--in EX_PHASE.branch_offset
								z => mux_b_out									--out ALU.b
							);

	U_BRANCH: BRANCH port map(
								instruction_type => reg_instruction_type,		--in REG_EX.instruction_type
	
								N => csr_n_flag,								--in CSR.n_out
								C => csr_c_flag,								--in CSR.c_out
								V => csr_v_flag,								--in CSR.v_out
								Z => csr_z_flag,								--in CSR.z_out
								cond => reg_cond,								--in REG_EX.cond

								branch_taken => branch_taken 					--out MUX_B.sel
							);

	U_SHIFTER: SHIFTER port map(
								shift_operation => reg_shift_operation,		--in REG_EX.shift_operation
								shift_type => reg_shift_type,				--in REG_EX.shif_type
								Rn => rn_hz,								--in REG_EX.Rn
								Rs => rs_hz, 								--in REG_EX.Rs

								result => shift_res							--out MUX_A.a
							);

	U_ALU: ALU port map(
						clk => clk,											--in EX_PHASE.clock

						opcode => reg_opcode,								--in REG_EX.opcode
						is_signed => reg_is_signed,							--in REG_EX.is_signed

						a => mux_a_out,										--in MUX_A.z
						b => mux_b_out,										--in MUX_B.z
			
						carry_in => csr_c_flag,								--in CSR.c_out
						overflow_in => csr_v_flag,							--in CSR.v_out
						negative_in => csr_n_flag,							--in CSR.n_out
						zero_in => csr_z_flag,								--in CSR.z_out

						result => alu_out,									--out MEM_PHASE	

						carry_out => alu_c_flag,							--out CSR.c_in
						zero_out => alu_z_flag,								--out CSR.z_in
						overflow_out => alu_v_flag,							--out CSR.v_in
						negative_out => alu_n_flag							--out CSR.n_in
					);
	
	U_CSR: CSR port map(
						-- Input ports 
						load => load,										--in ALU.fc
						reset => reset,
		
						n_in => alu_n_flag,									--in ALU.negative_out
						c_in => alu_c_flag,									--in ALU.carry_out
						v_in => alu_v_flag,									--in ALU.overflow_out
						z_in => alu_z_flag,									--in ALU.zero_out
		
						-- Output ports
						n_out => csr_n_flag,								--out BRANCH.N
						c_out => csr_c_flag,								--out BRANCH.C
						v_out => csr_v_flag,								--out BRANCH.V
						z_out => csr_z_flag									--out BRANCH.Z
					);

	branch_if_mem <= branch_taken or mov_branch;
	rn_mem <= rn_hz;
	rn_addr_mem <= reg_rn_addr;
	load_store_mem <= reg_load_store;
	rd_1_addr_mem <= reg_rd_addr;
	opcode_mem <= reg_opcode;
	link_flag_mem <= reg_link_flag;
	reg_reset <= reset or ((branch_taken or mov_branch or swap_pc) and not stall);

	branch_mov : process (reg_instruction_type, reg_opcode, reg_rd_addr) is
		variable PC_ADDR_VAR : REG_ADDR_TYPE := REG_ADDR_TYPE(TO_UNSIGNED(PC_ADDR, REG_ADDR_TYPE'length));
	begin
		
		if (reg_opcode /= OPCODE_CMP and reg_opcode /= OPCODE_SWAP and
			(reg_instruction_type = INSTRUCTION_TYPE_DP_I or reg_instruction_type = INSTRUCTION_TYPE_DP_R)  and
			reg_rd_addr = PC_ADDR_VAR
		) then
			mov_branch <= '1';
			instructon_type_mem <= INSTRUCTION_TYPE_NOOP;
		else
			mov_branch <= '0';
			instructon_type_mem <= reg_instruction_type;
		end if;
	end process;


	hazards : process (mem_instruction_type, mem_load_store, mem_opcode, mem_link_flag, mem_branch, mem_rd_1,
		mem_rd_1_addr, mem_rd_2, mem_rd_2_addr, wb_rd_1_addr, wb_rd_1, wb_we_1, wb_rd_2_addr, wb_rd_2, wb_we_2,
		reg_rd_addr, reg_rd, reg_rn_addr, reg_rn, reg_rm_addr, reg_rm, reg_rs, reg_rs_addr, reg_pc) is
	begin
		HAZARD(
			mem_instruction_type, mem_load_store, mem_opcode, mem_link_flag, mem_branch,
			mem_rd_1, mem_rd_1_addr, mem_rd_2, mem_rd_2_addr,
			wb_rd_1_addr , wb_rd_1, wb_we_1,
			wb_rd_2_addr, wb_rd_2, wb_we_2,
			reg_rd, reg_rd_addr, rd_hz
		);

		HAZARD(
			mem_instruction_type, mem_load_store, mem_opcode, mem_link_flag, mem_branch,
			mem_rd_1, mem_rd_1_addr, mem_rd_2, mem_rd_2_addr,
			wb_rd_1_addr , wb_rd_1, wb_we_1,
			wb_rd_2_addr, wb_rd_2, wb_we_2,
			reg_rn, reg_rn_addr, rn_hz
		);

		HAZARD(
			mem_instruction_type, mem_load_store, mem_opcode, mem_link_flag, mem_branch,
			mem_rd_1, mem_rd_1_addr, mem_rd_2, mem_rd_2_addr,
			wb_rd_1_addr , wb_rd_1, wb_we_1,
			wb_rd_2_addr, wb_rd_2, wb_we_2,
			reg_rm, reg_rm_addr, rm_hz
		);

		HAZARD(
			mem_instruction_type, mem_load_store, mem_opcode, mem_link_flag, mem_branch,
			mem_rd_1, mem_rd_1_addr, mem_rd_2, mem_rd_2_addr,
			wb_rd_1_addr , wb_rd_1, wb_we_1,
			wb_rd_2_addr, wb_rd_2, wb_we_2,
			reg_rs, reg_rs_addr, rs_hz
		);

		-- stall in case of memory load operation which loads one of the registers used in ex phase
		if ((mem_rd_1_addr = reg_rd_addr or mem_rd_1_addr = reg_rn_addr or mem_rd_1_addr = reg_rm_addr or mem_rd_1_addr = reg_rs_addr) and
			 mem_instruction_type = INSTRUCTION_TYPE_L_S and mem_load_store = L_MEMORY_LOAD) then
			reset_mem <= '1';
		else 
			reset_mem <= '0';
		end if;
	end process;

	swap_pc_logic : process(
			mem_instruction_type, mem_load_store, mem_opcode, mem_link_flag, mem_branch,
			mem_rd_1, mem_rd_1_addr, mem_rd_2, mem_rd_2_addr,
			wb_rd_1_addr , wb_rd_1, wb_we_1,
			wb_rd_2_addr, wb_rd_2, wb_we_2
		) is
		variable PC_ADDR_VAR : REG_ADDR_TYPE := REG_ADDR_TYPE(TO_UNSIGNED(PC_ADDR, REG_ADDR_TYPE'length));
	begin
		if (reg_rd_addr = PC_ADDR_VAR and reg_instruction_type = INSTRUCTION_TYPE_DP_R and
			reg_opcode = OPCODE_SWAP
		) then
			swap_pc <= '1';
		elsif (reg_rm_addr = PC_ADDR_VAR and reg_instruction_type = INSTRUCTION_TYPE_DP_R and  
			reg_opcode = OPCODE_SWAP
		) then
			swap_pc <= '1';
		elsif (mem_rd_1_addr = PC_ADDR_VAR and mem_instruction_type = INSTRUCTION_TYPE_DP_R and
			mem_opcode = OPCODE_SWAP
		) then
			swap_pc <= '1';
		elsif (mem_rd_2_addr = PC_ADDR_VAR and mem_instruction_type = INSTRUCTION_TYPE_DP_R and  
			mem_opcode = OPCODE_SWAP
		) then
			-- MEM[rd2]
			swap_pc <= '1';
		elsif (wb_rd_1_addr = PC_ADDR_VAR and wb_we_1 = '1') then
			-- WB[rd1]
			swap_pc <= '1';
		elsif (wb_rd_2_addr = PC_ADDR_VAR and wb_we_2 = '1') then
			-- WB[rd2]
			swap_pc <= '1';
		else 
			-- reg_in
			swap_pc <= '0';		
		end if;
	end process;
	

	mux_logic : process(reg_instruction_type) is
	begin
		if (reg_instruction_type = INSTRUCTION_TYPE_DP_I 
			or 
			reg_instruction_type = INSTRUCTION_TYPE_B_BL) then
			branch_offset <= '1';
			if(reg_instruction_type = INSTRUCTION_TYPE_DP_I) then
				imm <= '1';
			else
				imm <= '0';
			end if;
		else
			branch_offset <= '0';
			imm <= '0';
		end if;
	end process;

	rd_1_rd_2_logic : process (reg_instruction_type, reg_pc, alu_out, reg_rd_addr, 
		reg_link_flag, reg_opcode, reg_load_store, rd_hz, reg_rm_addr) is
	begin
		-- in case of store operation first rd_1 is rd_hz
		if (reg_instruction_type = INSTRUCTION_TYPE_L_S and reg_load_store = L_MEMORY_STORE) then
			rd_1_if_mem <= rd_hz;
		else
			rd_1_if_mem <= alu_out;
		end if;

		-- in case of swap operation rd register should go to out to mem as rd_2
		if (reg_instruction_type = INSTRUCTION_TYPE_DP_R and reg_opcode = OPCODE_SWAP) then
			rd_2_mem <= rd_hz;
			rd_2_addr_mem <= reg_rm_addr;
		-- in case of branch operation, branch addr is in rd_1 so we just need to pass old pc to rd2
		elsif (reg_instruction_type = INSTRUCTION_TYPE_B_BL and reg_link_flag = L_BRANCH_AND_LINK) then
			rd_2_mem <= reg_pc;
			rd_2_addr_mem <= REG_ADDR_TYPE(STD_LOGIC_VECTOR(TO_UNSIGNED(LINK_ADDR, REG_ADDR_TYPE'length)));
		-- unused
		else 
			rd_2_mem <= UNDEFINED_32;
			rd_2_addr_mem <= UNDEFINED_4;
		end if;
	end process;

end architecture STR;