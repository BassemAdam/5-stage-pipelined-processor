library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controller is
    generic (
        INST_WIDTH : integer := 16
    );
    port (
        clk           : in std_logic;
        rst           : in std_logic;
        ctr_opCode_in : in std_logic_vector(2 downto 0);
        ctr_Rdest_in  : in std_logic_vector(2 downto 0);
        ctr_Rsrc1_in  : in std_logic_vector(2 downto 0);
        ctr_Rsrc2_in  : in std_logic_vector(2 downto 0);
        ctr_fnNum_in  : in std_logic_vector(3 downto 0);

        ctr_opCode_out  : out std_logic_vector(2 downto 0);
        ctr_fnNum_out   : out std_logic_vector(3 downto 0);
        ctr_Rsrc1_out   : out std_logic_vector(2 downto 0);
        ctr_Rsrc2_out   : out std_logic_vector(2 downto 0);
        ctr_Rdest_out   : out std_logic_vector(2 downto 0);
        hasImm          : out std_logic;
        writeEnable_reg : out std_logic;
        writeEnable_mem : out std_logic;
        ALUorMem        : out std_logic;
        --predictor: OUT STD_LOGIC;
        --protect: OUT STD_LOGIC;
        --free: OUT STD_LOGIC;
        --isJZ : OUT STD_LOGIC;
        --isJMP : OUT STD_LOGIC;
        --flushIF_ID : OUT STD_LOGIC;
        --flushID_EX : OUT STD_LOGIC;
        --flushEX_MEM : OUT STD_LOGIC;
        --flushMEM_WB : OUT STD_LOGIC;
        stall        : out std_logic;
        int          : out std_logic;
        isSwap       : out std_logic;
        ctr_flags_en : out std_logic_vector(0 to 3);
        ctr_ALU_sel  : out std_logic_vector(3 downto 0);
        PCIncType    : out std_logic_vector(1 downto 0)
        --CallorInt : OUT STD_LOGIC;

        --push : OUT STD_LOGIC;
        --pop : OUT STD_LOGIC;

    );
end entity controller;

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
--             WITH ctr_fnNum_in SELECT ctr_flags_en <=
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

--             WITH ctr_fnNum_in SELECT ctr_flags_en <=
--                 "1111" WHEN "0000" | "0001",
--                 "0000" WHEN OTHERS;

--         END IF;
--     END IF;
-- END ARCHITECTURE controllerArch;
architecture controllerArch2 of controller is

begin
    -- reset
    ctr_opCode_out <= (others => '0') when rst = '1' else
    ctr_opCode_in;
    process (ctr_opCode_in, ctr_fnNum_in, rst)
    begin
        if rst = '1' then
            hasImm          <= '0';
            writeEnable_reg <= '0';
            writeEnable_mem <= '0';
            ALUorMem        <= '0';
            -- predictor <= '0';
            -- protect <= '0';
            -- free <= '0';
            -- isJZ <= '0';
            -- isJMP <= '0';
            -- flushIF_ID <= '0';
            -- flushID_EX <= '0';
            -- flushEX_MEM <= '0';
            -- flushMEM_WB <= '0';
            stall     <= '0';
            int       <= '0';
            isSwap    <= '0';
            PCIncType <= (others => '0');
            -- CallorInt <= '0';
            -- push <= '0';
            -- pop <= '0';
            else
            case ctr_opCode_in is
                when "010" =>
                    hasImm <= '1';
                when others =>
                    hasImm <= '0';
            end case;

            case ctr_opCode_in & ctr_fnNum_in is
                when "000----" | "0011011" | "0100011" | "0110001" | "011001-" | "011101-" | "100----" | "101----" | "110----" | "111----" =>
                    writeEnable_reg <= '0';
                when others =>
                    writeEnable_reg <= '1';
            end case;
            
            case ctr_opCode_in is
                when "010" =>
                    writeEnable_mem <= '1';
                when others =>
                    writeEnable_mem <= '0';
            end case;

            case ctr_opCode_in & ctr_fnNum_in is
                when "0101100" =>   -- LDD
                    ALUorMem <= '1';
                when others =>
                    ALUorMem <= '0';
            end case;

            case ctr_opCode_in & ctr_fnNum_in is
                when "0100101" =>
                    stall <= '1';
                when others =>
                    stall <= '0';
            end case;
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
            case ctr_opCode_in & ctr_fnNum_in(3) is
                when "1111" =>
                    int <= '1';
                when others =>
                    int <= '0';
            end case;

            case ctr_opCode_in & ctr_fnNum_in is
                when "0010101" =>
                    isSwap <= '1';
                when others =>
                    isSwap <= '0';
            end case;

            -- with ctr_opCode_in & ctr_fnNum_in select PCIncType <=,
            --I HAVE NO IDEA HOW TO SET THIS (ALI)
            case ctr_opCode_in & ctr_fnNum_in is
                when "0010010" | "0010011" | "0010110" | "0010111" | "0100000" | "0100001" =>
                    ctr_flags_en <= "1111";
                when "0010000" | "0010001" | "0011000" | "0011001" | "0011010" | "0011011" =>
                    ctr_flags_en <= "1100";
                when others =>
                    ctr_flags_en <= "0000";
            end case;

            case ctr_opCode_in is
                when "001" =>                -- ALU operation
                    ctr_ALU_sel <= ctr_fnNum_in; -- same as function num
                when "010" =>                -- when Immediate operation
                    case ctr_fnNum_in is
                        when "0000" | "0011" | "1100" => -- ADDI or LDD or STD
                            ctr_ALU_sel <= "1000";           -- additon
                        when "0001" =>                   -- SUBI
                            ctr_ALU_sel <= "0111";           -- subtraction
                        when "0010" =>                   -- LDM
                            ctr_ALU_sel <= "0101";           -- mov B
                        when others =>
                            ctr_ALU_sel <= "0100";-- move
                    end case;
                when others =>
                    ctr_ALU_sel <= "0100"; -- move
            end case;
            
        end if;

    end process;
end architecture controllerArch2;
