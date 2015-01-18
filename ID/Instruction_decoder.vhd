library IEEE; 
library WORK;

use IEEE.STD_LOGIC_1164.all;
--use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
--use WORK.EX_IF_PKG.all;
--use WORK.IF_ID_pkg.all;
use IEEE.STD_LOGIC_ARITH.all;

entity INSTRUCTION_DECODER is

	port
	(
		-- Input ports
		instruction	: in REG_TYPE;
		
		-- Output ports
		opcode      	: out OPCODE_TYPE;
		operand_A		: out REG_ADDR_TYPE; 				-- Operand_A address in register file 
		operand_B		: out REG_ADDR_TYPE; 				-- Operand_B address in register file 
		immediate		: out IMMEDIATE_TYPE;      		-- Immediate value 
		destination 	: out REG_ADDR_TYPE; 				-- Register index in the register file where the result will be put
		mem_address	   : out REG_ADDR_TYPE;					-- Register index which contains the address in memmmory when doing LOAD/STORE instructions 
		reg_address    : out REG_ADDR_TYPE;					-- Register index wich is the destination with LOAD instruction 
		store_data		: out REG_ADDR_TYPE;					-- Reguster index which contains the data wich will be put in memory with STORE instruction
		offset 			: out BRANCH_OFFSET_TYPE;			-- Address offset with branch instructions
		DPR_decoder  	: out STD_LOGIC; 						-- Extract the registers data acording to the DPR instruction's requirements
		DPI_decoder		: out STD_LOGIC;						-- Extract the registers data acording to the DPR instruction's requirements
		BRANCH_decoder	: out STD_LOGIC;						-- Extract the registers data acording to the DPR instruction's requirements
		LOAD_decoder   : out STD_LOGIC;
		STORE_decoder  : out STD_LOGIC
		);
end INSTRUCTION_DECODER;


architecture decoder_arch of INSTRUCTION_DECODER is

	shared variable opcode_var : OPCODE_TYPE;

begin
	
	process(instruction)
	
	begin
		
		opcode_var := instruction(31 downto 27);
		--UBACI I JEDAN IF BLOCK AKO JE NEKA NEDEFINISANA INSTRUKCIJA!!!
		
		if (opcode_var /= UNDEFINED_5) then 
		
			if(opcode_var < OPCODE_UMOV) then	
			
				operand_A   	<= instruction(26 downto 22);
				operand_B   	<= instruction(21 downto 17);
				destination 	<= instruction(16 downto 12);
				DPI_decoder 	<= '0';
				BRANCH_decoder <= '0';
				LOAD_decoder   <= '0';
				STORE_decoder  <= '0';
				DPR_decoder 	<= '1';
				
			end if;
			if ( (opcode_var = OPCODE_UMOV) or (opcode_var = OPCODE_SMOV) ) then	
				
				operand_A  		<= instruction(26 downto 22);
				destination 	<= instruction(21 downto 17);
				immediate   	<= instruction(16 downto 0);
				DPR_decoder 	<= '0';
				BRANCH_decoder <= '0';
				LOAD_decoder   <= '0';
				STORE_decoder  <= '0';
				DPI_decoder 	<= '1';
					
			end if;
			if (opcode_var = OPCODE_LOAD) then	
				
				mem_address <= instruction(26 downto 22);
				reg_address <= instruction(21 downto 17);
				DPR_decoder 	<= '0';
				DPI_decoder 	<= '0';
				BRANCH_decoder <= '0';
				STORE_decoder  <= '0';
				LOAD_decoder   <= '1';
			
			end if;
			if (opcode_var = OPCODE_STORE) then	
			
				mem_address <= instruction(26 downto 22);
				store_data  <= instruction(21 downto 17);
				DPR_decoder 	<= '0';
				DPI_decoder 	<= '0';
				BRANCH_decoder <= '0';
				LOAD_decoder   <= '0';
				STORE_decoder  <= '1';
			
			end if;
		  if ((opcode_var >= OPCODE_BEQ) and (opcode_var < OPCODE_STOP)) then 
				
				offset <= instruction(26 downto 0);
				DPR_decoder 	<= '0';
				DPI_decoder 	<= '0';
				LOAD_decoder   <= '0';
				STORE_decoder  <= '0';
				BRANCH_decoder <= '1';
			
			else 
				
				opcode_var := UNDEFINED_5;
			
			end if;
			
		end if;
--		
		opcode <= opcode_var;
			
		
	end process;

end decoder_arch;
