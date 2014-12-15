library ieee;
use ieee.std_logic_1164.all;
use work.cpu_lib.all;

entity BRANCH is
	port(
		-- Input ports
		instruction_type : INSTRUCTION_TYPE_TYPE;
		N, C, V, Z: std_logic;
		cond : COND_TYPE;
		
		-- Output ports
		branch_taken : out std_logic
	);
end entity BRANCH;

architecture BHV of BRANCH is
begin
	process(instruction_type, N, C, V, Z, cond)
	begin
		if(instruction_type = INSTRUCTION_TYPE_B_BL ) then
			case cond is
				when COND_EQ =>
					if(Z = '1') then
						branch_taken <= '1';
					else
						branch_taken <= '0';
					end if;
				when COND_GT =>
					if(N = V and Z = '0') then
						branch_taken <= '1';
					else
						branch_taken <= '0';
					end if;
				when COND_HI =>
					if(C = '0' and Z = '0') then
						branch_taken <= '1';
					else
						branch_taken <= '0';
					end if;
				when COND_AL =>
					branch_taken <= '1';
				when others =>
					branch_taken <= '0';
			end case;
		else
			branch_taken <= '0';
		end if;
	end process;
	
end architecture BHV;