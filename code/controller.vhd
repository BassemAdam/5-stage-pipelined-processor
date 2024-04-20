LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY controller IS
    GENERIC (
        INST_WIDTH : INTEGER := 16
    );
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        ctr_opCode_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctr_Rdest_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctr_Rsrc1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctr_Rsrc2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctr_fnNum_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        ctr_opCode_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctr_fnNum_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        ctr_Rsrc1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctr_Rsrc2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctr_Rdest_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        hasImm : OUT STD_LOGIC;
        writeEnable_reg : OUT STD_LOGIC;
        writeEnable_mem : OUT STD_LOGIC;
        ALUorMem : OUT STD_LOGIC;
        --predictor: OUT STD_LOGIC;
        --protect: OUT STD_LOGIC;
        --free: OUT STD_LOGIC;
        --isJZ : OUT STD_LOGIC;
        --isJMP : OUT STD_LOGIC;
        --flushIF_ID : OUT STD_LOGIC;
        --flushID_EX : OUT STD_LOGIC;
        --flushEX_MEM : OUT STD_LOGIC;
        --flushMEM_WB : OUT STD_LOGIC;
        stall : OUT STD_LOGIC;
        int : OUT STD_LOGIC;
        isSwap : OUT STD_LOGIC;
        modifiesFlags : OUT STD_LOGIC_VECTOR(0 TO 3);
        PCIncType : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        --CallorInt : OUT STD_LOGIC;

        --push : OUT STD_LOGIC;
        --pop : OUT STD_LOGIC;

    );
END ENTITY controller;

-- ARCHITECTURE controllerArch OF controller IS

-- BEGIN
--     -- reset
--     controller_opCode_out <= (OTHERS => '0') WHEN rst = '1' ELSE
--         controller_opCode_in;

--     IF rst = '1' THEN
--         hasImm <= (OTHERS => '0');
--         writeEnable_reg <= '0';
--         writeEnable_mem <= '0';
--         ALUorMem <= '0';
--         -- predictor <= '0';
--         -- protect <= '0';
--         -- free <= '0';
--         -- isJZ <= '0';
--         -- isJMP <= '0';
--         -- flushIF_ID <= '0';
--         -- flushID_EX <= '0';
--         -- flushEX_MEM <= '0';
--         -- flushMEM_WB <= '0';
--         stall <= '0';
--         int <= '0';
--         isSwap <= '0';
--         PCIncType <= (OTHERS => '0');
--         -- CallorInt <= '0';
--         -- push <= '0';
--         -- pop <= '0';

--     ELSE
--         IF controller_opCode_in = "000" THEN -- ALU
--             hasImm <= '0';
--             writeEnable_reg <= '0';
--             writeEnable_mem <= '0';
--             ALUorMem <= '0';
--             m
--             -- predictor <= '0';
--             -- protect <= '0';
--             -- free <= '0';
--             -- isJZ <= '0';
--             -- isJMP <= '0';
--             -- flushIF_ID <= '0';
--             -- flushID_EX <= '0';
--             -- flushEX_MEM <= '0';
--             -- flushMEM_WB <= '0';
--             stall <= '0';
--             int <= '0';
--             isSwap <= '0';
--             PCIncType <= "00";
--             -- CallorInt <= '0';
--             -- push <= '0';
--             -- pop <= '0';
--         ELSIF controller_opCode_in = "001" THEN --ALU instructions
--             hasImm <= '0';
--             writeEnable_reg <= '1';
--             writeEnable_mem <= '0';
--             ALUorMem <= '0';
--             -- predictor <= '0';
--             -- protect <= '0';
--             -- free <= '0';
--             -- isJZ <= '0';
--             -- isJMP <= '0';
--             -- flushIF_ID <= '0';
--             -- flushID_EX <= '0';
--             -- flushEX_MEM <= '0';
--             -- flushMEM_WB <= '0';
--             stall <= '0';
--             int <= '0';
--             isSwap <= '0';
--             PCIncType <= "00";
--             -- CallorInt <= '0';
--             -- push <= '0';
--             -- pop <= '0';
--             WITH ctr_fnNum_in SELECT modifiesFlags <=
--                 "1111" WHEN "0010" | "0011" | "0110" | "0111",
--                 "1100" WHEN "0000" | "0001" | "1000" | "1001" | "1010" | "1011",
--                 "0000" WHEN OTHERS;

--         ELSIF controller_opCode_in = "010" THEN -- Immediate
--             hasImm <= '0';
--             writeEnable_reg <= '1';
--             writeEnable_mem <= '0';
--             ALUorMem <= '0';
--             -- predictor <= '0';
--             -- protect <= '0';
--             -- free <= '0';
--             -- isJZ <= '0';
--             -- isJMP <= '0';
--             -- flushIF_ID <= '0';
--             -- flushID_EX <= '0';
--             -- flushEX_MEM <= '0';
--             -- flushMEM_WB <= '0';
--             stall <= '0';
--             int <= '0';
--             isSwap <= '0';
--             PCIncType <= "00";
--             -- CallorInt <= '0';
--             -- push <= '

--             WITH ctr_fnNum_in SELECT modifiesFlags <=
--                 "1111" WHEN "0000" | "0001",
--                 "0000" WHEN OTHERS;

--         END IF;
--     END IF;
-- END ARCHITECTURE controllerArch;
ARCHITECTURE controllerArch2 OF controller IS

BEGIN
    -- reset
    ctr_opCode_out <= (OTHERS => '0') WHEN rst = '1' ELSE
        ctr_opCode_in;
    PROCESS (ctr_opCode_in, ctr_fnNum_in, rst)
    BEGIN
        IF rst = '1' THEN
            hasImm <= '0';
            writeEnable_reg <= '0';
            writeEnable_mem <= '0';
            ALUorMem <= '0';
            -- predictor <= '0';
            -- protect <= '0';
            -- free <= '0';
            -- isJZ <= '0';
            -- isJMP <= '0';
            -- flushIF_ID <= '0';
            -- flushID_EX <= '0';
            -- flushEX_MEM <= '0';
            -- flushMEM_WB <= '0';
            stall <= '0';
            int <= '0';
            isSwap <= '0';
            PCIncType <= (OTHERS => '0');
            -- CallorInt <= '0';
            -- push <= '0';
            -- pop <= '0';
        ELSE
            CASE ctr_opCode_in IS
                WHEN "010" =>
                    hasImm <= '1';
                WHEN OTHERS =>
                    hasImm <= '0';
            END CASE;
            
            CASE ctr_opCode_in IS
                WHEN "000" =>
                    writeEnable_reg <= '0';
                WHEN OTHERS =>
                    writeEnable_reg <= '1';
            END CASE;

            CASE ctr_opCode_in IS
                WHEN "010" =>
                    writeEnable_mem <= '1';
                WHEN OTHERS =>
                    writeEnable_mem <= '0';
            END CASE;

            CASE ctr_opCode_in & ctr_fnNum_in IS
                WHEN "0101100" =>
                    ALUorMem <= '1';
                WHEN OTHERS =>
                    ALUorMem <= '0';
            END CASE;

            CASE ctr_opCode_in & ctr_fnNum_in IS
                WHEN "0100101" =>
                    stall <= '1';
                WHEN OTHERS =>
                    stall <= '0';
            END CASE;
            -- WITH ctr_opCode_in SELECT hasImm <=
            --     '1' WHEN "010",
            --     '0' WHEN OTHERS;

            -- WITH ctr_opCode_in SELECT writeEnable_reg <=
            --     '0' WHEN "000",
            --     '1' WHEN OTHERS;

            -- WITH ctr_opCode_in SELECT writeEnable_mem <=
            --     '1' WHEN "010",
            --     '0' WHEN OTHERS;

            -- WITH ctr_opCode_in & ctr_fnNum_in SELECT ALUorMem <=
            -- '1' WHEN "010110",
            -- '0' WHEN OTHERS;

            -- WITH ctr_opCode_in & ctr_fnNum_in SELECT stall <=
            -- '1' WHEN "0100101",
            -- '0' WHEN OTHERS;
            CASE ctr_opCode_in & ctr_fnNum_in(3) IS
                WHEN "1111" =>
                    int <= '1';
                WHEN OTHERS =>
                    int <= '0';
            END CASE;

            CASE ctr_opCode_in & ctr_fnNum_in IS
                WHEN "0010101" =>
                    isSwap <= '1';
                WHEN OTHERS =>
                    isSwap <= '0';
            END CASE;

            -- with ctr_opCode_in & ctr_fnNum_in select PCIncType <=,
            --I HAVE NO IDEA HOW TO SET THIS (ALI)
            CASE ctr_opCode_in & ctr_fnNum_in IS
                WHEN "0010010" | "0010011" | "0010110" | "0010111" | "0100000" | "0100001" =>
                    modifiesFlags <= "1111";
                WHEN "0010000" | "0010001" | "0011000" | "0011001" | "0011010" | "0011011" =>
                    modifiesFlags <= "1100";
                WHEN OTHERS =>
                    modifiesFlags <= "0000";
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE controllerArch2;