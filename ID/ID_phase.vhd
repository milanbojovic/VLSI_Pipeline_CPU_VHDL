--ID Phase--
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_LIB.all;
use WORK.CPU_PKG.all;
use IEEE.STD_LOGIC_ARITH.all;


entity ID_PHASE is

	port
	(
		-- Input ports
		record_in_crls			:  in CRLS_RCD;
		
		--IF phase 
		if_record_id	      :	in	IF_ID_RCD;
		
		--MEM phase
		wb_record_id			:  in WB_ID_RCD;

		-- Output ports
		--EX phase
		id_record_ex			: out ID_EX_RCD
		
	);

end ID_PHASE;
 

architecture arch of ID_PHASE is

	--Register PC (Program Counter)
	signal pc					: REG_TYPE;
	signal ir1, ir2			: REG_TYPE;

	--Signals that will connect instruction decoder and register file 
	signal A_id					: REG_ADDR_TYPE;
	signal B_id 				: REG_ADDR_TYPE;
	signal imm_id				: IMMEDIATE_TYPE;
	signal dest_id 			: REG_ADDR_TYPE;
	signal store_data_id		: REG_ADDR_TYPE;
	signal reg_addr_id   : REG_ADDR_TYPE;
	signal offset_id			: BRANCH_OFFSET_TYPE;
	signal DPR_id				: STD_LOGIC;
	signal DPI_id 				: STD_LOGIC;
	signal BRANCH_id			: STD_LOGIC;
	signal LOAD_id				: STD_LOGIC;
	signal STORE_id			: STD_LOGIC;
	signal opcode_id 			: OPCODE_TYPE;
	signal mem_addr_id		: REG_ADDR_TYPE;
	
		
		
begin
	
	process (record_in_crls.clk) begin 
		if rising_edge(record_in_crls.clk) then 
			pc 	<= if_record_id.pc;
			ir1   <= if_record_id.ir1;
			ir2   <= if_record_id.ir2;
		end if;
	end process;
	
		id_record_ex.pc <= pc;
		
	--Instatination and connecting of INSTRUCTION_DECODER
	instr_dec : entity work.INSTRUCTION_DECODER(decoder_arch)
		port map (
				    
					 instruction    => ir1, 
					 
					 opcode         => opcode_id,
					 operand_A      => A_id,
					 operand_B      => B_id,
					 immediate      => imm_id,
					 destination    => dest_id,
					 mem_address    => mem_addr_id,
					 reg_address    => reg_addr_id,
					 store_data     => store_data_id,
					 offset         => offset_id,
					 DPR_decoder    => DPR_id,
					 DPI_decoder    => DPI_id,
					 BRANCH_decoder => BRANCH_id,
					 LOAD_decoder   => LOAD_id,
					 STORE_decoder  => STORE_id
					 
					 );
					 
	--Instatination and connecting of REG_FILE				 
	reg_file : entity work.REG_FILE(reg_arch)
		port map (
				    --Connection from the instruction decoder
				    DPR               => DPR_id,
					 DPI               => DPI_id,
					 BRANCH   		    => BRANCH_id,
					 LOAD              => LOAD_id,
					 STORE             => STORE_id,
					 operand_A_index   => A_id,
					 operand_B_index   => B_id,
					 destination_index => dest_id,
					 mem_address_index => mem_addr_id,
					 store_data_index	 => store_data_id,
					 opcode            => opcode_id,
					 immediate         => imm_id,
					 offset				 => offset_id,
					 
					 --Connection from the WB Phase
					 input_data			 => wb_record_id.data,
					 write_enable      => wb_record_id.write_enable,
					 destination_wb    => wb_record_id.reg_adr,
					 
					 --Connection to the record from the EX Phase	
					 operand_A_out     => id_record_ex.a,
					 operand_B_out     => id_record_ex.b,
					 destination_out   => id_record_ex.dst,
					 immediate_out     => id_record_ex.immediate,
					 offset_out		    => id_record_ex.branch_offset,
					 opcode_out			 => id_record_ex.opcode
					 
					 );

end arch;



