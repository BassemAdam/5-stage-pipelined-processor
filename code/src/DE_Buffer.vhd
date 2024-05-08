LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY DE_Buffer IS
    PORT (
        clk, RES, WE : IN STD_LOGIC;
        DE_Rsrc1_Val : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DE_Rsrc2_Val : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DE_Imm : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        DE_isImm : IN STD_LOGIC;

        DE_ALUopd1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        DE_ALUopd2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Passing through
        DE_InPort_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DE_InPort_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- Control signals
        DE_OUTport_en_in : IN STD_LOGIC;
        DE_OUTport_en_out : OUT STD_LOGIC;
        DE_isInput_in : IN STD_LOGIC;
        DE_isInput_out : OUT STD_LOGIC;
        DE_we1_reg_in : IN STD_LOGIC;
        DE_we1_reg_out : OUT STD_LOGIC;
        DE_we2_reg_in : IN STD_LOGIC;
        DE_we2_reg_out : OUT STD_LOGIC;
        DE_ALUorMem_in : IN STD_LOGIC;
        DE_ALUorMem_out : OUT STD_LOGIC;
        DE_flags_en_in : IN STD_LOGIC_VECTOR (0 TO 3);
        DE_flags_en_out : OUT STD_LOGIC_VECTOR (0 TO 3);
        DE_Rdst1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        DE_Rdst2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        DE_Rdst1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        DE_Rdst2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        DE_ALUsel_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        DE_ALUsel_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END ENTITY DE_Buffer;

ARCHITECTURE DE_Buffer_Arch OF DE_Buffer IS
BEGIN
    PROCESS (clk, RES)
        VARIABLE DE_ALUopd2_var : STD_LOGIC_VECTOR(31 DOWNTO 0);
    BEGIN
        IF RES = '1' THEN
            DE_we1_reg_out <= '0';
            DE_ALUorMem_out <= '0';
            DE_flags_en_out <= (OTHERS => '0');
            DE_ALUopd1 <= (OTHERS => '0');
            DE_ALUopd2 <= (OTHERS => '0');
            DE_Rdst1_out <= (OTHERS => '0');
            DE_Rdst2_out <= (OTHERS => '0');
            DE_ALUsel_out <= (OTHERS => '0');
            DE_OUTport_en_out <= '0';
        ELSIF falling_edge(clk) THEN

            IF WE = '1' THEN

                DE_OUTport_en_out <= DE_OUTport_en_in;
                DE_we1_reg_out <= DE_we1_reg_in;
                DE_we2_reg_out <= DE_we2_reg_in;
                DE_ALUorMem_out <= DE_ALUorMem_in;
                DE_ALUopd1 <= DE_Rsrc1_Val;
                DE_flags_en_out <= DE_flags_en_in;
                IF DE_isImm = '1' THEN
                    DE_ALUopd2_var := X"0000" & DE_Imm;
                ELSE
                    DE_ALUopd2_var := DE_Rsrc2_Val;
                END IF;
                IF DE_isInput_in = '1' THEN
                    DE_ALUopd2 <= DE_InPort_in;
                ELSE
                    DE_ALUopd2 <= DE_ALUopd2_var;
                END IF;

                DE_Rdst1_out <= DE_Rdst1_in;
                DE_Rdst2_out <= DE_Rdst2_in;
                DE_ALUsel_out <= DE_ALUsel_in;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE DE_Buffer_Arch;