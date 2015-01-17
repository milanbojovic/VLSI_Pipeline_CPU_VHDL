-- DATA_CACHE TEST--
LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;   
USE WORK.CPU_PKG.all;
USE WORK.CPU_lib.all;
                          

ENTITY DATA_CACHE_vhd_tst IS
END DATA_CACHE_vhd_tst;
ARCHITECTURE DATA_CACHE_arch OF DATA_CACHE_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL address 			: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL dataIn 				: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL dataOut 			: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL record_in_crls	: CRLS_RCD;
SIGNAL control 			: DATA_CONTROL_TYPE;


COMPONENT DATA_CACHE
	PORT (
	address		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	control		: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	dataIn		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	dataOut		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL record_in_crls		: in 	CRLS_RCD
	);
END COMPONENT;
BEGIN
	d1 : DATA_CACHE
	PORT MAP (
-- list connections between master ports and signals
	address => address,
	control => control,
	dataIn => dataIn,
	dataOut => dataOut,
	record_in_crls 	=> record_in_crls
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
	wait for 10 ns;		
	-- CITANJE 1
	address <= "00000000000000000000000010100001";
	control <= "0010";	
	wait for 10 ns;		
		
	-- UPIS 1
	address <= "00000000000000000000000010100001";
	dataIn  <= "00111111111111111111110000000111";
	control <= "0001";
	
	wait for 10 ns;

	-- CITANJE 2
	address <= "00000000000000000000000010100001";
	control <= "0010";	
	wait for 10 ns;
	
	
	--UPIS 2
	address <= "00000000000000000001101111001110";
	dataIn  <= "00111111111111111111110000000111";
	control <= "0001";	
	
	wait for 10 ns;	
	
	-- CITANJE 3
	address <= "00000000000000000000000010100001";
	control <= "0010";	
	wait for 10 ns;
	
	-- CITANJE 4
	address <= "00000000000000000001101111001110";
	control <= "0010";	
	wait for 10 ns;	

	-- CITANJE 5
	address <= "00000000000000000000000000001011";
	control <= "0010";	
	wait for 10 ns;	
	
END PROCESS always;                                          
END DATA_CACHE_arch;
