--  ALU  --
library IEEE;
library WORK;

use IEEE.STD_LOGIC_1164.all;
use WORK.CPU_PKG.all;
use WORK.CPU_LIB.all;
use IEEE.STD_LOGIC_ARITH.all;


-- opcode : operation code check cpu_lib for more details
-- a : value of the first operand
-- b : value of the second operand
-- carry_in: value of the carry flag from previos operation
-- zero_in			-- || --
-- overflow_in		-- || --
-- negative_in		-- || --
-- carry_out : carry exists
-- overflow : signed operation overflow happend
-- negative : result is negative
-- zero : result equals zero
-- result : result of operation

entity ALU is
	port(
			opcode: in OPCODE_TYPE;
			a : in REG_TYPE;
			b : in REG_TYPE;

			negative_in : SIGNAL_BIT_TYPE 	:= '0';
			carry_in 	: SIGNAL_BIT_TYPE 	:= '0';
			overflow_in : SIGNAL_BIT_TYPE 	:= '0';
			zero_in 	 	: SIGNAL_BIT_TYPE 	:= '0';			

			-- output ports
			result 		: out REG_TYPE;

			negative_out: out SIGNAL_BIT_TYPE;
			carry_out	: out SIGNAL_BIT_TYPE;
			overflow_out: out SIGNAL_BIT_TYPE;
			zero_out 	: out SIGNAL_BIT_TYPE
			
	);

end entity ALU;

architecture arch of ALU is

	shared variable result_out : REG_TYPE;
	shared variable carry, overflow, negative, zero: SIGNAL_BIT_TYPE;

	-- logical and operation
	function DO_AND(a, b : REG_TYPE)	return REG_TYPE is
	begin
		return REG_TYPE(a and b);
	end DO_AND;

	-- unsigned sub operation
	function DO_SUB_U(a, b : REG_TYPE) return  REG_TYPE is
	begin
		return unsigned(a) - unsigned(b);
	end DO_SUB_U;


	-- unsigned add operation
	function DO_ADD_U(a, b : REG_TYPE) return REG_TYPE is
	begin
		return unsigned(a) + unsigned(b);
	end DO_ADD_U;

	-- unsigned add operation with cary flag
	function DO_ADC_U(a, b : REG_TYPE; carry : in SIGNAL_BIT_TYPE)	return REG_TYPE is
	begin
		return unsigned(a) + unsigned(b) + carry;
	end DO_ADC_U;

	-- unsigned sub operation with cary flag
	function DO_SBC_U(a, b : REG_TYPE; carry : in SIGNAL_BIT_TYPE) return REG_TYPE is
	begin
		return unsigned(a) - unsigned(b) - carry;
	end DO_SBC_U;

	-- signed sub operation
	function DO_SUB_S(a, b : REG_TYPE) return REG_TYPE is
	begin
		return signed(a) - signed(b);
	end DO_SUB_S;

	function DO_CMP(a,b : REG_TYPE) return REG_TYPE is
	begin
		return DO_SUB_S(a, b);
	end DO_CMP;

	-- signed add operation
	function DO_ADD_S(a, b : REG_TYPE) return REG_TYPE  is
	begin
		return signed(a) + signed(b);
	end DO_ADD_S;

	-- signed add operation with cary flag
	function DO_ADC_S(a, b : REG_TYPE; carry : in SIGNAL_BIT_TYPE)	return REG_TYPE is
	begin
		return signed(a) + signed(b) + carry;
	end DO_ADC_S;

	-- signed sub operation with cary flag
	function DO_SBC_S(a, b : REG_TYPE; carry : in SIGNAL_BIT_TYPE) return REG_TYPE is
	begin
		return signed(a) - signed(b) - carry;
	end DO_SBC_S;

	function DO_MOV(b : REG_TYPE) return REG_TYPE is
	begin
		return b;
	end DO_MOV;

	-- logical not operation
	function DO_NOT(b : REG_TYPE)	return REG_TYPE is
	begin
		return REG_TYPE(not b);
	end DO_NOT;

	function DO_UMOV(b : REG_TYPE) return REG_TYPE is
	begin
		return unsigned(b) - '0';
	end DO_UMOV;

	function DO_SMOV(b : REG_TYPE) return REG_TYPE is
	begin
		return signed(b) - '0';
	end DO_SMOV;
	
	function DO_LOAD_STORE(a : REG_TYPE) return REG_TYPE is
	begin
		return unsigned(a) - '0';
	end DO_LOAD_STORE;

	procedure SET_FLAGS(a, b, result : REG_TYPE;
						opcode 	: OPCODE_TYPE;
						overflow_out, zero_out, negative_out, carry_out : out SIGNAL_BIT_TYPE) is
		variable msb_a, msb_b, msb_res: SIGNAL_BIT_TYPE;
		variable ext_a, ext_b, ext_result : STD_LOGIC_VECTOR (32 downto 0);
	begin
		msb_a := a(REG_TYPE'length - 1);
		msb_b := b(REG_TYPE'length - 1);
		msb_res := result(REG_TYPE'length - 1);

		--Overflow (SIGNED operations only)
		if (opcode = OPCODE_SADD or opcode = OPCODE_SADC ) then
			if(msb_a = msb_b and msb_res /= msb_b ) then
				overflow_out := '1';
				carry_out 	 := '0';
			else
				overflow_out := '0';
				carry_out 	 := '0';
			end if;
		elsif (opcode = OPCODE_SSUB or opcode = OPCODE_SSBC or opcode = OPCODE_CMP) then
			if(msb_a /= msb_b and msb_res = msb_b) then
				overflow_out := '1';
				carry_out 	 := '0';
			else
				overflow_out := '0';
				carry_out 	 := '0';
			end if;
		end if;

		--Zero
		if(result = ZERO_32) then
			zero_out := '1';
		else
			zero_out := '0';
		end if;

		--Negative
		if (msb_res = '1') and (opcode = OPCODE_SADD or opcode = OPCODE_SADC or opcode = OPCODE_SSUB or opcode = OPCODE_SSBC or opcode = OPCODE_CMP) then
			negative_out := '1';
		else
			negative_out := '0';
		end if;

		-- carry (UNSIGNED operations only)
		if(opcode = OPCODE_ADD or opcode = OPCODE_ADC) then
			ext_a := '0' & a;
			ext_b := '0' & b;
			ext_result := signed(ext_a) + signed(ext_b);
			carry_out := ext_result(32);
			overflow_out := '0';
		elsif (opcode = OPCODE_SUB or opcode = OPCODE_SBC) then
			ext_a := '1' & a;
			ext_b := '0' & b;
			ext_result := signed(ext_a) - signed(ext_b);
			carry_out := not ext_result(32);
			overflow_out := '0';
		elsif (opcode = OPCODE_SADD or opcode = OPCODE_SADC or opcode = OPCODE_SSUB or opcode = OPCODE_SSBC or opcode = OPCODE_CMP) then
			carry_out := '0';
		else
			carry_out := carry_in;
		end if;

	end SET_FLAGS;

	procedure NO_EFFECT(carry_in, overflow_in, negative_in, zero_in	: SIGNAL_BIT_TYPE;
						carry_out, negative_out,
						zero_out, overflow_out : out  SIGNAL_BIT_TYPE) is
	begin
		carry_out			:= carry_in;
		zero_out			:= zero_in;
		negative_out	:= negative_in;
		overflow_out	:= overflow_in;
	end NO_EFFECT;

begin
	process (a, b, opcode, carry_in, zero_in, overflow_in, negative_in)
	begin
		case opcode is

			when OPCODE_AND =>
				result_out := DO_AND(a, b);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);

			when OPCODE_SUB =>
					result_out := DO_SUB_U(a, b);
					SET_FLAGS(a, b, result_out, opcode, overflow, zero, negative, carry);

			when OPCODE_ADD =>
					result_out := DO_ADD_U(a, b);
					SET_FLAGS(a, b, result_out, opcode,	overflow, zero, negative, carry);

			when OPCODE_ADC =>
					result_out := DO_ADC_U(a, b, carry_in);
					SET_FLAGS(a, b, result_out, opcode, overflow, zero, negative, carry);

			when OPCODE_SBC =>
					result_out := DO_SBC_U(a, b, carry_in);
					SET_FLAGS(a, b, result_out, opcode, overflow, zero, negative, carry);

			when OPCODE_CMP =>
				result_out := DO_CMP(a, b);
				SET_FLAGS(a, b, result_out, opcode, overflow, zero, negative, carry);
				result_out := UNDEFINED_32;

			when OPCODE_SSUB =>
					result_out := DO_SUB_S(a, b);
					SET_FLAGS(a, b, result_out, opcode, overflow, zero, negative, carry);

			when OPCODE_SADD =>
					result_out := DO_ADD_S(a, b);
					SET_FLAGS(a, b, result_out, opcode,	overflow, zero, negative, carry);

			when OPCODE_SADC =>
					result_out := DO_ADC_S(a, b, carry_in);
					SET_FLAGS(a, b, result_out, opcode, overflow, zero, negative, carry);

			when OPCODE_SSBC =>
					result_out := DO_SBC_S(a, b, carry_in);
					SET_FLAGS(a, b, result_out, opcode, overflow, zero, negative, carry);

			when OPCODE_MOV =>
				result_out := DO_MOV(b);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);

			when OPCODE_NOT =>
				result_out := DO_NOT(b);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);

			when OPCODE_SL =>
				result_out := DO_SHIFT_LL(a, b);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);

			when OPCODE_SR =>
				result_out := DO_SHIFT_LSR(a, b);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);

			when OPCODE_ASR =>
				result_out := DO_SHIFT_ASR(a, b);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);

			when OPCODE_UMOV =>
				result_out := DO_UMOV(b);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);

			when OPCODE_SMOV =>
				result_out := DO_SMOV(b);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);

			--For all branch instructions
			when OPCODE_BEQ =>
				result_out := DO_ADD_S(a, b);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);
				
			when OPCODE_BGT =>
				result_out := DO_ADD_S(a, b);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);
				
			when OPCODE_BHI =>
				result_out := DO_ADD_S(a, b);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);				
				
			when OPCODE_BAL =>
				result_out := DO_ADD_S(a, b);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);
				
			when OPCODE_BLAL =>
				result_out := DO_ADD_S(a, b);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);
				
			when OPCODE_LOAD =>
				result_out := DO_LOAD_STORE(a);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);
				
			when OPCODE_STORE =>
				result_out := DO_LOAD_STORE(a);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);
				
			when others =>
				--STOP instruction included !!!
				result_out := REG_TYPE(UNDEFINED_32);
				NO_EFFECT(carry_in, overflow_in, negative_in, zero_in, carry, negative , zero, overflow);
		end case;

		result <= result_out;
		carry_out <= carry;
		zero_out <= zero;
		overflow_out <= overflow;
		negative_out <= negative;
	end process;

end architecture arch;
