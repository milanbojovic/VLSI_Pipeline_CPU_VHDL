library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;
use WORK.CPU_LIB.all;


--
-- instruction : instruction value loaded from memory
-- instruction_type : determens instruction type (one of the constants)
-- opcode : operaction code, one of the instruction constants
-- cond : cond code EQ, GT, HI, AL

-- is_signed : flag that says if signed operation in alu should be used
-- load_store : flag that controls if store or load instruction is used (1 - store, 0 - load): 
-- link_flag: determens if linking should be done during jump instructions (1 - link, 0 - none)

-- Rn : Rn register - value which should be shifted
-- Rs : Rs register - shift count

-- shift_operation : determens shift operation (0 - shift, 1 - rotate)
-- shift_type: type of shift instuction (00 - LL, 01 - LSR, 10 - ASR, 11 - NONE)

entity shifter is
	port (
        shift_operation: in STD_LOGIC;
        shift_type: in SHIFT_TYPE_TYPE;
      
        Rn: in REG_TYPE;
        Rs: in REG_TYPE;

        result : out REG_TYPE
    );
end shifter;

architecture rtl of shifter is

    function DO_SHIFT_LL (Rn: REG_TYPE; count : NATURAL) return REG_TYPE is
    begin
		return REG_TYPE(SHIFT_LEFT(UNSIGNED(Rn), count));
    end DO_SHIFT_LL;

    -- shift logical right
    function DO_SHIFT_LSR (Rn: REG_TYPE; count : NATURAL) return REG_TYPE is
    begin
        return REG_TYPE(SHIFT_RIGHT(UNSIGNED(Rn), count));
    end DO_SHIFT_LSR;

    -- shift arithmetic right
    function DO_SHIFT_ASR (Rn: REG_TYPE; count : NATURAL) return REG_TYPE is
    begin
        return REG_TYPE(SHIFT_RIGHT(SIGNED(Rn), count));
    end DO_SHIFT_ASR;

    -- rotate logical left
    function DO_ROTATE_LL (Rn: REG_TYPE; count : NATURAL) return REG_TYPE is
    begin
        return  REG_TYPE(ROTATE_LEFT(SIGNED(Rn), count));
    end DO_ROTATE_LL;

    -- rotate logical right
    function DO_ROTATE_LSR (Rn: REG_TYPE; count : NATURAL) return REG_TYPE is
    begin
        return  REG_TYPE(ROTATE_RIGHT(SIGNED(Rn), count));
    end DO_ROTATE_LSR;

    -- rotate right
    function DO_ROTATE_ASR (Rn: REG_TYPE; count : NATURAL) return REG_TYPE is
    begin
        return  REG_TYPE(ROTATE_RIGHT(UNSIGNED(Rn), count));
    end DO_ROTATE_ASR;

begin
   process (Rn, Rs, shift_operation, shift_type)
       variable count : NATURAL;
	begin

        if (Rs /= UNDEFINED_32) then
            count := NATURAL(to_integer(UNSIGNED(Rs)));
        else 
            count := 0;
        end if;

        if (shift_operation = F_SHIFT) then
            case shift_type is
                when SHIFT_LL =>
                    result <= DO_SHIFT_LL(Rn, count);
                when SHIFT_LSR =>
                    result <= DO_SHIFT_LSR(Rn, count);
                when SHIFT_ASR =>
                    result <= DO_SHIFT_ASR(Rn, count);
                when others =>
                    result <= Rn;
            end case;
        else 
            case shift_type is
                when SHIFT_LL =>
                    result <= DO_ROTATE_LL(Rn, count);
                when SHIFT_LSR =>
                    result <= DO_ROTATE_LSR(Rn, count);
                when SHIFT_ASR =>
                    result <= DO_ROTATE_ASR(Rn, count);
                when others =>
                    result <= Rn;
            end case;
        end if;

	end process;
end rtl;