--- CPU ---
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
use WORK.EX_IF_PKG.all;
use WORK.IF_ID_PKG.all;

entity CPU is
  port
    (
    -- Input ports
      signal clk		: STD_LOGIC;
		signal reset	: STD_LOGIC;
      signal load 	: STD_LOGIC;
      signal stall 	: STD_LOGIC

		-- Output ports	
    );
end CPU;

architecture arch of CPU is

	signal record_crls : CRLS_RCD;
	
	--temp record - delete it !!!
	signal ex_record_if: EX_IF_RCD;
	signal if_record_id: IF_ID_RCD;

begin	
		record_crls.clk <= clk;
		record_crls.reset <= reset;
		record_crls.load <= load;
		record_crls.stall <= stall;
		
		-- Try to connect clk with reordc_crls.clk and recursevly !!!
		IF_PHASE : entity work.IF_PHASE(arch) port map (record_crls, ex_record_if, if_record_id);
		
	
end arch;