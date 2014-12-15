library ieee;
library work;

use ieee.std_logic_1164.all;
use work.cpu_lib.all;

entity REG_WB is
	port(
		-- Input ports
		load  : STD_LOGIC;
		reset : STD_LOGIC;
		stall : STD_LOGIC;

		instruction_type_in 	: INSTRUCTION_TYPE_TYPE;
		load_store_in			: STD_LOGIC;
		opcode_in				: OPCODE_TYPE;
		link_flag_in			: STD_LOGIC;
		branch_in				: STD_LOGIC;
		rd_1_in					: REG_TYPE;
		rd_2_in					: REG_TYPE;
		rd_1_addr_in			: REG_ADDR_TYPE;
		rd_2_addr_in			: REG_ADDR_TYPE;
		
		-- Output ports
		instruction_type_out 	: out INSTRUCTION_TYPE_TYPE;
		load_store_out			: out STD_LOGIC;
		opcode_out				: out OPCODE_TYPE;
		link_flag_out			: out STD_LOGIC;
		branch_out				: out STD_LOGIC;
		rd_1_out				: out REG_TYPE;
		rd_2_out				: out REG_TYPE;
		rd_1_addr_out			: out REG_ADDR_TYPE;
		rd_2_addr_out			: out REG_ADDR_TYPE
	);
end entity;
architecture BHV of REG_WB is
begin
	process(load) is
	begin
		if(rising_edge(load)) then
			if(reset = '1')then
				instruction_type_out <= INSTRUCTION_TYPE_NOOP;
				load_store_out <= '0';
				link_flag_out <= '0';
				opcode_out <= (others => '0'); 
				rd_1_out <= (others => '0'); 
				rd_2_out <= (others => '0'); 
				rd_1_addr_out <= (others => '0'); 
				rd_2_addr_out <= (others => '0');
				branch_out <= '0';
			elsif (stall = '0') then
				instruction_type_out <= instruction_type_in;
				load_store_out <= load_store_in;
				opcode_out <= opcode_in;
				link_flag_out <= link_flag_in;
				branch_out <= branch_in;
				rd_1_out <= rd_1_in; 
				rd_2_out <= rd_2_in; 
				rd_1_addr_out <= rd_1_addr_in; 
				rd_2_addr_out <= rd_2_addr_in;
			end if;
		end if;
	end process;
end architecture BHV;
