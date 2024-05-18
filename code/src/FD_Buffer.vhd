LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY FD_Buffer IS
    PORT (
        clk : IN STD_LOGIC;
        RES : IN STD_LOGIC;
        WE : IN STD_LOGIC;
        FD_INT : IN STD_LOGIC;
        FD_Flush_FD : IN STD_LOGIC;
        FLUSH : IN STD_LOGIC;
        FD_stall_PopUse : IN STD_LOGIC;
        FD_Inst : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16 bits from instruction memory
        FD_IN_PORT : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        FD_current_PC_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        FD_OpCode : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        FD_Rsrc1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        FD_Rsrc2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        FD_Rdst1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        FD_Rdst2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        FD_Func : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        FD_InputPort : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        FD_current_PC_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Passing through
        FD_isImm_in : IN STD_LOGIC
    );
END ENTITY FD_Buffer;

ARCHITECTURE Behavioral OF FD_Buffer IS

BEGIN
    PROCESS (CLK, RES)
    BEGIN
        IF RES = '1' THEN
            -- Asynchronous RES
            FD_OpCode <= (OTHERS => '0');
            FD_Rsrc1 <= (OTHERS => '0');
            FD_Rsrc2 <= (OTHERS => '0');
            FD_Rdst1 <= (OTHERS => '0');
            FD_Rdst2 <= (OTHERS => '0');
            FD_Func <= (OTHERS => '0');
            FD_current_PC_out <= (OTHERS => '0');

        ELSIF FD_INT = '1' THEN
            FD_OpCode <= "111";
            FD_Func <= "1000";
        ELSIF falling_edge(clk) AND FD_Flush_FD = '1' THEN
            FD_OpCode <= (OTHERS => '0');

        ELSIF falling_edge(clk) AND WE = '1' AND NOT FD_stall_PopUse = '1' THEN

            FD_Rdst1 <= FD_Inst(12 DOWNTO 10);
            -- FD_Rdst2 <= FD_Inst(9 DOWNTO 7);
            FD_Rdst2 <= FD_Inst(6 DOWNTO 4);
            FD_Rsrc1 <= FD_Inst(9 DOWNTO 7);
            FD_Rsrc2 <= FD_Inst(6 DOWNTO 4);
            FD_Func <= FD_Inst(3 DOWNTO 0);
            FD_InputPort <= FD_IN_PORT;
            IF FD_isImm_in = '1' THEN
                FD_OpCode <= "000";
            ELSE
                FD_OpCode <= FD_Inst(15 DOWNTO 13);
            END IF;

            FD_current_PC_out <= FD_current_PC_in;
        END IF;
    END PROCESS;

END ARCHITECTURE Behavioral;