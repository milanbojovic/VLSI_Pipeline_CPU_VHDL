library ieee;
library work;

use ieee.std_logic_1164.all;
use work.cpu_lib.all;

entity REG_EX is
	port(
	
		-- Input ports
		load : STD_LOGIC;
		reset : STD_LOGIC;
		stall : STD_LOGIC;
		
        pc_in : REG_TYPE;

		instruction_type_in : INSTRUCTION_TYPE_TYPE;
		opcode_in			: OPCODE_TYPE;
		cond_in				: COND_TYPE;
		branch_offset_in	: BRANCH_OFFSET_TYPE;
		is_signed_in		: STD_LOGIC;
		link_flag_in		: STD_LOGIC;
		load_store_in		: STD_LOGIC;
		shift_operation_in	: STD_LOGIC;
		shift_type_in		: SHIFT_TYPE_TYPE;
		immidiate_in		: REG_TYPE;

		rd_addr_in 			: REG_ADDR_TYPE;
		rn_addr_in			: REG_ADDR_TYPE;
		rm_addr_in 			: REG_ADDR_TYPE;
		rs_addr_in			: REG_ADDR_TYPE;
		
		rn_in		: REG_TYPE;
		rs_in		: REG_TYPE;
		rm_in		: REG_TYPE;
		rd_in		: REG_TYPE;
		
		-- Output ports
        pc_out		: out REG_TYPE;

		instruction_type_out 	: out INSTRUCTION_TYPE_TYPE;
		opcode_out			 	: out OPCODE_TYPE;
		cond_out				: out COND_TYPE;
		branch_offset_out		: out BRANCH_OFFSET_TYPE;
		is_signed_out			: out STD_LOGIC;
		link_flag_out			: out STD_LOGIC;
		load_store_out			: out STD_LOGIC;
		shift_operation_out		: out STD_LOGIC;
		shift_type_out			: out SHIFT_TYPE_TYPE;
		immidiate_out			: out REG_TYPE;

		rd_addr_out 			: out REG_ADDR_TYPE;
		rn_addr_out				: out REG_ADDR_TYPE;
		rm_addr_out 			: out REG_ADDR_TYPE;
		rs_addr_out				: out REG_ADDR_TYPE;
		
		rn_out		: out REG_TYPE;
		rs_out		: out REG_TYPE;
		rm_out		: out REG_TYPE;
		rd_out 		: out REG_TYPE
		
	);
end entity REG_EX;

architecture BHV of REG_EX is
begin
	process(load, reset) is
	begin
		if(rising_edge(load)) then
			if(reset = '1') then
				pc_out 	<= (others => '0');

				instruction_type_out 	<= INSTRUCTION_TYPE_NOOP;
				opcode_out 				<= (others => '0');
				cond_out 				<= (others => '0');
				branch_offset_out 		<= (others => '0');
				is_signed_out 			<= '0';
				link_flag_out 			<= '0';
				load_store_out 			<= '0';
				shift_operation_out 	<= '0';
				shift_type_out 			<= (others => '0');
				immidiate_out 			<= (others => '0');

				rd_addr_out 			<= (others => '0');
				rn_addr_out 			<= (others => '0');
				rm_addr_out 			<= (others => '0');
				rs_addr_out 			<= (others => '0');
		
				rn_out <= (others => '0');
				rs_out <= (others => '0');
				rm_out <= (others => '0');
				rd_out <= (others => '0');
			elsif (stall = '0') then
				pc_out <= pc_in;

				instruction_type_out 	<= instruction_type_in;
				opcode_out 				<= opcode_in;
				cond_out 				<= cond_in;
				branch_offset_out 		<= branch_offset_in;
				is_signed_out 			<= is_signed_in;
				link_flag_out 			<= link_flag_in;
				load_store_out 			<= load_store_in;
				shift_operation_out 	<= shift_operation_in;
				shift_type_out 			<= shift_type_in;
				immidiate_out 			<= immidiate_in;

				rd_addr_out 			<= rd_addr_in;
				rn_addr_out 			<= rn_addr_in;
				rm_addr_out 			<= rm_addr_in;
				rs_addr_out 			<= rs_addr_in;

				rn_out <= rn_in;
				rs_out <= rs_in;
				rm_out <= rm_in;
				rd_out <= rd_in;
			end if;
		end if;
	end process;
end architecture;