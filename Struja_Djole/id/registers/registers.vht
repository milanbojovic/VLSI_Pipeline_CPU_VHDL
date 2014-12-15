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
-- Generated on "08/03/2014 20:51:40"
                                                            
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
-- Generated on "08/23/2014 23:46:06"
                                                            
-- Vhdl Test Bench template for design  :  REGISTERS
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all;    
use WORK.CPU_LIB.all;                       

ENTITY REGISTERS_vhd_tst IS
END REGISTERS_vhd_tst;
ARCHITECTURE REGISTERS_arch OF REGISTERS_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL in_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL in_1_addr : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL in_2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL in_2_addr : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL pc_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL pc_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL rd : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL rd_addr : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL reset : STD_LOGIC;
SIGNAL rm : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL rm_addr : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL rn : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL rn_addr : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL rs : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL rs_addr : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL we_1 : STD_LOGIC;
SIGNAL we_2 : STD_LOGIC;

COMPONENT REGISTERS
	PORT (
	clk : IN STD_LOGIC;
	in_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	in_1_addr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	in_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	in_2_addr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	rd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	rd_addr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	reset : IN STD_LOGIC;
	rm : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	rm_addr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	rn : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	rn_addr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	rs : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	rs_addr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	we_1 : IN STD_LOGIC;
	we_2 : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : REGISTERS
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	in_1 => in_1,
	in_1_addr => in_1_addr,
	in_2 => in_2,
	in_2_addr => in_2_addr,
	pc_in => pc_in,
	pc_out => pc_out,
	rd => rd,
	rd_addr => rd_addr,
	reset => reset,
	rm => rm,
	rm_addr => rm_addr,
	rn => rn,
	rn_addr => rn_addr,
	rs => rs,
	rs_addr => rs_addr,
	we_1 => we_1,
	we_2 => we_2
	);

init : PROCESS (clk)
	variable count : integer := -2;
	variable i : integer := 0;
	variable extend : std_LOGIC_VECTOR(27 downto 0) := (others => '0');                                             
BEGIN                                                         
	if (falling_edge(clk)) then
		count := count + 2;

		if (count < 15) then
			i := count;
			we_1 <= '1';
			in_1_addr <= REG_ADDR_TYPE(STD_LOGIC_VECTOR(TO_UNSIGNED(i, REG_ADDR_TYPE'length)));
			in_1 <= REG_TYPE(STD_LOGIC_VECTOR(TO_UNSIGNED(i * 2, REG_TYPE'length)));

			i := count + 1;
			we_2 <= '1';
			in_2_addr <= REG_ADDR_TYPE(STD_LOGIC_VECTOR(TO_UNSIGNED(i, REG_ADDR_TYPE'length)));
			in_2 <= REG_TYPE(STD_LOGIC_VECTOR(TO_UNSIGNED(i * 3, REG_TYPE'length)));
		else
			we_1 <= '0';
			we_2 <= '0';
		end if;
	end if;
END PROCESS init;

clk_p : PROCESS
BEGIN
	clk <= '0';
	wait for 1 ns;
	
	clk <= '1';
	wait for 1 ns;
END PROCESS clk_p;                                          
END REGISTERS_arch;
