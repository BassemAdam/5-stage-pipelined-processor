LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY InstrCache IS
    GENERIC (
        n : INTEGER := 16; -- number of bits per instruction
        m : INTEGER := 12; -- height of the cache
        k : INTEGER := 32 -- pc size
    );
    PORT (
        clk, RES : IN STD_LOGIC;
        IC_PC : IN STD_LOGIC_VECTOR(k - 1 DOWNTO 0);

        IC_data : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0); --so that i can read and write to
        PC_Reset : OUT STD_LOGIC_VECTOR(k - 1 DOWNTO 0); --to reset the PC
        PC_Interrupt : OUT STD_LOGIC_VECTOR(k - 1 DOWNTO 0) --to interrupt the PC
    );
END InstrCache;

ARCHITECTURE Behavioral OF InstrCache IS

    TYPE ram_type IS ARRAY (0 TO 2 ** m - 1) OF STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL ram : ram_type;

BEGIN
    PC_Reset <= ram(0) & ram(1);
    PC_Interrupt <= ram(2) & ram(3);
    PROCESS (clk, RES)
        VARIABLE temp_data : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    BEGIN
        IF rising_edge(clk) THEN
            IF to_integer(unsigned(IC_PC)) < 2 ** m THEN
                IC_data <= ram(to_integer(unsigned(IC_PC)));
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE Behavioral;