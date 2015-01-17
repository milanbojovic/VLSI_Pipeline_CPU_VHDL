library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_TEXTIO.all;
use IEEE.numeric_std.all;
use STD.TEXTIO.all;


package cpu_lib is

	constant WORD_WIDTH				: NATURAL 	:= 32;
	constant REG_WIDTH				: POSITIVE 	:= 32;
	constant ADDR_WIDTH 				: NATURAL 	:= 32;
	constant SP_ADDR					: NATURAL 	:= 30;
	constant LINK_ADDR				: NATURAL 	:= 31;
	constant PHASE_DURATION 		: NATURAL 	:= 3;        -- SET PHASE DURATION !!!!!!!!
	constant INSTR_CACHE_SIZE		: NATURAL 	:= 2**8-1;	 --  should be 2**10-1 or more
	constant DATA_CACHE_SIZE		: NATURAL 	:= 2**13-1;	 --  should be 2**10-1 or more

	subtype 	OPCODE_TYPE 			is STD_LOGIC_VECTOR(4 downto 0);
--	subtype 	REG_ADDR_TYPE 			is STD_LOGIC_VECTOR(3 downto 0);
	subtype 	IMMIDIATE_TYPE			is STD_LOGIC_VECTOR(16 downto 0);	--17 bits
	subtype 	BRANCH_OFFSET_TYPE	is STD_LOGIC_VECTOR((REG_WIDTH - 6) downto 0);
	subtype 	REG_TYPE 				is STD_LOGIC_VECTOR((REG_WIDTH - 1) downto 0);
	subtype 	WORD_TYPE 				is STD_LOGIC_VECTOR((WORD_WIDTH - 1) downto 0);
	subtype 	ADDR_TYPE				is WORD_TYPE;
	subtype 	INSTR_TYPE				is WORD_TYPE;
	subtype	SIGNAL_BIT_TYPE		is STD_LOGIC;
	subtype	INSTR_CONTROL_TYPE	is STD_LOGIC_VECTOR(2 downto 0);
	subtype	DATA_CONTROL_TYPE		is STD_LOGIC_VECTOR(3 downto 0);

	type	   INSTR_CACHE_TYPE		is array (natural range 0 to INSTR_CACHE_SIZE) OF INSTR_TYPE;
	type	   DATA_CACHE_TYPE	 	is array (natural range 0 to DATA_CACHE_SIZE)  OF INSTR_TYPE; 

	constant OPCODE_AND			: OPCODE_TYPE := "00000"; -- Logical AND
	constant OPCODE_SUB			: OPCODE_TYPE := "00001"; -- Substract
	constant OPCODE_ADD			: OPCODE_TYPE := "00010"; -- Addition
	constant OPCODE_ADC			: OPCODE_TYPE := "00011"; -- Addition with carry bit
	constant OPCODE_SBC			: OPCODE_TYPE := "00100"; -- Substract with carry bit
	constant OPCODE_CMP			: OPCODE_TYPE := "00101"; -- Comparison
	constant OPCODE_SSUB		: OPCODE_TYPE := "00110"; -- Substract (SIGNED)
	constant OPCODE_SADD		: OPCODE_TYPE := "00111"; -- Addition (SIGNED)
	constant OPCODE_SADC		: OPCODE_TYPE := "01000"; -- Addition with carry bit (SIGNED)
	constant OPCODE_SSBC		: OPCODE_TYPE := "01001"; -- Substract with carry bit (SIGNED)
	constant OPCODE_MOV			: OPCODE_TYPE := "01010"; -- Move of the second operand
	constant OPCODE_NOT			: OPCODE_TYPE := "01011"; -- Logical NOT
	constant OPCODE_SL    	: OPCODE_TYPE := "01100"; -- Logical shift left
	constant OPCODE_SR    	: OPCODE_TYPE := "01101"; -- Logical shift right
	constant OPCODE_ASR   	: OPCODE_TYPE := "01110"; -- Arithmetic shift right
	constant OPCODE_UMOV		: OPCODE_TYPE := "01111"; -- Move of the second operand unsigned
	constant OPCODE_SMOV		: OPCODE_TYPE := "10000"; -- Move of the second operand signed

	constant OPCODE_LOAD  	: OPCODE_TYPE := "10100"; -- Store operation
	constant OPCODE_STORE 	: OPCODE_TYPE := "10101"; -- Load operation

	constant OPCODE_BEQ		  : OPCODE_TYPE := "11000"; -- Branch if Equal
	constant OPCODE_BGT		  : OPCODE_TYPE := "11001"; -- Branch if Greater (SIGNED)
	constant OPCODE_BHI		  : OPCODE_TYPE := "11010"; -- Branch if Greater (UNSIGNED)
	constant OPCODE_BAL  	  : OPCODE_TYPE := "11011"; -- Branch and Link
	constant OPCODE_BLAL 	  : OPCODE_TYPE := "11100"; -- Branch Long and Link


	constant OPCODE_STOP		: OPCODE_TYPE := "11111"; -- Move of the second operand signed

-- Constants used when value is not important
	constant UNDEFINED_1 	: 	STD_LOGIC 	:= '-';
	constant UNDEFINED_2 	: 	STD_LOGIC_VECTOR (1 downto 0) 	:= (others => '-');
	constant UNDEFINED_3 	: 	STD_LOGIC_VECTOR (2 downto 0) 	:= (others => '-');
	constant UNDEFINED_4 	: 	STD_LOGIC_VECTOR (3 downto 0) 	:= (others => '-');
	constant UNDEFINED_8 	: 	STD_LOGIC_VECTOR (7 downto 0) 	:= (others => '-');
	constant UNDEFINED_16	: STD_LOGIC_VECTOR (15 downto 0) 	:= (others => '-');
	constant UNDEFINED_32 	: STD_LOGIC_VECTOR (31 downto 0) 	:= (others => '-');

--	constant F_SHIFT  : STD_LOGIC := '0'; -- Shift operation
--	constant F_ROTATE : STD_LOGIC := '1'; -- Rotate operation


--	constant L_BRANCH          : STD_LOGIC := '0'; -- Simple Branch
--	constant L_BRANCH_AND_LINK : STD_LOGIC := '1'; -- Branch and link

--	constant S_SIGNED    : STD_LOGIC := '1'; -- Signed operation
--	constant S_UNSIGNED  : STD_LOGIC := '0'; -- Unsigned operation

	constant MAX_32 : STD_LOGIC_VECTOR(31 downto 0)		:= (others => '1');
	constant MAX_16 : STD_LOGIC_VECTOR(15 downto 0)		:= (others => '1');
	constant MAX_6  : STD_LOGIC_VECTOR(5 downto 0)		:= (others => '1');

	constant ZERO_16 : STD_LOGIC_VECTOR(15 downto 0)	:= (others => '0');
	constant ZERO_6 : STD_LOGIC_VECTOR(5 downto 0)		:= (others => '0');
	constant ZERO_32 : STD_LOGIC_VECTOR(31 downto 0)	:= (others => '0');

--	constant HIGH_Z_32 : STD_LOGIC_VECTOR(31 downto 0)	:= (others => 'Z');


	--constant input_file			: STRING := "test_2_in.txt";
	constant instr_input_file_path		: STRING := "/home/milanbojovic/vhdl_workspace/vlsi_projkat/IO/javni_test_inst_in.txt";
	constant data_input_file_path			: STRING := "/home/milanbojovic/vhdl_workspace/vlsi_projkat/IO/javni_test_data_in.txt";
	constant expected_output_file			: STRING := "/home/milanbojovic/vhdl_workspace/vlsi_projkat/IO/javni_test_out.txt";
	constant actual_output_file			: STRING := "/home/milanbojovic/vhdl_workspace/vlsi_projkat/IO/generated_output.txt";

	function read_pc_from_file return REG_TYPE;
	function read_pc_plus_one_from_file return REG_TYPE;
	function DO_SHIFT_LL  (operand: REG_TYPE; count : REG_TYPE) return REG_TYPE;
	function DO_SHIFT_LSR (operand: REG_TYPE; count : REG_TYPE) return REG_TYPE;
	function DO_SHIFT_ASR (operand: REG_TYPE; count : REG_TYPE) return REG_TYPE;
end cpu_lib;

package body cpu_lib is

	function read_pc_plus_one_from_file return REG_TYPE is
		file 		input_file		: text;
		variable input_line		: line;
		variable pc_value			: WORD_TYPE;  -- pc from file
	begin

		file_open(input_file, instr_input_file_path, read_mode);

		READLINE(input_file, input_line);  	--Read the line from the file
		HREAD(input_line, pc_value);		--Read first word (pc adress)

		file_close(input_file);

		return std_logic_vector(UNSIGNED(pc_value) + 1);
	end;

	
	function read_pc_from_file return REG_TYPE is
		file 		input_file		: text;
		variable input_line1		: line;
		variable pc_value1			: WORD_TYPE;  -- pc from file
	begin

		file_open(input_file, instr_input_file_path, read_mode);

		READLINE(input_file, input_line1);  	--Read the line from the file
		HREAD(input_line1, pc_value1);			--Read first word (pc adress)

		file_close(input_file);
		return pc_value1;
	end;

	-- logical shift left
	function DO_SHIFT_LL (operand: REG_TYPE; count : REG_TYPE) return REG_TYPE is
    begin
		return REG_TYPE(SHIFT_LEFT(UNSIGNED(operand), TO_INTEGER(UNSIGNED(count))));
    end DO_SHIFT_LL;

    -- shift logical right
   function DO_SHIFT_LSR (operand: REG_TYPE; count : REG_TYPE) return REG_TYPE is
   begin
		return REG_TYPE(SHIFT_RIGHT(UNSIGNED(operand), TO_INTEGER(UNSIGNED(count))));
   end DO_SHIFT_LSR;

   -- shift arithmetic right
   function DO_SHIFT_ASR (operand: REG_TYPE; count : REG_TYPE) return REG_TYPE is
   begin
		return REG_TYPE(SHIFT_RIGHT(SIGNED(operand), TO_INTEGER(UNSIGNED(count))));
   end DO_SHIFT_ASR;

end cpu_lib;
