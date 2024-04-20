LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY RegisterFile IS
    GENERIC (
        w : INTEGER := 3;
        n : INTEGER := 32
    );
    PORT (
        clk, rst : IN STD_LOGIC;
        Rsrc1_address, Rsrc2_address : IN STD_LOGIC_VECTOR(w-1 DOWNTO 0);
        Rdest : IN STD_LOGIC_VECTOR(w-1 DOWNTO 0);
        WBdata : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        writeEnable : IN STD_LOGIC;
        Rsrc1_data, Rsrc2_data : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
    );
END ENTITY RegisterFile;

ARCHITECTURE Behavioral OF RegisterFile IS
    TYPE register_array IS ARRAY (0 TO 2**w-1) OF STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    SIGNAL q_registers : register_array;

BEGIN

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            q_registers <= (OTHERS => (OTHERS => '0'));
        ELSIF rising_edge(clk) THEN
            IF writeEnable = '1' THEN
                q_registers(TO_INTEGER(unsigned(Rdest))) <= WBdata;
            END IF;
        END IF;
    END PROCESS;
    Rsrc1_data <= q_registers(TO_INTEGER(unsigned(Rsrc1_address)));
    Rsrc2_data <= q_registers(TO_INTEGER(unsigned(Rsrc2_address)));
END ARCHITECTURE Behavioral;