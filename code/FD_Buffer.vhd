LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY FD_Buffer IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        WE : IN STD_LOGIC;
        --16 bits from instruction memory
        Intruction : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        OpCode : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        Src1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        Src2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        dst : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        FnNum : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END ENTITY FD_Buffer;

ARCHITECTURE Behavioral OF FD_Buffer IS

BEGIN
    PROCESS (CLK, RESET)
    BEGIN
        IF RESET = '1' THEN
            -- Asynchronous reset
            OpCode <= (OTHERS => '0');
            Src1 <= (OTHERS => '0');
            Src2 <= (OTHERS => '0');
            dst <= (OTHERS => '0');
            FnNum <= (OTHERS => '0');

      
        ELSIF falling_edge(clk) AND WE = '1' THEN
            
            OpCode <= Intruction(15 DOWNTO 13);
            dst <= Intruction(12 DOWNTO 10); 
            Src1 <= Intruction(9 DOWNTO 7);
            Src2 <= Intruction(6 DOWNTO 4);  
            FnNum <= Intruction(3 DOWNTO 0);
        END IF;
    END PROCESS;

END ARCHITECTURE Behavioral;