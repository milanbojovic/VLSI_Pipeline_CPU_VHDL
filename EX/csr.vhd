library ieee;

use IEEE.STD_LOGIC_1164.all;
use work.cpu_lib.all;

entity CSR is
	port(
		-- Input ports 
		load 						: in STD_LOGIC;
		reset 					: in STD_LOGIC;
		alu2_enable				: in SIGNAL_BIT_TYPE;
		
		n_in 						: in SIGNAL_BIT_TYPE ;
		c_in 						: in SIGNAL_BIT_TYPE ;
		v_in 						: in SIGNAL_BIT_TYPE ;
		z_in 						: in SIGNAL_BIT_TYPE ;
		
		n_in2 					: in SIGNAL_BIT_TYPE ;
		c_in2 					: in SIGNAL_BIT_TYPE ;
		v_in2 					: in SIGNAL_BIT_TYPE ;
		z_in2 					: in SIGNAL_BIT_TYPE ;
		
		-- Output ports
		n_out 					: out SIGNAL_BIT_TYPE := '0';
		c_out 					: out SIGNAL_BIT_TYPE := '0';
		v_out 					: out SIGNAL_BIT_TYPE := '0';
		z_out 					: out SIGNAL_BIT_TYPE := '0'
	);
end entity;

architecture arch of CSR is
begin
	process(load, reset, n_in, c_in, v_in, z_in, n_in2, c_in2, v_in2, z_in2) is
	begin
		if(rising_edge(load)) then
			if(reset = '1') then
				n_out <= '0';
				c_out <= '0';
				v_out <= '0';
				z_out <= '0';
			else
				if (alu2_enable = '0') then 
					n_out <= n_in;
					c_out <= c_in;
					v_out <= v_in;
					z_out <= z_in;
				elsif (alu2_enable = '1') then
					n_out <= n_in2;
					c_out <= c_in2;
					v_out <= v_in2;
					z_out <= z_in2;
				end if;
			end if;
		end if;
	end process;
end architecture;