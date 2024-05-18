LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--stack pointer that starts from address 2^12-1 and decrements by 2
ENTITY SP IS
    GENERIC (
        WIDTH : INTEGER := 12
    );
    PORT (
        RES : IN STD_LOGIC;
        SP_Push : IN STD_LOGIC;
        SP_Pop : IN STD_LOGIC;

        SP_SP : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
    );
END SP;

ARCHITECTURE SPArch OF SP IS

    SIGNAL sp : unsigned(WIDTH - 1 DOWNTO 0);

BEGIN

    PROCESS (RES, SP_Push, SP_Pop)
    BEGIN
        IF RES = '1' THEN
            sp <= to_unsigned(2 ** WIDTH - 1, sp'length); -- Initialize to 2^12-1
        ELSIF SP_Push = '1' AND sp /= to_unsigned(0, sp'length) THEN
            sp <= sp - 2; -- Decrement by 2 on push
        ELSIF SP_Pop = '1' AND sp /= to_unsigned(0, sp'length) THEN
            sp <= sp + 2; -- Increment by 2 on pop
        END IF;
    END PROCESS;

    SP_SP <= STD_LOGIC_VECTOR(sp);

END SPArch;