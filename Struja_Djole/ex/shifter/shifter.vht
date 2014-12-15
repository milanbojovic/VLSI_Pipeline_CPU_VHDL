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
-- Generated on "07/29/2014 22:29:36"
                                                            
-- Vhdl Test Bench template for design  :  shifter
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.STD_LOGIC_1164.all;                                

ENTITY shifter_vhd_tst IS
END shifter_vhd_tst;
ARCHITECTURE shifter_arch OF shifter_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL result : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Rn : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Rs : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL shift_operation : STD_LOGIC;
SIGNAL shift_type : STD_LOGIC_VECTOR(1 DOWNTO 0);
COMPONENT shifter
	PORT (
	result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	Rn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	Rs : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	shift_operation : IN STD_LOGIC;
	shift_type : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : shifter
	PORT MAP (
-- list connections between master ports and signals
	result => result,
	Rn => Rn,
	Rs => Rs,
	shift_operation => shift_operation,
	shift_type => shift_type
	);
	
shift_o: PROCESS                                                                                   
BEGIN
	shift_operation <= '0';
	wait for 40 ns;
	
	shift_operation <= '1';
	wait for 40 ns;
END PROCESS shift_o;                                           

shift_t: PROCESS                                              
BEGIN                                                         
   shift_type <= "00";
	wait for 10 ns;
	
	shift_type <= "01";
	wait for 10 ns;
	
	shift_type <= "10";
	wait for 10 ns;
	
	shift_type <= "11";
	wait for 10 ns;                                           
END PROCESS shift_t;

Rn_Rs: PROCESS
BEGIN
	Rn <= "11111001001001001110101101000010";
	Rs <= "00000000000000000000000000000100";
	wait for 40 ns;
	
	Rn <= "11111001001001001110101101000010";
	Rs <= "00000000000000000000000000000011";
	wait for 40 ns;
END PROCESS Rn_Rs;
                                          
END shifter_arch;
