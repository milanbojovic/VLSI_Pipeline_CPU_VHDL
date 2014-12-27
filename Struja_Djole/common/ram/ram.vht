-- Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus II License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "08/08/2014 22:10:03"
                                                            
-- Vhdl Test Bench template for design  :  RAM
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 


library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use WORK.CPU_LIB.all;

ENTITY RAM_vhd_tst IS
END RAM_vhd_tst;

ARCHITECTURE RAM_arch OF RAM_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL addr : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
SIGNAL clk : STD_LOGIC;
SIGNAL data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
SIGNAL we : STD_LOGIC := '1';

COMPONENT RAM
	port 
	(
		clk		: in std_logic;
		addr	: in ADDR_TYPE;
		data	: inout REG_TYPE := HIGH_Z_32;
		we		: in STD_LOGIC
	);
END COMPONENT;

BEGIN
	i1 : RAM
	PORT MAP (
	-- list connections between master ports and signals
		addr => addr,
		clk => clk,
		data => data,
		we => we 
	);
                                        
always : PROCESS (clk)
	variable count : integer := 1;
	variable time : integer := 1;                                        
BEGIN                                                         
	if (falling_edge(clk)) then

		addr <= ADDR_TYPE(TO_UNSIGNED(count, ADDR_TYPE'length));
	
		if (time < 4) then
			we <= '1';
			data <= REG_TYPE(TO_UNSIGNED(count + 100, REG_TYPE'length));
		else 
			we <= '0';
			data <= HIGH_Z_32;
		end if;

		time := time + 1;
		count := time mod 16;
	end if;
END PROCESS always;


clk_p : PROCESS
BEGIN
	clk <= '0';
	wait for 1 ns;
	
	clk <= '1';
	wait for 1 ns;
END PROCESS clk_p;

END ARCHITECTURE;
