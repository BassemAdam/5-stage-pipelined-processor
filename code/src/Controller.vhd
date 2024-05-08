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

        ctr_hasImm : OUT STD_LOGIC;
        ctr_ALUsel : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        ctr_flags_en : OUT STD_LOGIC_VECTOR(0 TO 3);
        ctr_we1_reg : OUT STD_LOGIC;
        ctr_we2_reg : OUT STD_LOGIC;
        ctr_we_mem : OUT STD_LOGIC;
        ctr_ALUorMem : OUT STD_LOGIC;
        ctr_isInput : OUT STD_LOGIC;
        ctr_OUTport_en : OUT STD_LOGIC

        -- Passing through should be none its not a buffer
    );
END ENTITY Controller;

ARCHITECTURE ControllerArch3 OF Controller IS

BEGIN
    PROCESS (ctr_opCode, ctr_Func, RES)
    BEGIN

        -- ctr_hasImm   <= '0';
        -- ctr_ALUsel   <= (others => '0');
        -- ctr_flags_en <= (others => '0');
        -- ctr_we1_reg  <= '0';
        -- ctr_we2_reg  <= '0';
        -- ctr_we_mem   <= '0';
        -- ctr_ALUorMem <= '0';
        -- ctr_OUTport_en <= '0';

        IF RES = '0' THEN
            IF ctr_opCode = "000" THEN -- NOP
                ctr_flags_en <= (OTHERS => '0');
                ctr_we1_reg <= '0';
                ctr_we2_reg <= '0';
                ctr_we_mem <= '0';
                ctr_hasImm <= '0';
                ctr_OUTport_en <= '0';
            END IF;

            IF ctr_opCode = "001" THEN -- ALU 
                ctr_ALUsel <= ctr_Func;
                ctr_we1_reg <= '1';
                ctr_ALUorMem <= '0';

                IF ctr_Func = "0000" THEN -- NOT
                    ctr_flags_en <= "1100";
                END IF;
                IF ctr_Func = "0001" THEN -- NEG
                    ctr_flags_en <= "1100";
                END IF;
                IF ctr_Func = "0010" THEN -- INC
                    ctr_flags_en <= "1111";
                END IF;
                IF ctr_Func = "0011" THEN -- DEC
                    ctr_flags_en <= "1111";
                END IF;
                IF ctr_Func = "0100" THEN -- MOV
                    ctr_flags_en <= "0000";
                END IF;
                IF ctr_Func = "0101" THEN -- MOV
                    ctr_flags_en <= "0000";
                END IF;
                IF ctr_Func = "0110" THEN -- ADD
                    ctr_flags_en <= "1111";
                END IF;
                IF ctr_Func = "0111" THEN -- SUB
                    ctr_flags_en <= "1111";
                END IF;
                IF ctr_Func = "1000" THEN -- AND
                    ctr_flags_en <= "1100";
                END IF;
                IF ctr_Func = "1001" THEN -- OR
                    ctr_flags_en <= "1100";
                END IF;
                IF ctr_Func = "1010" THEN -- XOR
                    ctr_flags_en <= "1100";
                END IF;
                IF ctr_Func = "1011" THEN -- CMP
                    ctr_we1_reg <= '0';
                    ctr_flags_en <= "1100";
                END IF;
            END IF;
            ----------------------------Imm-------------------------------------------
            IF ctr_opCode = "010" THEN -- Immediate 
                ctr_hasImm <= '1';
                IF ctr_Func = "0011" THEN -- STD
                    ctr_we_mem <= '1';
                    ctr_ALUsel <= "0110";
                END IF;
                IF ctr_Func = "1100" THEN -- LDD
                    ctr_ALUorMem <= '1';
                    ctr_ALUsel <= "0110";
                END IF;
                IF ctr_Func = "0010" THEN -- LDM
                    ctr_ALUsel <= "0101";
                    ctr_we1_reg <= '1';
                END IF;
                IF ctr_Func = "0000" THEN -- ADDI
                    ctr_ALUsel <= "0110";
                    ctr_flags_en <= "1111";
                    ctr_we1_reg <= '1';
                    ctr_ALUorMem <= '0';
                END IF;
                IF ctr_Func = "0001" THEN -- SUBI
                    ctr_ALUsel <= "0111";
                    ctr_flags_en <= "1111";
                    ctr_we1_reg <= '1';
                    ctr_ALUorMem <= '0';
                END IF;
            END IF;

            IF ctr_opCode = "011" THEN -- Data Operations 
                IF ctr_Func = "0000" THEN
                END IF;
                IF ctr_Func = "1001" THEN -- Input
                    ctr_isInput <= '1';
                    ctr_hasImm <= '0';
                    ctr_ALUsel <= "0101";
                    ctr_flags_en <= "0000";
                    ctr_we1_reg <= '1';
                    ctr_we2_reg <= '0';
                    ctr_we_mem <= '0';
                    ctr_ALUorMem <= '0';
                END IF;
                IF ctr_Func = "0001" THEN -- Output
                    ctr_OUTport_en <= '1';
                    ctr_hasImm <= '0';
                    ctr_ALUsel <= "0100";
                    ctr_flags_en <= "0000";
                    ctr_we1_reg <= '0';
                    ctr_we2_reg <= '0';
                    ctr_we_mem <= '0';
                    ctr_ALUorMem <= '0';
                END IF;
            END IF;

            IF ctr_opCode = "100" THEN -- Conditional Jump
                IF ctr_Func = "0000" THEN
                END IF;
            END IF;

            IF ctr_opCode = "101" THEN -- Unconditional Jump
                IF ctr_Func = "0000" THEN
                END IF;
            END IF;

            IF ctr_opCode = "110" THEN -- Memory Security
                IF ctr_Func = "0000" THEN
                END IF;
            END IF;

            IF ctr_opCode = "111" THEN -- Input Signals
                IF ctr_Func = "0000" THEN
                END IF;
            END IF;
        ELSE
            ctr_hasImm <= '0';
            ctr_ALUsel <= (OTHERS => '0');
            ctr_flags_en <= (OTHERS => '0');
            ctr_we1_reg <= '0';
            ctr_we2_reg <= '0';
            ctr_we_mem <= '0';
            ctr_ALUorMem <= '0';
        END IF;
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