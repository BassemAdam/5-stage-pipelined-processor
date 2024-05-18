LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Controller IS
    GENERIC (
        INST_WIDTH : INTEGER := 16
    );
    PORT (
        clk : IN STD_LOGIC;
        RES : IN STD_LOGIC;
        ctr_opCode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctr_Func : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        ctr_Correction : IN STD_LOGIC;
        ctr_POP_PC_in : IN STD_LOGIC;
        ctr_Push_PC_in : IN STD_LOGIC;
        ctr_Push_CCR_in : IN STD_LOGIC;

        ctr_POP_PC_out : OUT STD_LOGIC;
        ctr_hasImm : OUT STD_LOGIC;
        ctr_ALUsel : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        ctr_flags_en : OUT STD_LOGIC_VECTOR(0 TO 3);
        ctr_we1_reg : OUT STD_LOGIC;
        ctr_we2_reg : OUT STD_LOGIC;
        ctr_MemW : OUT STD_LOGIC;
        ctr_MemR : OUT STD_LOGIC;
        ctr_Push : OUT STD_LOGIC;
        ctr_Pop : OUT STD_LOGIC;
        ctr_Free : OUT STD_LOGIC;
        ctr_Protect : OUT STD_LOGIC;
        ctr_ALUorMem : OUT STD_LOGIC;
        ctr_isInput : OUT STD_LOGIC;
        ctr_src1_use : OUT STD_LOGIC;
        ctr_src2_use : OUT STD_LOGIC;
        ctr_STD_use : OUT STD_LOGIC;
        ctr_OUTport_en : OUT STD_LOGIC;
        ctr_JMP_DEC : OUT STD_LOGIC;
        ctr_JMP_EXE : OUT STD_LOGIC;
        ctr_Flush_FD : OUT STD_LOGIC;
        ctr_Flush_DE : OUT STD_LOGIC;
        ctr_Predictor : OUT STD_LOGIC;
        ctr_Push_PC_out : OUT STD_LOGIC;
        ctr_Push_CCR_out : OUT STD_LOGIC;
        ctr_POP_CCR : OUT STD_LOGIC;
        ctr_INT : OUT STD_LOGIC
        -- Passing through should be none its not a buffer
    );
END ENTITY Controller;

ARCHITECTURE ControllerArch3 OF Controller IS

BEGIN
    PROCESS (ctr_opCode, ctr_Func, RES, ctr_Correction, ctr_POP_PC_in, ctr_Push_PC_in, ctr_Push_PC_in)
        VARIABLE ctr_INT_var : STD_LOGIC := '0';
        VARIABLE ctr_RTI_var : INTEGER := 0;
        VARIABLE ctr_inRET_var : STD_LOGIC := '0';
        VARIABLE ctr_next_inRET_var : STD_LOGIC := '0';
        VARIABLE ctr_Predictor_var : STD_LOGIC := '1';

        VARIABLE ctr_hasImm_var : STD_LOGIC := '0';
        VARIABLE ctr_ALUsel_var : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
        VARIABLE ctr_flags_en_var : STD_LOGIC_VECTOR(0 TO 3) := (OTHERS => '0');
        VARIABLE ctr_we1_reg_var : STD_LOGIC := '0';
        VARIABLE ctr_we2_reg_var : STD_LOGIC := '0';
        VARIABLE ctr_we_mem_var : STD_LOGIC := '0';
        VARIABLE ctr_ALUorMem_var : STD_LOGIC := '0';
        VARIABLE ctr_isInput_var : STD_LOGIC := '0';
        VARIABLE ctr_OUTport_en_var : STD_LOGIC := '0';

        VARIABLE ctr_MemW_var : STD_LOGIC := '0';
        VARIABLE ctr_MemR_var : STD_LOGIC := '0';
        VARIABLE ctr_Push_var : STD_LOGIC := '0';
        VARIABLE ctr_Pop_var : STD_LOGIC := '0';
        VARIABLE ctr_Free_var : STD_LOGIC := '0';
        VARIABLE ctr_Protect_var : STD_LOGIC := '0';
        VARIABLE ctr_JMP_DEC_var : STD_LOGIC := '0';
        VARIABLE ctr_JMP_EXE_var : STD_LOGIC := '0';
        VARIABLE ctr_Flush_FD_var : STD_LOGIC := '0';
        VARIABLE ctr_Flush_DE_var : STD_LOGIC := '0';
        VARIABLE ctr_POP_PC_out_var : STD_LOGIC := '0';
        VARIABLE ctr_Push_PC_out_var : STD_LOGIC := '0';
        VARIABLE ctr_Push_CCR_out_var : STD_LOGIC := '0';
        VARIABLE ctr_POP_CCR_var : STD_LOGIC := '0';
        VARIABLE ctr_src1_use_var : STD_LOGIC := '0';
        VARIABLE ctr_src2_use_var : STD_LOGIC := '0';
        VARIABLE ctr_STD_use_var : STD_LOGIC := '0';
    BEGIN
        ctr_hasImm_var := '0';
        ctr_ALUsel_var := (OTHERS => '0');
        ctr_flags_en_var := (OTHERS => '0');
        ctr_we1_reg_var := '0';
        ctr_we2_reg_var := '0';
        ctr_we_mem_var := '0';
        ctr_ALUorMem_var := '0';
        ctr_isInput_var := '0';
        ctr_OUTport_en_var := '0';
        ctr_MemW_var := '0';
        ctr_MemR_var := '0';
        ctr_Push_var := '0';
        ctr_Pop_var := '0';
        ctr_Free_var := '0';
        ctr_Protect_var := '0';
        ctr_src1_use_var := '0';
        ctr_src2_use_var := '0';
        ctr_STD_use_var := '0';

        ctr_JMP_DEC_var := '0';
        ctr_JMP_EXE_var := '0';
        ctr_Flush_FD_var := '0';
        ctr_Flush_DE_var := '0';
        ctr_POP_PC_out_var := '0';
        ctr_Push_PC_out_var := '0';
        ctr_Push_CCR_out_var := '0';
        ctr_POP_CCR_var := '0';
        ctr_INT_var := '0';

        IF RES = '0' AND ctr_inRET_var = '1' THEN
            ctr_Flush_FD_var := '1';
            ctr_inRET_var := ctr_next_inRET_var;
            IF ctr_POP_PC_in = '0' THEN
                ctr_next_inRET_var := '0';
            END IF;
            ELSIF RES = '0' THEN
            IF ctr_Correction = '1' THEN
                ctr_Predictor_var := NOT ctr_Predictor_var;
                ctr_JMP_EXE_var := '1';
                ctr_Flush_FD_var := '1';
                ctr_Flush_DE_var := '1';
            END IF;

            IF ctr_opCode = "000" THEN -- NOP
                -- ctr_flags_en_var := (OTHERS => '0');
                -- ctr_we1_reg_var := '0';
                -- ctr_we2_reg_var := '0';
                -- ctr_we_mem_var := '0';
                -- ctr_hasImm_var := '0';
                -- ctr_OUTport_en_var := '0';
            END IF;

            IF ctr_opCode = "001" THEN -- ALU 
                ctr_ALUsel_var := ctr_Func;
                ctr_we1_reg_var := '1';
                ctr_src1_use_var := '1';
                IF ctr_Func = "0000" THEN -- NOT
                    ctr_flags_en_var := "1100";
                END IF;
                IF ctr_Func = "0001" THEN -- NEG
                    ctr_flags_en_var := "1100";
                END IF;
                IF ctr_Func = "0010" THEN -- INC
                    ctr_flags_en_var := "1111";
                END IF;
                IF ctr_Func = "0011" THEN -- DEC
                    ctr_flags_en_var := "1111";
                END IF;
                IF ctr_Func = "0100" THEN -- MOV
                    ctr_flags_en_var := "0000";
                END IF;
                IF ctr_Func = "0101" THEN -- MOV
                    ctr_flags_en_var := "0000";
                    ctr_src2_use_var := '1';
                END IF;
                IF ctr_Func = "0110" THEN -- ADD
                    ctr_flags_en_var := "1111";
                    ctr_src2_use_var := '1';
                END IF;
                IF ctr_Func = "0111" THEN -- SUB
                    ctr_flags_en_var := "1111";
                    ctr_src2_use_var := '1';
                END IF;
                IF ctr_Func = "1000" THEN -- AND
                    ctr_flags_en_var := "1100";
                    ctr_src2_use_var := '1';
                END IF;
                IF ctr_Func = "1001" THEN -- OR
                    ctr_flags_en_var := "1100";
                    ctr_src2_use_var := '1';
                END IF;
                IF ctr_Func = "1010" THEN -- XOR
                    ctr_flags_en_var := "1100";
                    ctr_src2_use_var := '1';
                END IF;
                IF ctr_Func = "1011" THEN -- CMP
                    ctr_we1_reg_var := '0';
                    ctr_flags_en_var := "1100";
                    ctr_src2_use_var := '1';
                END IF;
                IF ctr_Func = "1111" THEN -- SWAP
                    ctr_we2_reg_var := '1';
                    ctr_src1_use_var := '1';
                END IF;
            END IF;
            ----------------------------Imm-------------------------------------------
            IF ctr_opCode = "010" THEN -- Immediate 
                ctr_hasImm_var := '1';
                ctr_src1_use_var := '1';
                IF ctr_Func = "0011" THEN -- STD
                    ctr_MemW_var := '1';
                    ctr_ALUsel_var := "0110";
                    ctr_STD_use_var := '1';
                END IF;
                IF ctr_Func = "1100" THEN -- LDD
                    ctr_ALUorMem_var := '1';
                    ctr_MemR_var := '1';
                    ctr_we1_reg_var := '1';
                    ctr_ALUsel_var := "0110";
                END IF;
                IF ctr_Func = "0010" THEN -- LDM
                    ctr_ALUsel_var := "0101";
                    ctr_we1_reg_var := '1';
                    ctr_src1_use_var := '0';
                END IF;
                IF ctr_Func = "0000" THEN -- ADDI
                    ctr_ALUsel_var := "0110";
                    ctr_flags_en_var := "1111";
                    ctr_we1_reg_var := '1';
                END IF;
                IF ctr_Func = "0001" THEN -- SUBI
                    ctr_ALUsel_var := "0111";
                    ctr_flags_en_var := "1111";
                    ctr_we1_reg_var := '1';
                END IF;
            END IF;

            IF ctr_opCode = "011" THEN -- Data Operations 
                IF ctr_Func = "0000" THEN
                END IF;
                IF ctr_Func = "1001" THEN -- Input
                    ctr_isInput_var := '1';
                    ctr_ALUsel_var := "0101";
                    ctr_flags_en_var := "0000";
                    ctr_we1_reg_var := '1';
                END IF;
                IF ctr_Func = "0001" THEN -- Output
                    ctr_OUTport_en_var := '1';
                    ctr_ALUsel_var := "0100";
                    ctr_src1_use_var := '1';
                END IF;
                --Memory Operations
                IF ctr_Func = "0010" THEN --PUSH
                    ctr_Push_var := '1';
                    ctr_ALUsel_var := "0100";
                    ctr_src1_use_var := '1';
                END IF;
                IF ctr_Func = "1010" THEN --POP
                    ctr_Pop_var := '1';
                    ctr_we1_reg_var := '1';
                    ctr_AluOrMem_var := '1';
                END IF;
            END IF;

            IF ctr_opCode = "100" THEN -- Conditional Jump
                IF ctr_Func = "0000" THEN
                    ctr_src1_use_var := '1';
                    IF ctr_Predictor_var = '1' THEN
                        ctr_JMP_DEC_var := '1';
                        ctr_Flush_FD_var := '1';
                        ELSE
                    END IF;
                END IF;
            END IF;

            IF ctr_opCode = "101" THEN -- Unconditional Jump
                IF ctr_Func = "0000" THEN
                    ctr_src1_use_var := '1';
                    ctr_JMP_DEC_var := '1';
                    ctr_Flush_FD_var := '1';

                ELSIF ctr_Func = "0100" THEN
                    ctr_Push_var := '1';
                    ctr_ALUsel_var := "0100";
                    ctr_JMP_DEC_var := '1';
                    ctr_Flush_FD_var := '1';

                ELSIF ctr_Func = "1000" THEN
                    ctr_inRET_var := '1';
                    ctr_next_inRET_var := '1';
                    ctr_Flush_FD_var := '1';
                    ctr_POP_PC_out_var := '1';
                    ctr_Pop_var := '1';
                    ctr_AluOrMem_var := '1';

                ELSIF ctr_Func = "1100" THEN
                    ctr_POP_CCR_var := '1';
                    ctr_Pop_var := '1';
                    ctr_AluOrMem_var := '1';

                ELSIF ctr_Func = "1110" THEN
                    ctr_inRET_var := '1';
                    ctr_next_inRET_var := '1';
                    ctr_Flush_FD_var := '1';
                    ctr_POP_PC_out_var := '1';
                    ctr_Pop_var := '1';
                    ctr_AluOrMem_var := '1';
                END IF;
            END IF;

            IF ctr_opCode = "110" THEN -- Memory Security
                IF ctr_Func = "0000" THEN -- Protect
                    ctr_Protect_var := '1';
                    ctr_src1_use_var := '1';
                    ctr_ALUsel_var := "0100";
                END IF;
                IF ctr_Func = "1000" THEN -- Free
                    ctr_Free_var := '1';
                    ctr_src1_use_var := '1';
                    ctr_ALUsel_var := "0100";
                END IF;
            END IF;

            IF ctr_opCode = "111" THEN -- Input Signals
                IF ctr_Func = "1000" THEN
                    ctr_Push_var := '1';
                    ctr_ALUsel_var := "0100";
                    ctr_Push_PC_out_var := '1';
                ELSIF ctr_Func = "1100" THEN
                    ctr_Push_var := '1';
                    ctr_ALUsel_var := "0100";
                    ctr_Push_CCR_out_var := '1';
                    ctr_Flush_FD_var := '1';
                    ctr_INT_var := '1';
                END IF;
            END IF;
            ELSE
            -- ctr_hasImm <= '0';
            -- ctr_ALUsel <= (OTHERS => '0');
            -- ctr_flags_en <= (OTHERS => '0');
            -- ctr_we1_reg <= '0';
            -- ctr_we2_reg <= '0';
            -- ctr_we_mem <= '0';
            -- ctr_ALUorMem <= '0';
        END IF;
        ctr_hasImm <= ctr_hasImm_var;
        ctr_ALUsel <= ctr_ALUsel_var;
        ctr_flags_en <= ctr_flags_en_var;
        ctr_we1_reg <= ctr_we1_reg_var;
        ctr_we2_reg <= ctr_we2_reg_var;
        ctr_ALUorMem <= ctr_ALUorMem_var;
        ctr_isInput <= ctr_isInput_var;
        ctr_OUTport_en <= ctr_OUTport_en_var;
        ctr_MemW <= ctr_MemW_var;
        ctr_MemR <= ctr_MemR_var;
        ctr_Push <= ctr_Push_var;
        ctr_Pop <= ctr_Pop_var;
        ctr_Free <= ctr_Free_var;
        ctr_Protect <= ctr_Protect_var;
        ctr_JMP_DEC <= ctr_JMP_DEC_var;
        ctr_JMP_EXE <= ctr_JMP_EXE_var;
        ctr_Flush_FD <= ctr_Flush_FD_var;
        ctr_Flush_DE <= ctr_Flush_DE_var;
        ctr_Predictor <= ctr_Predictor_var;
        ctr_POP_PC_out <= ctr_POP_PC_out_var;
        ctr_Push_PC_out <= ctr_Push_PC_out_var;
        ctr_Push_CCR_out <= ctr_Push_CCR_out_var;
        ctr_src1_use <= ctr_src1_use_var;
        ctr_src2_use <= ctr_src2_use_var;
        ctr_STD_use <= ctr_STD_use_var;
        ctr_INT <= ctr_INT_var;
        ctr_POP_CCR <= ctr_POP_CCR_var;
    END PROCESS;
END ARCHITECTURE ControllerArch3;

-- architecture ControllerArch2 of Controller is

-- begin
--     process (ctr_opCode, ctr_Func, RES)
--     begin
--         if RES = '1' then
--             ctr_hasImm   <= '0';
--             ctr_we1_reg  <= '0';
--             ctr_we2_reg  <= '0';
--             ctr_we_mem   <= '0';
--             ctr_ALUorMem <= '0';

--         else
--             case ctr_opCode is
--                 when "010" =>
--                     ctr_hasImm <= '1';
--                 when others =>
--                     ctr_hasImm <= '0';
--             end case;

--             case ctr_opCode & ctr_Func is
--                 when "0011011" | "0100011" | "0110001" | "011001-" | "011101-" | "100----" | "101----" | "110----" | "111----" |"0000000" =>
--                     ctr_we1_reg <= '0';
--                 when others =>
--                     ctr_we1_reg <= '1';
--             end case;
--             case ctr_opCode & ctr_Func is
--                 when "0011111" =>
--                     ctr_we2_reg <= '1';
--                 when others =>
--                     ctr_we2_reg <= '0';
--             end case;
--             case ctr_opCode is
--                 when "010" =>
--                     ctr_we_mem <= '1';
--                 when others =>
--                     ctr_we_mem <= '0';
--             end case;

--             case ctr_opCode & ctr_Func is
--                 when "0101100" => -- LDD
--                     ctr_ALUorMem <= '1';
--                 when others =>
--                     ctr_ALUorMem <= '0';
--             end case;

--             --I HAVE NO IDEA HOW TO SET THIS (ALI)
--             case ctr_opCode & ctr_Func is
--                 when "0010010" | "0010011" | "0010110" | "0010111" | "0100000" | "0100001" =>
--                     ctr_flags_en <= "1111";
--                 when "0010000" | "0010001" | "0011000" | "0011001" | "0011010" | "0011011" =>
--                     ctr_flags_en <= "1100";
--                 when others =>
--                     ctr_flags_en <= "0000";
--             end case;

--             case ctr_opCode is
--                 when "001" =>           -- ALU operation
--                     ctr_ALUsel <= ctr_Func; -- same as function num
--                 when "010" =>           -- when Immediate operation
--                     case ctr_Func is
--                         when "0000" | "0011" | "1100" => -- ADDI or LDD or STD
--                             ctr_ALUsel <= "1000";            -- additon
--                         when "0001" =>                   -- SUBI
--                             ctr_ALUsel <= "0111";            -- subtraction
--                         when "0010" =>                   -- LDM
--                             ctr_ALUsel <= "0101";            -- mov B
--                         when others =>
--                             ctr_ALUsel <= "0100";-- move
--                     end case;
--                 when others =>
--                     ctr_ALUsel <= "0100"; -- move
--             end case;

--         end if;

--     end process;
-- end architecture ControllerArch2;
