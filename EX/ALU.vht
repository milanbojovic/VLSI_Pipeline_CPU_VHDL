-- ***************************************************************************
-- Generated on "01/10/2015 22:38:40"

-- Vhdl Test Bench template for design  :  ALU
--
-- Simulation tool : ModelSim-Altera (VHDL)
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE WORK.CPU_LIB.ALL;
ENTITY ALU_vhd_tst IS
END ALU_vhd_tst;
ARCHITECTURE ALU_arch OF ALU_vhd_tst IS
-- constants
-- signals
SIGNAL a : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL carry_in : STD_LOGIC;
SIGNAL carry_out : STD_LOGIC;
SIGNAL clk : STD_LOGIC;
SIGNAL is_signed : STD_LOGIC;
SIGNAL negative_in : STD_LOGIC;
SIGNAL negative_out : STD_LOGIC;
SIGNAL opcode : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL overflow_in : STD_LOGIC;
SIGNAL overflow_out : STD_LOGIC;
SIGNAL result : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL zero_in : STD_LOGIC;
SIGNAL zero_out : STD_LOGIC;
COMPONENT ALU
	PORT (
	a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	carry_in : IN STD_LOGIC;
	carry_out : OUT STD_LOGIC;
	negative_in : IN STD_LOGIC;
	negative_out : OUT STD_LOGIC;
	opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
	overflow_in : IN STD_LOGIC;
	overflow_out : OUT STD_LOGIC;
	result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	zero_in : IN STD_LOGIC;
	zero_out : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	alu1 : ALU
	PORT MAP (
-- list connections between master ports and signals
	a => a,
	b => b,
	carry_in => carry_in,
	carry_out => carry_out,
	negative_in => negative_in,
	negative_out => negative_out,
	opcode => opcode,
	overflow_in => overflow_in,
	overflow_out => overflow_out,
	result => result,
	zero_in => zero_in,
	zero_out => zero_out
	);



PROCESS
BEGIN
	report "Test report: First output 1 2 3 bla bla bla";

	carry_in <= '1';
	overflow_in <= '0';
	negative_in <= '0';
	zero_in 		<= '0';


	a <= "00000000000000000000000000001000";
	b <= "00000000000000000000000000000011";	--NOT
	opcode <= OPCODE_NOT;

	wait for 5 ns;

	a <= "00000000000000000000000000001000";
	b <= "00000000000000000000000000000011";	--mov unsigned num
	opcode <= OPCODE_MOV;

	wait for 5 ns;


	a <= "00000000000000000000000000001000";
	b <= "11111111111111111111111111100000";	--mov signed num
	opcode <= OPCODE_MOV;

	wait for 5 ns;


	a <= "00000000000000000000000000001000";	--mov unsigned sa unsigned brojem
	b <= "00000000000000000000000000000011";
	opcode <= OPCODE_UMOV;

	wait for 5 ns;


	a <= "00000000000000000000000000001000"; --mov unsigned sa signed brojem
	b <= "11111111111110000000000000000001";
	opcode <= OPCODE_UMOV;

	wait for 5 ns;


	a <= "00000000000000000000000000001000"; --MOV SIGNED SA SIGNED BROJEM
	b <= "11111111111111111111111111111111";
	opcode <= OPCODE_SMOV;

	wait for 5 ns;


	a <= "00000000000000000000000000001000"; --MOV SIGNED SA UNSIGNED BROJEM
	b <= "00000000000000000000000011111111";
	opcode <= OPCODE_SMOV;

	wait for 5 ns;
END PROCESS;
END ALU_arch;
