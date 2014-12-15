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
-- Generated on "07/28/2014 21:26:49"
                                                            
-- Vhdl Test Bench template for design  :  instruction_decoder
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.STD_LOGIC_1164.all;                                

ENTITY instruction_decoder_vhd_tst IS
END instruction_decoder_vhd_tst;
ARCHITECTURE instruction_decoder_arch OF instruction_decoder_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL cond : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL immidiate : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL instruction_type : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL is_signed : STD_LOGIC;
SIGNAL link_flag : STD_LOGIC;
SIGNAL load_store : STD_LOGIC;
SIGNAL opcode : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL Rd : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL Rm : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL Rn : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL Rs : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL shift_operation : STD_LOGIC;
SIGNAL shift_type : STD_LOGIC_VECTOR(1 DOWNTO 0);
COMPONENT instruction_decoder
	PORT (
	cond : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	immidiate : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	instruction_type : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
	is_signed : OUT STD_LOGIC;
	link_flag : OUT STD_LOGIC;
	load_store : OUT STD_LOGIC;
	opcode : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	Rd : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	Rm : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	Rn : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	Rs : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	shift_operation : OUT STD_LOGIC;
	shift_type : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : instruction_decoder
	PORT MAP (
-- list connections between master ports and signals
	cond => cond,
	immidiate => immidiate,
	instruction => instruction,
	instruction_type => instruction_type,
	is_signed => is_signed,
	link_flag => link_flag,
	load_store => load_store,
	opcode => opcode,
	Rd => Rd,
	Rm => Rm,
	Rn => Rn,
	Rs => Rs,
	shift_operation => shift_operation,
	shift_type => shift_type
	);
	
instr : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
      instruction <= "00001000110011101000111001100000";
		wait for 20 ns;
		
		instruction <= "00111111010001111001010101011001";
		wait for 20 ns;
		
		instruction <= "01100001100000110010010100111011";
		wait for 20 ns;
		
END PROCESS instr;                                           
                                          
END instruction_decoder_arch;
