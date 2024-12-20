LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY DE_Buffer IS
    PORT (
        clk, RES, WE, DE_flush_PopUse, FLUSH : IN STD_LOGIC;
        DE_Flush_DE : IN STD_LOGIC;
        DE_Rsrc1_Val : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DE_Rsrc2_Val : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DE_Imm : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        DE_isImm : IN STD_LOGIC;

        DE_Zflag : IN STD_LOGIC;
        DE_OpCode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        DE_OpCode_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        DE_Predictor : IN STD_LOGIC;
        DE_PC_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DE_current_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        DE_ALUopd1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        DE_ALUopd2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        DE_PC_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        DE_Correction : OUT STD_LOGIC;
        DE_PC_FWD : OUT STD_LOGIC;
        -- Passing through
        DE_InPort_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DE_InPort_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        DE_zReset_in : IN STD_LOGIC;
        DE_zReset_out : OUT STD_LOGIC;

        DE_POP_PC_in : IN STD_LOGIC;
        DE_POP_PC_out : OUT STD_LOGIC;
        DE_POP_CCR_in : IN STD_LOGIC;
        DE_POP_CCR_out : OUT STD_LOGIC;
        DE_Push_CCR_in : IN STD_LOGIC;
        DE_Push_CCR_out : OUT STD_LOGIC;
        DE_Push_PC_in : IN STD_LOGIC;
        DE_Push_PC_out : OUT STD_LOGIC;
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
        --MEMORY OPERATIONS SIGNALS
        DE_MemW_in : IN STD_LOGIC;
        DE_MemW_out : OUT STD_LOGIC;
        DE_MemR_in : IN STD_LOGIC;
        DE_MemR_out : OUT STD_LOGIC;
        DE_Push_in : IN STD_LOGIC;
        DE_Push_out : OUT STD_LOGIC;
        DE_Pop_in : IN STD_LOGIC;
        DE_Pop_out : OUT STD_LOGIC;
        DE_Protect_in : IN STD_LOGIC;
        DE_Protect_out : OUT STD_LOGIC;
        DE_Free_in : IN STD_LOGIC;
        DE_Free_out : OUT STD_LOGIC; -- for std 
        --END MEMORY OPERATIONS SIGNALS
        DE_ALUsel_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        --SRCS PROPAGATION
        DE_STD_VALUE : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        DE_Rsrc1_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        DE_Rsrc2_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        DE_STD_address : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        DE_ALUopd1_address : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        DE_ALUopd2_address : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

        DE_src1_use_in : IN STD_LOGIC;
        DE_src1_use_out : OUT STD_LOGIC;
        DE_src2_use_in : IN STD_LOGIC;
        DE_src2_use_out : OUT STD_LOGIC;
        DE_STD_use_in : IN STD_LOGIC;
        DE_STD_use_out : OUT STD_LOGIC
    );
END ENTITY DE_Buffer;

ARCHITECTURE DE_Buffer_Arch OF DE_Buffer IS
    SIGNAL DE_Predictor_out : STD_LOGIC;
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
            DE_we2_reg_out <= '0';
            DE_InPort_out <= (OTHERS => '0');
            DE_isInput_out <= '0';
            DE_MemW_out <= '0';
            DE_MemR_out <= '0';
            DE_Push_out <= '0';
            DE_Pop_out <= '0';
            DE_POP_PC_out <= '0';
            DE_Protect_out <= '0';
            DE_Free_out <= '0';
            DE_STD_VALUE <= (OTHERS => '0');
            DE_Correction <= '0';
            DE_Predictor_out <= '0';
            DE_PC_out <= (OTHERS => '0');
            DE_Push_CCR_out <= '0';
            DE_Push_PC_out <= '0';
            DE_src1_use_out <= '0';
            DE_src2_use_out <= '0';
            DE_STD_use_out <= '0';
            DE_STD_address <= (OTHERS => '0');
            DE_ALUopd1_address <= (OTHERS => '0');
            DE_ALUopd2_address <= (OTHERS => '0');
            DE_POP_CCR_out <= '0';
            DE_zReset_out <= '0';
            DE_PC_FWD <= '0';
            DE_OpCode_out <= "000";

        ELSIF falling_edge(clk) AND DE_Flush_DE = '1' THEN
            DE_we1_reg_out <= '0';
            DE_we2_reg_out <= '0';
            DE_flags_en_out <= (OTHERS => '0');
            DE_OUTport_en_out <= '0';
            DE_Correction <= '0';
            DE_POP_PC_out <= '0';
            DE_POP_CCR_out <= '0';
            DE_zReset_out <= '0';
        ELSIF falling_edge(clk) THEN

            IF WE = '1' AND DE_flush_PopUse = '0' THEN

                DE_OUTport_en_out <= DE_OUTport_en_in;
                DE_we1_reg_out <= DE_we1_reg_in;
                DE_we2_reg_out <= DE_we2_reg_in;
                DE_ALUorMem_out <= DE_ALUorMem_in;
                DE_zReset_out <= DE_zReset_in;

                DE_flags_en_out <= DE_flags_en_in;
                IF DE_isImm = '1' THEN
                    DE_ALUopd2_var := X"0000" & DE_Imm;
                ELSE

                    DE_ALUopd2_var := DE_Rsrc2_Val;
                    DE_ALUopd2_address <= DE_Rsrc2_address;
                END IF;

                IF DE_Push_PC_in = '1' THEN
                    DE_ALUopd1 <= DE_Rsrc2_Val;
                    DE_STD_VALUE <= DE_current_PC;
                ELSIF DE_OpCode = "101" THEN
                    DE_ALUopd1 <= DE_PC_in;
                    DE_STD_VALUE <= (OTHERS => '0');
                    DE_ALUopd1_address <= DE_Rsrc1_address;
                ELSIF DE_MemW_in = '1' AND DE_isImm = '1' THEN
                    DE_ALUopd1 <= DE_Rsrc2_Val;
                    DE_ALUopd2_var := X"0000" & DE_Imm;
                    DE_STD_VALUE <= DE_Rsrc1_Val;
                    DE_STD_address <= DE_Rsrc1_address;
                    DE_ALUopd1_address <= DE_Rsrc2_address;
                ELSE
                    DE_ALUopd1 <= DE_Rsrc1_Val;
                    DE_ALUopd1_address <= DE_Rsrc1_address;
                    DE_STD_Address <= (OTHERS => '0');
                    DE_STD_VALUE <= (OTHERS => '0');
                END IF;
                IF DE_isInput_in = '1' THEN
                    DE_ALUopd2 <= DE_InPort_in;
                ELSE
                    DE_ALUopd2 <= DE_ALUopd2_var;
                END IF;

                DE_Rdst1_out <= DE_Rdst1_in;
                DE_Rdst2_out <= DE_Rdst2_in;
                DE_ALUsel_out <= DE_ALUsel_in;
                --Memory Operations
                DE_MemW_out <= DE_MemW_in;
                DE_MemR_out <= DE_MemR_in;
                DE_Push_out <= DE_Push_in;
                DE_Pop_out <= DE_Pop_in;
                DE_Protect_out <= DE_Protect_in;
                DE_Free_out <= DE_Free_in;
                --End Memory Operations
                DE_src1_use_out <= DE_src1_use_in;
                DE_src2_use_out <= DE_src2_use_in;
                DE_STD_use_out <= DE_STD_use_in;
                IF DE_OpCode = "101" THEN
                    DE_PC_out <= DE_PC_in;
                ELSIF DE_Predictor = '1' THEN
                    DE_PC_out <= DE_PC_in;
                ELSE
                    DE_PC_out <= DE_Rsrc1_Val;
                END IF;
                IF DE_OpCode = "101" OR DE_OpCode = "100" THEN
                    DE_ALUopd1_address <= DE_Rsrc1_address;
                END IF;
                IF DE_OpCode = "101" THEN
                    DE_PC_FWD <= '1';
                ELSIF DE_OpCode = "100" AND DE_Predictor = '1' THEN
                    DE_PC_FWD <= '1';
                ELSE
                    DE_PC_FWD <= '0';
                END IF;

                IF DE_OpCode = "100" THEN
                    DE_Correction <= DE_Predictor XOR DE_Zflag;
                ELSE
                    DE_Correction <= '0';
                END IF;
                DE_POP_PC_out <= DE_POP_PC_in;
                DE_POP_CCR_out <= DE_POP_CCR_in;
                DE_Push_CCR_out <= DE_Push_CCR_in;
                DE_Push_PC_out <= DE_Push_PC_in;
                DE_OpCode_out <= DE_OpCode;
                DE_Predictor_out <= DE_Predictor;
            ELSE
                DE_we1_reg_out <= '0';
                DE_ALUorMem_out <= '0';
                DE_flags_en_out <= (OTHERS => '0');
                DE_ALUopd1 <= (OTHERS => '0');
                DE_ALUopd2 <= (OTHERS => '0');
                DE_Rdst1_out <= (OTHERS => '0');
                DE_Rdst2_out <= (OTHERS => '0');
                DE_ALUsel_out <= (OTHERS => '0');
                DE_OUTport_en_out <= '0';
                DE_we2_reg_out <= '0';
                DE_InPort_out <= (OTHERS => '0');
                DE_isInput_out <= '0';
                DE_MemW_out <= '0';
                DE_MemR_out <= '0';
                DE_Push_out <= '0';
                DE_Pop_out <= '0';
                DE_Protect_out <= '0';
                DE_Free_out <= '0';
                DE_STD_VALUE <= (OTHERS => '0');
                DE_src1_use_out <= '0';
                DE_src2_use_out <= '0';
                DE_STD_use_out <= '0';
                DE_STD_address <= (OTHERS => '0');
                DE_ALUopd1_address <= (OTHERS => '0');
                DE_ALUopd2_address <= (OTHERS => '0');
                DE_POP_CCR_out <= '0';
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE DE_Buffer_Arch;