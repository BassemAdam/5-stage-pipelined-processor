library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Controller is
    generic (
        INST_WIDTH : integer := 16
    );
    port (
        clk        : in std_logic;
        RES        : in std_logic;
        ctr_opCode : in std_logic_vector(2 downto 0);
        ctr_Func   : in std_logic_vector(3 downto 0);

        ctr_hasImm   : out std_logic;
        ctr_ALUsel   : out std_logic_vector(3 downto 0);
        ctr_flags_en : out std_logic_vector(0 to 3);
        ctr_we1_reg  : out std_logic;
        ctr_we2_reg  : out std_logic;
        ctr_we_mem   : out std_logic;
        ctr_ALUorMem : out std_logic;
        ctr_isInput    : out std_logic

        -- Passing through should be none its not a buffer
    );
end entity Controller;

architecture ControllerArch3 of Controller is

begin
    process (ctr_opCode, ctr_Func, RES)
    begin

        -- ctr_hasImm   <= '0';
        -- ctr_ALUsel   <= (others => '0');
        -- ctr_flags_en <= (others => '0');
        -- ctr_we1_reg  <= '0';
        -- ctr_we2_reg  <= '0';
        -- ctr_we_mem   <= '0';
        -- ctr_ALUorMem <= '0';

        if RES = '0' then
            if ctr_opCode = "000" then -- NOP
                ctr_flags_en <= (others => '0');
                ctr_we1_reg  <= '0';
                ctr_we2_reg  <= '0';
                ctr_we_mem   <= '0';
                ctr_hasImm   <= '0';
            end if;

            if ctr_opCode = "001" then -- ALU 
                ctr_ALUsel   <= ctr_Func;
                ctr_we1_reg  <= '1';
                ctr_ALUorMem <= '0';

                if ctr_Func = "0000" then -- NOT
                    ctr_flags_en <= "1100";
                end if;
                if ctr_Func = "0001" then -- NEG
                    ctr_flags_en <= "1100";
                end if;
                if ctr_Func = "0010" then -- INC
                    ctr_flags_en <= "1111";
                end if;
                if ctr_Func = "0011" then -- DEC
                    ctr_flags_en <= "1111";
                end if;
                if ctr_Func = "0100" then -- MOV
                    ctr_flags_en <= "0000";
                end if;
                if ctr_Func = "0101" then -- MOV
                    ctr_flags_en <= "0000";
                end if;
                if ctr_Func = "0110" then -- ADD
                    ctr_flags_en <= "1111";
                end if;
                if ctr_Func = "0111" then -- SUB
                    ctr_flags_en <= "1111";
                end if;
                if ctr_Func = "1000" then -- AND
                    ctr_flags_en <= "1100";
                end if;
                if ctr_Func = "1001" then -- OR
                    ctr_flags_en <= "1100";
                end if;
                if ctr_Func = "1010" then -- XOR
                    ctr_flags_en <= "1100";
                end if;
                if ctr_Func = "1011" then -- CMP
                    ctr_we1_reg  <= '0';
                    ctr_flags_en <= "1100";
                end if;
            end if;
            ----------------------------Imm-------------------------------------------
            if ctr_opCode = "010" then -- Immediate 
                ctr_hasImm <= '1';
                if ctr_Func = "0011" then -- STD
                    ctr_we_mem <= '1';
                    ctr_ALUsel <= "0110";
                end if;
                if ctr_Func = "1100" then -- LDD
                    ctr_ALUorMem <= '1';
                    ctr_ALUsel   <= "0110";
                end if;
                if ctr_Func = "0010" then -- LDM
                    ctr_ALUsel  <= "0101";
                    ctr_we1_reg <= '1';
                end if;
                if ctr_Func = "0000" then -- ADDI
                    ctr_ALUsel   <= "0110";
                    ctr_flags_en <= "1111";
                    ctr_we1_reg  <= '1';
                    ctr_ALUorMem <= '0';
                end if;
                if ctr_Func = "0001" then -- SUBI
                    ctr_ALUsel   <= "0111";
                    ctr_flags_en <= "1111";
                    ctr_we1_reg  <= '1';
                    ctr_ALUorMem <= '0';
                end if;
            end if;

            if ctr_opCode = "011" then -- Data Operations 
                if ctr_Func = "0000" then
                end if;
                if ctr_Func = "1001" then -- Input
                    ctr_isInput <= '1';
                    ctr_hasImm   <= '0';
                    ctr_ALUsel   <= "0101";
                    ctr_flags_en <= "0000";
                    ctr_we1_reg  <= '1';
                    ctr_we2_reg  <= '0';
                    ctr_we_mem   <= '0';
                    ctr_ALUorMem <= '0';
                    end if;
            end if;

            if ctr_opCode = "100" then -- Conditional Jump
                if ctr_Func = "0000" then
                end if;
            end if;

            if ctr_opCode = "101" then -- Unconditional Jump
                if ctr_Func = "0000" then
                end if;
            end if;

            if ctr_opCode = "110" then -- Memory Security
                if ctr_Func = "0000" then
                end if;
            end if;

            if ctr_opCode = "111" then -- Input Signals
                if ctr_Func = "0000" then
                end if;
            end if;
        else
            ctr_hasImm   <= '0';
            ctr_ALUsel   <= (others => '0');
            ctr_flags_en <= (others => '0');
            ctr_we1_reg  <= '0';
            ctr_we2_reg  <= '0';
            ctr_we_mem   <= '0';
            ctr_ALUorMem <= '0';
        end if;
    end process;
end architecture ControllerArch3;

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
