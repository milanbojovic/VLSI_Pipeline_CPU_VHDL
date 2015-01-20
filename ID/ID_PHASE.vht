
LIBRARY ieee;     
LIBRARY WORK;                                          
USE ieee.std_logic_1164.all;  
USE WORK.CPU_LIB.all;
USE WORK.CPU_PKG.all;                              

ENTITY ID_PHASE_vhd_tst IS
END ID_PHASE_vhd_tst;
ARCHITECTURE ID_PHASE_arch OF ID_PHASE_vhd_tst IS
-- constants                                                 
-- signals             

SIGNAL record_in_crls : CRLS_RCD;
SIGNAL if_record_id   : IF_ID_RCD;
SIGNAL wb_record_id   : WB_ID_RCD;
SIGNAL id_record_ex   : ID_EX_RCD;


COMPONENT ID_PHASE
	PORT (
	SIGNAL record_in_crls : in CRLS_RCD;
	SIGNAL if_record_id   : in IF_ID_RCD;
		SIGNAL wb_record_id   : in WB_ID_RCD;
	SIGNAL id_record_ex   : out ID_EX_RCD
	);
END COMPONENT;
BEGIN
	i1 : ID_PHASE
	PORT MAP (
-- list connections between master ports and signals
	id_record_ex 	=> id_record_ex,
	if_record_id 	=> if_record_id,
	record_in_crls => record_in_crls,
	wb_record_id 	=> wb_record_id
	);

CLOCK : 
PROCESS
variable clk_next : std_logic := '1';
BEGIN
  loop
    record_in_crls.clk <= clk_next;
    clk_next := not clk_next;
    wait for 5 ns;
  end loop;
END PROCESS;



process_load : 
PROCESS(record_in_crls.clk)
variable load_next : std_logic := '0';
variable step : INTEGER := 0;
BEGIN
	if rising_edge(record_in_crls.clk) then 
		if step = 0 then 
			record_in_crls.load <= '1';
		else
			record_in_crls.load <= '0';
		end if;
		step := (step + 1) mod PHASE_DURATION;	
	end if;
END PROCESS;

always : PROCESS

BEGIN
  report "Test report: First output 1 2 3 bla bla bla";
  
  --UMOV R5 A
  if_record_id.pc  <= "00000000000000000000000000001010";
  if_record_id.ir1 <= "01111111110010100000000000001010";

  wait for 30 ns;
  --CMP R20, R31, R1 
  if_record_id.ir1 <= "00101101001111100001001011101111";
  
  wait for 30 ns;
  
  	--LOAD R7, R5, R3 
  if_record_id.ir1 <= "10100001110010100011001111100000";
  wait for 30 ns;
  
  	--BGT 256
  if_record_id.ir1 <= "11001000000000000000000100000000";	
  
  --record_in_crls.reset<= '1';
    
  wait for 50 ns;
                                             
END PROCESS always;
	
END ID_PHASE_arch;
