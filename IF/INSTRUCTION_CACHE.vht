-- Generated on "01/03/2015 14:51:25"
                                                            
-- Vhdl Test Bench template for design  :  INSTRUCTION_CACHE
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                        
USE ieee.std_logic_1164.all;                                
use WORK.CPU_PKG.all;

ENTITY INSTRUCTION_CACHE_vhd_tst IS
END INSTRUCTION_CACHE_vhd_tst;
ARCHITECTURE INSTRUCTION_CACHE_arch OF INSTRUCTION_CACHE_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL address1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL address2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL control : INSTR_CONTROL_TYPE;
SIGNAL data1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL data2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL record_in_crls : CRLS_RCD;


COMPONENT INSTRUCTION_CACHE
	PORT (
	address1 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	address2 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	control  		: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	data1 			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	data2 			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	record_in_crls : IN CRLS_RCD
	);
END COMPONENT;
BEGIN
	i1 : INSTRUCTION_CACHE
	PORT MAP (
-- list connections between master ports and signals
	address1 => address1,
	address2 => address2,
	control => control,
	data1 => data1,
	data2 => data2,
	record_in_crls => record_in_crls
	);

PROCESS
variable clk_next : std_logic := '1';
BEGIN
	loop
		record_in_crls.clk <= clk_next;
		clk_next := not clk_next;
		wait for 5 ns;
	end loop;
END PROCESS;

always : PROCESS

BEGIN
	report "Test report: First output 1 2 3 bla bla bla";
	
	wait for 10 ns; 
	
	record_in_crls.reset<= '1';
	
	wait for 20 ns; 
	
	record_in_crls.reset<= '0';
		
	wait for 20 ns;
	
	address1 <= "00000000000000000000000000000001";
	control  <= "001";
	
	wait for 20 ns;
	
	address2 <= "00000000000000000000000000000011";
	control  <= "010";
	
	wait for 20 ns;
	
	address1 <= "00000000000000000000000000000100";
	address2 <= "00000000000000000000000000000100";
	control  <= "011";
	
	wait for 20 ns;
	
	--assert output = "00100000000000000000000000000000"
	--report "Wrong First Result"
                                             
END PROCESS always;
	
END INSTRUCTION_CACHE_arch;
