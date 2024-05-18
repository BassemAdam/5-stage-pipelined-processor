LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PC IS
    GENERIC (
        N : INTEGER := 32
    );
    PORT (
        clk, RES : IN STD_LOGIC;
        PC_en : IN STD_LOGIC;
        PC_stall_PopUse : IN STD_LOGIC;
        PC_Interrupt : IN STD_LOGIC;
        PC_branch : IN STD_LOGIC;
        PC_corrected : IN STD_LOGIC;
        PC_POP_PC : IN STD_LOGIC;
        PC_JMP_EXE_PC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        PC_JMP_DEC_PC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        PC_InterruptPC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        PC_ResetPC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        PC_RET_PC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

        PC_PC : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
END ENTITY PC;

ARCHITECTURE PC_ARCH OF PC IS

    SIGNAL pcNext : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

BEGIN

    PROCESS (RES, clk)
    BEGIN
        IF RES = '1' THEN
            pcNext <= (PC_ResetPC);
        ELSIF PC_Interrupt = '1' THEN
            pcNext <= PC_InterruptPC;
        ELSIF falling_edge(clk) THEN
            IF PC_POP_PC = '1' THEN
                pcNext <= PC_RET_PC;
            elsIF PC_corrected = '1' THEN
                pcNext <= PC_JMP_EXE_PC;
            ELSIF PC_branch = '1' THEN
                pcNext <= PC_JMP_DEC_PC;
            ELSIF PC_en = '1' AND NOT PC_stall_PopUse  = '1' THEN
                pcNext <= STD_LOGIC_VECTOR(unsigned(pcNext) + 1);
            END IF;

        END IF;
    END PROCESS;

    PC_PC <= pcNext;

END ARCHITECTURE PC_ARCH;
