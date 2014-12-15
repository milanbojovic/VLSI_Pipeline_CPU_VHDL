-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "08/03/2014 21:53:38"
                                                            
-- Vhdl Test Bench template for design  :  ADDER
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY ADDER_vhd_tst IS
END ADDER_vhd_tst;
ARCHITECTURE ADDER_arch OF ADDER_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL input : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL output : STD_LOGIC_VECTOR(31 DOWNTO 0);
COMPONENT ADDER
	PORT (
	input : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : ADDER
	PORT MAP (
-- list connections between master ports and signals
	input => input,
	output => output
	);
init : PROCESS                                               
BEGIN                                                        
	input <= "00011111111111111111111111111111";
	wait for 5 ns; 
	assert output = "00100000000000000000000000000000"
	report "Wrong First Result"
	severity ERROR;
	wait for 10 ns;
	
	input <= "00011000000000000000000000000001";
	wait for 5 ns; 
	assert output = "00011000000000000000000000000010"
	report "Wrong Second Result"
	severity ERROR;
	wait for 10 ns;                                                       
END PROCESS init;                                                                                   
END ADDER_arch;
