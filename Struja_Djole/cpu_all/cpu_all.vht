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
-- Generated on "08/06/2014 17:05:22"
                                                            
-- Vhdl Test Bench template for design  :  CPU_ALL
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY CPU_ALL_vhd_tst IS
END CPU_ALL_vhd_tst;
ARCHITECTURE CPU_ALL_arch OF CPU_ALL_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL address_bus : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL clk : STD_LOGIC;
SIGNAL data_bus : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL rd_wr : STD_LOGIC;
SIGNAL reset : STD_LOGIC;
COMPONENT CPU_ALL
	PORT (
	address_bus : STD_LOGIC_VECTOR(31 DOWNTO 0);
	clk : IN STD_LOGIC;
	data_bus : STD_LOGIC_VECTOR(31 DOWNTO 0);
	rd_wr : STD_LOGIC;
	reset : IN STD_LOGIC
	);
END COMPONENT;

COMPONENT RAM is
	port 
	(
		clk		: STD_LOGIC;
		addr	: ADDR_TYPE;
		data	: WORD_TYPE;
		we		: STD_LOGIC := '1';

		q		: out WORD_TYPE
	);
end COMPONENT;
BEGIN
	i1 : RAM
	PORT MAP (
-- list connections between master ports and signals
	address_bus => addr,
	clk => clk,
	data_bus => data,
	rd_wr => we,
	reset => reset
	);

	i2 : CPU_ALL
	PORT MAP (
-- list connections between master ports and signals
	address_bus => address_bus,
	clk => clk,
	data_bus => data_bus,
	rd_wr => rd_wr,
	reset => reset
	);
init : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
        -- code that executes only once                      
WAIT;                                                       
END PROCESS init;                                           
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN                                                         
        -- code executes for every event on sensitivity list  
WAIT;                                                        
END PROCESS always;                                          
END CPU_ALL_arch;
