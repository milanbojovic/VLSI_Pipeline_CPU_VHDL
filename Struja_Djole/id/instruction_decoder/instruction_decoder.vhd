library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
--use IEEE.NUMERIC_STD.all;
use WORK.CPU_LIB.all;


--
-- instruction : instruction value loaded from memory
-- instruction_type : determens instruction type (one of the constants)
-- opcode : operaction code, one of the instruction constants
-- cond : cond code EQ, GT, HI, AL

-- is_signed : flag that says if signed operation in alu should be used
-- load_store : flag that controls if store or load instruction is used (1 - store, 0 - load): 
-- link_flag: determens if linking should be done during jump instructions (1 - link, 0 - none)

-- RnAddr : address of the Rn register of instruction
-- RdAddr : address of the Rd register of instruction
-- RmAddr : address of the Rm register of instruction
-- RsAddr : address of the Rs register of instruction

-- shift_operation : determens shift operation (0 - shift, 1 - rotate)
-- shift_type: type of shift instuction (00 - LL, 01 - LSR, 10 - ASR, 11 - NONE)

-- immidiate : immidiate value from instruction

entity INSTRUCTION_DECODER is
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
end INSTRUCTION_DECODER;

architecture RTL of INSTRUCTION_DECODER is

	shared variable instruction_type_var : INSTRUCTION_TYPE_TYPE;

	procedure load_register(signal reg_address : out REG_ADDR_TYPE;
									address : in REG_ADDR_TYPE) is
	begin
		if (instruction_type_var = INSTRUCTION_TYPE_DP_R or 
			instruction_type_var = INSTRUCTION_TYPE_DP_I or 
			instruction_type_var = INSTRUCTION_TYPE_L_S or 
			instruction_type_var = INSTRUCTION_TYPE_RMW) then
			 
			reg_address <= address;
		else 
			reg_address <= UNDEFINED_4;
		end if;
	end;
begin

	process (instruction)
		variable offset : STD_LOGIC_VECTOR(25 downto 0);
	begin
	
		instruction_type_var := instruction(31 downto 29);
		
		-- instruction_type
		instruction_type <= instruction_type_var;

		-- opcode
		if (instruction_type_var = INSTRUCTION_TYPE_DP_R or 
			instruction_type_var = INSTRUCTION_TYPE_DP_I or 
			instruction_type_var = INSTRUCTION_TYPE_RMW) then
			 
			opcode <=  OPCODE_TYPE(instruction(28 downto 25));
		elsif (instruction_type_var = INSTRUCTION_TYPE_B_BL) then
			-- branch needs to use alu unit with signed operation add
			opcode <= OPCODE_BRANCH;
		else 
			opcode <= UNDEFINED_4;
		end if;

		-- RnAddr
		load_register(RnAddr, REG_ADDR_TYPE(instruction(24 downto 21)));
		
		-- RdAddr
		load_register(RdAddr, REG_ADDR_TYPE(instruction(20 downto 17)));
		
		-- RmAddr
		if (instruction_type_var = INSTRUCTION_TYPE_DP_R or 
			instruction_type_var = INSTRUCTION_TYPE_RMW) then
			 
			RmAddr <= REG_ADDR_TYPE(instruction(15 downto 12));
		else 
			RmAddr <= UNDEFINED_4;
		end if;
		
		-- RsAddr
		if (instruction_type_var = INSTRUCTION_TYPE_DP_R) then
		
			RsAddr <= REG_ADDR_TYPE(instruction(11 downto 8));
		else 
			RsAddr <= UNDEFINED_4;
		end if;


		-- is_signed
		if (instruction_type_var = INSTRUCTION_TYPE_DP_R or 
			instruction_type_var = INSTRUCTION_TYPE_DP_I or 
			instruction_type_var = INSTRUCTION_TYPE_RMW) then
			 
			is_signed <= instruction(16);
		else 
			is_signed <= UNDEFINED_1;
		end if;

		-- load_store
		if (instruction_type_var = INSTRUCTION_TYPE_L_S) then
			 
			load_store <= instruction(28);
		else 
			load_store <= UNDEFINED_1;
		end if;

	 	-- cond
		 if (instruction_type_var = INSTRUCTION_TYPE_B_BL) then
		
			cond <= COND_TYPE(instruction(28 downto 27));
			offset := instruction(25 downto 0);
			if(offset(25) = '1') then
				branch_offset <= BRANCH_OFFSET_TYPE(MAX_6 & offset);
			else
				branch_offset <= BRANCH_OFFSET_TYPE(ZERO_6 & offset);
			end if;

		else 
			cond <= UNDEFINED_2;
			branch_offset <= UNDEFINED_32;
		end if;

		-- link_flag
		if (instruction_type_var = INSTRUCTION_TYPE_B_BL) then
			 
			link_flag <= instruction(26);
		else 
			link_flag <= UNDEFINED_1;
		end if;

		-- shift_operation
		if (instruction_type_var = INSTRUCTION_TYPE_DP_R) then
			 
			shift_operation <= instruction(7);
		else 
			shift_operation <= UNDEFINED_1;
		end if;

		-- shift_type
		if (instruction_type_var = INSTRUCTION_TYPE_DP_R) then
			 
			shift_type <= instruction(6 downto 5);
		else 
			shift_type <= UNDEFINED_2;
		end if;

		-- immidiate
		if (instruction_type_var = INSTRUCTION_TYPE_DP_I) then
			 
			immidiate <= instruction(15 downto 0);
		else 
			immidiate <= UNDEFINED_16;
		end if;
		
	end process;

end RTL;

