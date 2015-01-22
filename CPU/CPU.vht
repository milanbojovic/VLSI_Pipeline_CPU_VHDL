-- CPU TEST --
LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;          
USE WORK.CPU_PKG.all;
USE WORK.CPU_lib.all;                        

ENTITY CPU_vhd_tst IS
END CPU_vhd_tst;
ARCHITECTURE CPU_arch OF CPU_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC		:= '0';
SIGNAL load : STD_LOGIC		:= '0';
SIGNAL reset : STD_LOGIC	:= '0';
SIGNAL stall : STD_LOGIC	:= '0';
COMPONENT CPU
	PORT (
	clk : IN STD_LOGIC;
	load : IN STD_LOGIC;
	reset : IN STD_LOGIC;
	stall : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : CPU
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	load => load,
	reset => reset,
	stall => stall
	);
	
	
CLOCK : 
PROCESS
variable clk_next : std_logic := '1';
BEGIN
  loop
    clk <= clk_next;
    clk_next := not clk_next;
    wait for 5 ns;
  end loop;
END PROCESS;



process_load : 
PROCESS(clk)
variable load_next : std_logic := '0';
variable step : INTEGER := 0;
BEGIN
	if rising_edge(clk) then 
		if step = 2 then 
			load <= '1';
		else
			load <= '0';
		end if;
		step := (step + 1) mod PHASE_DURATION;	
	end if;
END PROCESS;
	
always : PROCESS
BEGIN
  report "Simulation started !!!";
  
  
  wait for 100 ns;
                                             
END PROCESS always;

END CPU_arch;
