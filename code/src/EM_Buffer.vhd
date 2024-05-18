LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY EM_Buffer IS
    PORT (
        clk, RES, WE, FLUSH : IN STD_LOGIC;
        EM_Push_CCR : IN STD_LOGIC;
        EM_CCR : IN STD_LOGIC_VECTOR(0 TO 3);

        -- Passing through
        EM_OUTport_en_out : OUT STD_LOGIC;
        EM_OUTport_en_in : IN STD_LOGIC;
        EM_ALUorMem_in : IN STD_LOGIC;
        EM_ALUorMem_out : OUT STD_LOGIC;
        EM_we1_reg_in : IN STD_LOGIC;
        EM_we1_reg_out : OUT STD_LOGIC;
        EM_we2_reg_in : IN STD_LOGIC;
        EM_we2_reg_out : OUT STD_LOGIC;
        EM_Rdst1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        EM_Rdst1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        EM_Rdst2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        EM_Rdst2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        EM_ALUResult1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        EM_ALUResult1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        EM_ALUResult2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        EM_ALUResult2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        EM_POP_PC_in : IN STD_LOGIC;
        EM_POP_PC_out : OUT STD_LOGIC;

        --MEMORY OPERATIONS SIGNALS
        EM_STD_VALUE_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        EM_STD_VALUE_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        EM_MemW_in : IN STD_LOGIC;
        EM_MemW_out : OUT STD_LOGIC;
        EM_MemR_in : IN STD_LOGIC;
        EM_MemR_out : OUT STD_LOGIC;
        EM_Push_in : IN STD_LOGIC;
        EM_Push_out : OUT STD_LOGIC;
        EM_Pop_in : IN STD_LOGIC;
        EM_Pop_out : OUT STD_LOGIC;
        EM_Protect_in : IN STD_LOGIC;
        EM_Protect_out : OUT STD_LOGIC;
        EM_Free_in : IN STD_LOGIC;
        EM_Free_out : OUT STD_LOGIC
        --END MEMORY OPERATIONS SIGNALS
        --srcs

    );
END ENTITY EM_Buffer;

ARCHITECTURE EM_Buffer_Arch OF EM_Buffer IS
BEGIN
    PROCESS (clk, RES)
    BEGIN
        IF RES = '1' THEN
            EM_we1_reg_out <= '0';
            EM_we2_reg_out <= '0';
            EM_ALUorMem_out <= '0';
            EM_ALUResult1_out <= (OTHERS => '0');
            EM_ALUResult2_out <= (OTHERS => '0');
            EM_Rdst1_out <= (OTHERS => '0');
            EM_Rdst2_out <= (OTHERS => '0');
            EM_OUTport_en_out <= '0';
            EM_POP_PC_out <= '0';
            --MEMORY OPERATIONS SIGNALS
            EM_MemW_out <= '0';
            EM_MemR_out <= '0';
            EM_Push_out <= '0';
            EM_Pop_out <= '0';
            EM_Protect_out <= '0';
            EM_Free_out <= '0';
            --END MEMORY OPERATIONS SIGNALS
        ELSIF falling_edge(clk) THEN
            IF WE = '1' THEN
                EM_OUTport_en_out <= EM_OUTport_en_in;
                EM_ALUorMem_out <= EM_ALUorMem_in;
                EM_we1_reg_out <= EM_we1_reg_in;
                EM_we2_reg_out <= EM_we2_reg_in;
                EM_ALUResult1_out <= EM_ALUResult1_in;
                EM_ALUResult2_out <= EM_ALUResult2_in;
                EM_Rdst1_out <= EM_Rdst1_in;
                EM_Rdst2_out <= EM_Rdst2_in;
                --MEMORY OPERATIONS SIGNALS
                EM_MemW_out <= EM_MemW_in;
                EM_MemR_out <= EM_MemR_in;
                EM_Push_out <= EM_Push_in;
                EM_Pop_out <= EM_Pop_in;
                EM_Protect_out <= EM_Protect_in;
                EM_Free_out <= EM_Free_in;
                IF EM_MemW_in = '1' AND EM_Push_in = '0' THEN
                    EM_STD_VALUE_out <= EM_STD_VALUE_in;
                ELSIF EM_Push_CCR = '1' THEN
                    EM_STD_VALUE_out(31 DOWNTO 28) <= EM_CCR;
                    EM_STD_VALUE_out(28 DOWNTO 0) <= (OTHERS => '0');
                ELSE
                    EM_STD_VALUE_out <= EM_ALUResult1_in;
                END IF;
                --END MEMORY OPERATIONS SIGNALS
                EM_POP_PC_out <= EM_POP_PC_in;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE EM_Buffer_Arch;