library ieee;

use IEEE.STD_LOGIC_1164.all;
use work.cpu_lib.all;

entity CSR is
	port(
		-- Input ports 
		load 		: STD_LOGIC;
		reset 	: STD_LOGIC;
		
		n_in : SIGNAL_BIT_TYPE ;
		c_in : SIGNAL_BIT_TYPE ;
		v_in : SIGNAL_BIT_TYPE ;
		z_in : SIGNAL_BIT_TYPE ;
		
		-- Output ports
		n_out : out SIGNAL_BIT_TYPE := '0';
		c_out : out SIGNAL_BIT_TYPE := '0';
		v_out : out SIGNAL_BIT_TYPE := '0';
		z_out : out SIGNAL_BIT_TYPE := '0'
		
	);
end entity;

architecture arch of CSR is
begin
	process(load, reset, n_in, c_in, v_in, z_in ) is
	begin
		if(rising_edge(load)) then
			if(reset = '1') then
				n_out <= '0';
				c_out <= '0';
				v_out <= '0';
				z_out <= '0';
			else
				n_out <= n_in;
				c_out <= c_in;
				v_out <= v_in;
				z_out <= z_in;
			end if;
		end if;
	end process;
end architecture;