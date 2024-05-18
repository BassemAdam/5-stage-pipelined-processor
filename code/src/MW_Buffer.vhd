LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MW_Buffer IS
    PORT (
        clk, RES, WE, FLUSH : IN STD_LOGIC;
        MW_ALUorMem : IN STD_LOGIC;
        MW_ALUResult1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        MW_ALUResult2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        MW_MemResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        MW_value1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MW_value2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Passing through

        MW_OUTport_en_out : OUT STD_LOGIC;
        MW_OUTport_en_in : IN STD_LOGIC;
        MW_we1_reg_in : IN STD_LOGIC;
        MW_we1_reg_out : OUT STD_LOGIC;
        MW_we2_reg_in : IN STD_LOGIC;
        MW_we2_reg_out : OUT STD_LOGIC;
        MW_Rdst1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        MW_Rdst1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        MW_Rdst2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        MW_Rdst2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        MW_POP_PC_in : IN STD_LOGIC;
        MW_POP_PC_out : OUT STD_LOGIC

    );
END ENTITY MW_Buffer;

ARCHITECTURE MW_Buffer_Arch OF MW_Buffer IS
BEGIN
    PROCESS (clk, RES)
    BEGIN
        IF RES = '1' THEN
            MW_we1_reg_out <= '0';
            MW_we2_reg_out <= '0';
            MW_value1 <= (OTHERS => '0');
            MW_value2 <= (OTHERS => '0');
            MW_Rdst1_out <= (OTHERS => '0');
            MW_Rdst2_out <= (OTHERS => '0');
            MW_OUTport_en_out <= '0';
            MW_POP_PC_out <= '0';
        ELSIF falling_edge(clk) THEN
            IF WE = '1' THEN
                IF (MW_ALUorMem = '1') THEN
                    MW_value1 <= MW_MemResult;
                ELSE
                    MW_value1 <= MW_ALUResult1;
                    MW_value2 <= MW_ALUResult2;
                END IF;
                MW_OUTport_en_out <= MW_OUTport_en_in;
                MW_we1_reg_out <= MW_we1_reg_in;
                MW_we2_reg_out <= MW_we2_reg_in;
                MW_Rdst1_out <= MW_Rdst1_in;
                MW_Rdst2_out <= MW_Rdst2_in;
                MW_POP_PC_out <= MW_POP_PC_in;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE MW_Buffer_Arch;