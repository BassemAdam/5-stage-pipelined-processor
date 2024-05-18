
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CCR IS
    PORT (
        clk, RES : IN STD_LOGIC;
        CCR_flags_in : IN STD_LOGIC_VECTOR (0 TO 3);
        CCR_flags_en : IN STD_LOGIC_VECTOR (0 TO 3);

        CCR_flags_out : OUT STD_LOGIC_VECTOR (0 TO 3)
    );
END ENTITY CCR;

ARCHITECTURE arch1 OF CCR IS

BEGIN

    PROCESS (clk, RES)
    BEGIN

        IF RES = '1' THEN
            CCR_flags_out <= "0000";
        ELSIF rising_edge(clk) THEN

            IF CCR_flags_en(0) = '1' THEN
                CCR_flags_out(0) <= CCR_flags_in(0);
            END IF;

            IF CCR_flags_en(1) = '1' THEN
                CCR_flags_out(1) <= CCR_flags_in(1);
            END IF;

            IF CCR_flags_en(2) = '1' THEN
                CCR_flags_out(2) <= CCR_flags_in(2);
            END IF;

            IF CCR_flags_en(3) = '1' THEN
                CCR_flags_out(3) <= CCR_flags_in(3);
            END IF;

        END IF;

    END PROCESS;

END ARCHITECTURE arch1;