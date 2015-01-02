library ieee;
library WORK;
use ieee.std_logic_1164.all;

package if_id is

	--Record which connects Instruction Fetch and Instruction Decode phase
	type if_id_record is record
		NPC	:;
		IR   	:;
	end record;
	
end package if_id;

package body if_id is
end package body if_id;