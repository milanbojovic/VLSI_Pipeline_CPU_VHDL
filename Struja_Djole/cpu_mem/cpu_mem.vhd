library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;

use WORK.CPU_LIB.all;

entity CPU_MEM is
	port
	(
		clk : STD_LOGIC;
		reset : STD_LOGIC
	);
end CPU_MEM;

architecture STR of CPU_MEM is

	component RAM is
		generic 
		(
			ADDR_WIDTH : NATURAL := 20
		);

		port 
		(
			-- Input ports
			clk		: STD_LOGIC;
			halt	: STD_LOGIC;
			addr	: ADDR_TYPE;
			we		: STD_LOGIC := '1';

			-- Inout ports
			data	: inout WORD_TYPE
		);
	end component;

	component CPU_ALL is
		generic 
		(
			DATA_WIDTH : NATURAL := 32;
			ADDR_WIDTH : NATURAL := 32
			);
		
		port(
			signal clk: in STD_LOGIC;
			signal reset : in STD_LOGIC;
			signal we : out STD_LOGIC;
			signal halt : out STD_LOGIC;
			signal addr : out WORD_TYPE;
			signal data : inout WORD_TYPE
		);
	end component;

	signal addr : WORD_TYPE;
	signal data : WORD_TYPE;
	signal we : STD_LOGIC := '0';
	signal halt : STD_LOGIC := '0';
begin

	U_CPU_ALL : CPU_ALL port map (
		clk => clk,			--in CPU_MEM.clk
		reset => reset,		--in CPU_MEM.reset

		we => we,			--out RAM.we
		halt => halt,			--out RAM.we
		addr => addr,		--out RAM.addr
		data => data		--inout RAM.data
  	);

	U_RAM : RAM port map (
		clk => clk,		--in CPU_MEM.clk
		
		we => we,		--in CPU_ALL.we	
		halt => halt,		--in CPU_ALL.we	
		addr => addr,	--in CPU_ALL.addr	
		data => data	--inout CPU_ALL.data	
  	);

end architecture STR;

