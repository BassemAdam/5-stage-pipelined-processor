LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY PC IS
    GENERIC (
        N : INTEGER := 32
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        branch : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        pcBranch : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        pc : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
END ENTITY PC;

ARCHITECTURE PC_ARCH OF PC IS
    SIGNAL pcNext : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
BEGIN
    PROCESS (reset, clk)
    BEGIN
        IF reset = '1' THEN
            pcNext <= (OTHERS => '0');
        ELSIF falling_edge(clk) THEN
            IF branch = '1' THEN
                pcNext <= pcBranch;
            ELSIF enable = '1' THEN
                pcNext <= STD_LOGIC_VECTOR(unsigned(pcNext) + 1);
            END IF;
        END IF;
    END PROCESS;
    pc <= pcNext;
END ARCHITECTURE PC_ARCH;