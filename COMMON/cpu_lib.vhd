library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

package cpu_lib is

--	constant WORD_WIDTH	: NATURAL 	:= 32;
--	constant REG_WIDTH	: POSITIVE 	:= 32;
--	constant PC_ADDR	: NATURAL 	:= 15;
--	constant LINK_ADDR	: NATURAL 	:= 14;
--	constant PHASE_DURATION : NATURAL := 8;

--	subtype INSTRUCTION_TYPE_TYPE 	is STD_LOGIC_VECTOR(2 downto 0);
--	subtype COND_TYPE 				is STD_LOGIC_VECTOR(1 downto 0);
--	subtype OPCODE_TYPE 			is STD_LOGIC_VECTOR(3 downto 0);
--	subtype SHIFT_TYPE_TYPE 		is STD_LOGIC_VECTOR(1 downto 0);
--	subtype REG_ADDR_TYPE 			is STD_LOGIC_VECTOR(3 downto 0);
--	subtype IMMIDIATE_TYPE			is STD_LOGIC_VECTOR(15 downto 0);
--	subtype BRANCH_OFFSET_TYPE		is STD_LOGIC_VECTOR((REG_WIDTH - 1) downto 0);
--	subtype REG_TYPE 				is STD_LOGIC_VECTOR((REG_WIDTH - 1) downto 0);
--	subtype WORD_TYPE 				is STD_LOGIC_VECTOR((WORD_WIDTH - 1) downto 0);
--	subtype ADDR_TYPE				is WORD_TYPE;
	 

--	constant INSTRUCTION_TYPE_DP_R   : INSTRUCTION_TYPE_TYPE := "000"; -- Data Processing - Register Value
--	constant INSTRUCTION_TYPE_DP_I   : INSTRUCTION_TYPE_TYPE := "001"; -- Data Processing - Immediate Value
--	constant INSTRUCTION_TYPE_L_S    : INSTRUCTION_TYPE_TYPE := "010"; -- Load/Stor
--	constant INSTRUCTION_TYPE_RMW    : INSTRUCTION_TYPE_TYPE := "011"; -- Read Modify Write
--	constant INSTRUCTION_TYPE_B_BL   : INSTRUCTION_TYPE_TYPE := "100"; -- Jump instructions
--	constant INSTRUCTION_TYPE_S      : INSTRUCTION_TYPE_TYPE := "101"; -- Stop instruction
--	constant INSTRUCTION_TYPE_NOOP 	 : INSTRUCTION_TYPE_TYPE := "111"; -- No operation

--	constant COND_EQ	: COND_TYPE := "00"; -- Equal
--	constant COND_GT	: COND_TYPE := "01"; -- Signed greater
--	constant COND_HI	: COND_TYPE := "10"; -- Unsigned higher
--	constant COND_AL	: COND_TYPE := "11"; -- Unconditional
	
--	constant OPCODE_AND		: OPCODE_TYPE := "0000"; -- Logical AND
--	constant OPCODE_SUB		: OPCODE_TYPE := "0010"; -- Substract
--	constant OPCODE_ADD		: OPCODE_TYPE := "0100"; -- Addition 
--	constant OPCODE_ADC		: OPCODE_TYPE := "0101"; -- Addition with carry bit
--	constant OPCODE_SBC		: OPCODE_TYPE := "0110"; -- Substract with carry bit
--	constant OPCODE_SWAP	: OPCODE_TYPE := "1000"; -- Swap of register values
--	constant OPCODE_CMP		: OPCODE_TYPE := "1010"; -- Comparison
--	constant OPCODE_MOV		: OPCODE_TYPE := "1101"; -- Move of the second operand
--	constant OPCODE_NOT		: OPCODE_TYPE := "1111"; -- Logical NOT
--	constant OPCODE_BRANCH	: OPCODE_TYPE := "1110"; -- Calculate brunch address - internal use onlu
	
	
--	constant SHIFT_LL    : SHIFT_TYPE_TYPE := "00"; -- Logical shift/rotate left
--	constant SHIFT_LSR   : SHIFT_TYPE_TYPE := "01"; -- Logical shift/rotate right
--	constant SHIFT_ASR   : SHIFT_TYPE_TYPE := "10"; -- Arithmetic shift/rotate right
--	constant SHIFT_NONE  : SHIFT_TYPE_TYPE := "11"; -- No shift
	
--	constant F_SHIFT  : STD_LOGIC := '0'; -- Shift operation
--	constant F_ROTATE : STD_LOGIC := '1'; -- Rotate operation
	
--	constant L_MEMORY_STORE : STD_LOGIC := '0'; -- Store operation
--	constant L_MEMORY_LOAD  : STD_LOGIC := '1'; -- Load operation
	
--	constant L_BRANCH          : STD_LOGIC := '0'; -- Simple Branch
--	constant L_BRANCH_AND_LINK : STD_LOGIC := '1'; -- Branch and link
	
--	constant S_SIGNED    : STD_LOGIC := '1'; -- Signed operation
--	constant S_UNSIGNED  : STD_LOGIC := '0'; -- Unsigned operation

	
	-- Constants used when value is not important
--	constant UNDEFINED_1 : 	STD_LOGIC 	:= '-';
--	constant UNDEFINED_2 : 	STD_LOGIC_VECTOR (1 downto 0) 	:= (others => '-');
--	constant UNDEFINED_3 : 	STD_LOGIC_VECTOR (2 downto 0) 	:= (others => '-');
--	constant UNDEFINED_4 : 	STD_LOGIC_VECTOR (3 downto 0) 	:= (others => '-');
--	constant UNDEFINED_8 : 	STD_LOGIC_VECTOR (7 downto 0) 	:= (others => '-');
--	constant UNDEFINED_16 : STD_LOGIC_VECTOR (15 downto 0) 	:= (others => '-');
--	constant UNDEFINED_32 : STD_LOGIC_VECTOR (31 downto 0) 	:= (others => '-');

--	constant MAX_16 : STD_LOGIC_VECTOR(15 downto 0)		:= (others => '1');
--	constant MAX_6 : STD_LOGIC_VECTOR(5 downto 0)		:= (others => '1');

--	constant ZERO_16 : STD_LOGIC_VECTOR(15 downto 0)	:= (others => '0');
--	constant ZERO_6 : STD_LOGIC_VECTOR(5 downto 0)		:= (others => '0');
--	constant ZERO_32 : STD_LOGIC_VECTOR(31 downto 0)	:= (others => '0');

--	constant HIGH_Z_32 : STD_LOGIC_VECTOR(31 downto 0)	:= (others => 'Z');


--	constant input_file			: STRING := "test_2_in.txt";
	--constant input_file			: STRING := "D:\altera\VLSI_VHDL\simulation\modelsim\test_1_in.txt";
--	constant output_file			: STRING := "test_2_out.txt";
	--constant output_file			: STRING := "D:\altera\VLSI_VHDL\simulation\modelsim\test_1_out.txt";
end cpu_lib;

--package body cpu_lib is
--	function LOG2 (count : POSITIVE) return POSITIVE is 
--		variable cnt,tmp : POSITIVE;
--	begin 
--		cnt := count;
--		while cnt > 1 loop 
--			tmp := tmp + 1; 
--			cnt := cnt / 2; 
--		end loop; 
--		return tmp; 
--	end;
--end cpu_lib;
 