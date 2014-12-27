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
-- Generated on "08/19/2014 22:16:40"
                                                            
-- Vhdl Test Bench template for design  :  CACHE
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee; 
LIBRARY WORK;

USE ieee.std_logic_1164.all; 
USE work.cpu_lib.all;                               

ENTITY CACHE_vhd_tst IS
END CACHE_vhd_tst;
ARCHITECTURE CACHE_arch OF CACHE_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL addr : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL addr_ram : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL clk : STD_LOGIC;
SIGNAL data : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL data_ram : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL miss : STD_LOGIC;
SIGNAL we : STD_LOGIC;
SIGNAL we_ram : STD_LOGIC;

COMPONENT CACHE
	PORT (

	clk : IN STD_LOGIC;

	addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	data : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	we : IN STD_LOGIC;

	miss : OUT STD_LOGIC;

	data_ram : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	addr_ram : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	we_ram : OUT STD_LOGIC
	);
END COMPONENT;

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
	i1 : CACHE
	PORT MAP (
-- list connections between master ports and signals
	addr => addr,
	addr_ram => addr_ram,
	clk => clk,
	data => data,
	data_ram => data_ram,
	miss => miss,
	we => we,
	we_ram => we_ram
	);

	i2 : RAM
	PORT MAP (
	-- list connections between master ports and signals
		addr => addr_ram,
		clk => clk,
		data => data_ram,
		we => we_ram 
	);
                  
	init : PROCESS                                               
	-- variable declarations                                     
	BEGIN                                                        
	        -- code that executes only once                      
	WAIT;                                                       
	END PROCESS init;                                           
	always : PROCESS                                              
	                                   
	BEGIN                                                         
	     addr <= (others => '0');
	     data <= HIGH_Z_32;
	     we <= '0';

	WAIT;                                                        
	END PROCESS always;  

	clk_p : PROCESS
	BEGIN
		clk <= '0';
		wait for 1 ns;
		
		clk <= '1';
		wait for 1 ns;
	END PROCESS clk_p;

END ARCHITECTURE;

