LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY RegisterFile IS
    GENERIC (
        w : INTEGER := 3;
        n : INTEGER := 32
    );
    PORT (
        clk, RES : IN STD_LOGIC;

        RE_we1 : IN STD_LOGIC;
        RF_we2 : IN STD_LOGIC;
        RF_Rdst1 : IN STD_LOGIC_VECTOR(w - 1 DOWNTO 0);
        RF_Rdst2 : IN STD_LOGIC_VECTOR(w - 1 DOWNTO 0);
        RF_Wdata1 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        RF_Wdata2 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);

        RF_Rsrc1 : IN STD_LOGIC_VECTOR(w - 1 DOWNTO 0);
        RF_Rsrc2 : IN STD_LOGIC_VECTOR(w - 1 DOWNTO 0);

        RF_Rdata1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        RF_Rdata2 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
    );
END ENTITY RegisterFile;

ARCHITECTURE Behavioral OF RegisterFile IS
    TYPE register_array IS ARRAY (0 TO 2 ** w - 1) OF STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL q_registers : register_array;

BEGIN

    PROCESS (clk, RES)
    BEGIN
        IF RES = '1' THEN
            q_registers <= (OTHERS => (OTHERS => '0'));
        ELSIF rising_edge(clk) THEN
            IF RE_we1 = '1' THEN
                q_registers(TO_INTEGER(unsigned(RF_Rdst1))) <= RF_Wdata1;
            END IF;
            IF RF_we2 = '1' THEN
                q_registers(TO_INTEGER(unsigned(RF_Rdst2))) <= RF_Wdata2;
            END IF;
        END IF;

    END PROCESS;
    RF_Rdata1 <= q_registers(TO_INTEGER(unsigned(RF_Rsrc1)));
    RF_Rdata2 <= q_registers(TO_INTEGER(unsigned(RF_Rsrc2)));

END ARCHITECTURE Behavioral;