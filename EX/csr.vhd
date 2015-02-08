library ieee;

use IEEE.STD_LOGIC_1164.all;
use work.cpu_lib.all;
use WORK.CPU_PKG.all;

entity CSR is
	port(
		-- Input ports 
		record_in_crls 		: in CRLS_RCD;
		alu1_enable				: in SIGNAL_BIT_TYPE;
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
	process(record_in_crls.reset, record_in_crls.clk) is
	begin
			if (record_in_crls.reset = '0') then
				if (rising_edge(record_in_crls.clk)) then
						if (alu1_enable = '1') then 
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
			else
			  	n_out <= '0';
				c_out <= '0';
				v_out <= '0';
				z_out <= '0';
			end if;
	end process;
end architecture;