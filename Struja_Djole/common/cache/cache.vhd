library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use WORK.CPU_LIB.all;
	

-- tag 																    block 		  offset
-- 31 30 29 28 27 26 25 24 23 22 21 19 18 17 16 15 14 13 12 11 10 9 8 | 7 6 5 4 3 2 | 1 0
entity CACHE is
	generic (
		TAG_WIDTH 		: NATURAL := 24;
		BLOCK_WIDTH 	: NATURAL := 6;
		OFFSET_WIDTH	: NATURAL := 2
	);

	port (
		clk			: STD_LOGIC;
		reset		: STD_LOGIC;
		flash		: STD_LOGIC;
		flashed		: out STD_LOGIC;

		addr		: ADDR_TYPE;
		addr_ram 	: out ADDR_TYPE;

		we			: STD_LOGIC := '1';
		we_ram		: out STD_LOGIC := '1';

		data		: inout REG_TYPE;
		data_ram	: inout REG_TYPE;

		miss		: out STD_LOGIC
	);
end CACHE;


architecture RTL of CACHE is
	type MEMORY_TYPE is array(2**(BLOCK_WIDTH + OFFSET_WIDTH)-1 downto 0) of WORD_TYPE;
	shared variable  cache : MEMORY_TYPE;

	subtype TAG_TYPE is STD_LOGIC_VECTOR(TAG_WIDTH - 1 downto 0);
	type TAG_ARR_TYPE is array (2**BLOCK_WIDTH - 1 downto 0) of TAG_TYPE;
	shared variable tags : TAG_ARR_TYPE;

	type FLAG_ARR_TYPE is array (2**BLOCK_WIDTH - 1 downto 0) of STD_LOGIC;
	shared variable valid : FLAG_ARR_TYPE := (others => '0');
	shared variable dirty : FLAG_ARR_TYPE := (others => '0');

	signal miss_out : STD_LOGIC := '0';

	shared variable step : INTEGER := 15;
begin
	process (clk, miss_out) 
		variable block_no : NATURAL;
		variable cache_addr : NATURAL;
		variable base_addr : NATURAL;
		variable cache_out : REG_TYPE := HIGH_Z_32;
		variable flash_pointer : NATURAL := 0;
		variable flash_step : NATURAL := 3;
		variable block_addr : STD_LOGIC_VECTOR(5 downto 0);
		variable offset_addr : STD_LOGIC_VECTOR(1 downto 0);
		variable flashed_out : STD_LOGIC;
		variable flashed_out_wait : NATURAL := 0;
	begin
		if (rising_edge(clk)) then
			-- empty lines when we don't need them
			we_ram <= '0';
			addr_ram <= UNDEFINED_32;
			data_ram <= HIGH_Z_32;
			flashed <= flashed_out;

			if (reset = '1') then
				valid := (others => '0');
				dirty := (others => '0');
				flash_pointer := 0;
				flash_step := 3;
				step := 15;
				miss_out <= '0';
				flashed_out := '0';
				we_ram <= '0';

			elsif (flashed_out_wait > 0) then
				flashed_out_wait := flashed_out_wait - 1;

				if (flashed_out_wait = 0) then
					flashed_out := '1';
				end if;
			elsif (flash = '1' and flashed_out = '0') then
				if (dirty(flash_pointer) = '1') then
					we_ram <= '1';
					flash_step := (flash_step + 1) mod 4;

					base_addr := flash_pointer * 2**OFFSET_WIDTH;
					block_addr := STD_LOGIC_VECTOR(TO_UNSIGNED(flash_pointer, 6));
					offset_addr := STD_LOGIC_VECTOR(TO_UNSIGNED(flash_step, 2));
					
					cache_out := cache(base_addr + flash_step);

					addr_ram <= tags(flash_pointer) & block_addr & offset_addr;

					if (flash_step = 3) then
						dirty(flash_pointer) := '0';
						flash_pointer := flash_pointer + 1;
					end if;

					data <= HIGH_Z_32;
					data_ram <= cache_out;
				else 
					data <= HIGH_Z_32;
					we_ram <= '0';

					for i in 0 to 2**BLOCK_WIDTH - 1 loop
						if (dirty(i) = '1') then
							flash_pointer := i;
							exit;
						elsif (i = 2**BLOCK_WIDTH -1) then
							flashed_out_wait := 12;
						end if;
					end loop;
				end if;
			else
				if (addr = UNDEFINED_32) then
					block_no := 0;
					cache_addr := 0;
				else
					block_no := TO_INTEGER(UNSIGNED(addr(7 downto 2)));
				
					-- direct address in cache
					cache_addr := TO_INTEGER(UNSIGNED(addr(7 downto 0)));
				end if;
				
				-- address of the lowes word in the block
				base_addr := block_no * 2**OFFSET_WIDTH;
			
				if (addr = UNDEFINED_32) then


				elsif (addr(31 downto 8) = tags(block_no) and valid(block_no) = '1') then
					miss_out <= '0';
			 		if (we = '1') then
			 			cache(cache_addr) := data;
						dirty(block_no) := '1';
			 		else 
						cache_out := cache(cache_addr);
			 		end if;
			 	else 
			 		miss_out <= '1';
			 		step := (step + 1) mod 16;

					cache_out := HIGH_Z_32;
					
					-- 4 koraka dovlacenja bloka
					case step is
						when 0 =>
							addr_ram <= addr(31 downto 2) & "00";

						when 1 =>
							addr_ram <= addr(31 downto 2) & "01";

						when 2 =>
							addr_ram <= addr(31 downto 2) & "10";

						when 3 =>
							addr_ram <= addr(31 downto 2) & "11";

						-- 4 koraka cuvanja bloka
						when 4 =>
							-- if block we should replace is dirty we need steps 0 to 3 
							if (dirty(block_no) = '1') then
								we_ram <= '1';
								--data_ram <= cache(base_addr);
								cache_out := cache(base_addr);
								addr_ram <= tags(block_no) & addr(7 downto 2) & "00";
							end if;
						
						when 5 =>
							if (dirty(block_no) = '1') then
								we_ram <= '1';
								cache_out := cache(base_addr + 1);
								addr_ram <= tags(block_no) & addr(7 downto 2) & "01";
							end if;

						when 6 =>
							if (dirty(block_no) = '1') then
								we_ram <= '1';
								cache_out := cache(base_addr + 2);
								addr_ram <= tags(block_no) & addr(7 downto 2) & "10";
							end if;
						when 7 =>
							if (dirty(block_no) = '1') then
								we_ram <= '1';
								cache_out := cache(base_addr + 3);
								addr_ram <= tags(block_no) & addr(7 downto 2) & "11";
							end if;

						-- 4 koraka cuvanja bloka iz memorije u kesu
						when 12 =>
							cache(base_addr) := data_ram;

						when 13 =>
							cache(base_addr + 1) := data_ram;

						when 14 =>
							cache(base_addr + 2) := data_ram;

						when 15 =>
							cache(base_addr + 3) := data_ram;

							dirty(block_no) := '0';
							valid(block_no) := '1';
							tags(block_no) := addr(31 downto 8);
						when others  =>
					end case;
		 		end if;

	 			if (addr = UNDEFINED_32) then
	 				data <= HIGH_Z_32;

		 		elsif (addr(31 downto 8) = tags(block_no) and valid(block_no) = '1') then
		 			if (we = '1') then
		 				data <= HIGH_Z_32;
		 			else 
						data <= cache_out;
		 			end if;
		 			
	 				data_ram <= HIGH_Z_32;
		 		else 
		 			data <= HIGH_Z_32;
		 			data_ram <= cache_out;
		 		end if;
			end if;
		end if;
	end process;

	miss <= miss_out;

end architecture;
