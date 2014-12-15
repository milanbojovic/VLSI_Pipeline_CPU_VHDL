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
-- Generated on "08/07/2014 22:57:19"
                                                            
-- Vhdl Test Bench template for design  :  CPU_MEM
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY CPU_MEM_vhd_tst IS
END CPU_MEM_vhd_tst;

ARCHITECTURE CPU_MEM_arch OF CPU_MEM_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL reset : STD_LOGIC;
COMPONENT CPU_MEM
	PORT (
	clk : IN STD_LOGIC;
	reset : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : CPU_MEM
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	reset => reset
	);
init : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
        -- code that executes only once 

      reset <= '1';

      wait for 4 ns;

      reset <= '0';                 
WAIT;                                                       
END PROCESS init;                                              

clk_p : PROCESS
BEGIN
	clk <= '0';
	wait for 1 ns;
	
	clk <= '1';
	wait for 1 ns;
END PROCESS clk_p; 
                                       
END CPU_MEM_arch;
