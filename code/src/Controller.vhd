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
        ctr_ALUorMem : out std_logic

        -- Passing through should be none its not a buffer
    );
end entity Controller;

architecture ControllerArch2 of Controller is

begin
    process (ctr_opCode, ctr_Func, RES)
    begin
        if RES = '1' then
            ctr_hasImm   <= '0';
            ctr_we1_reg  <= '0';
            ctr_we2_reg  <= '0';
            ctr_we_mem   <= '0';
            ctr_ALUorMem <= '0';

        else
            case ctr_opCode is
                when "010" =>
                    ctr_hasImm <= '1';
                when others =>
                    ctr_hasImm <= '0';
            end case;

            case ctr_opCode & ctr_Func is
                when "0011011" | "0100011" | "0110001" | "011001-" | "011101-" | "100----" | "101----" | "110----" | "111----" |"0000000" =>
                    ctr_we1_reg <= '0';
                when others =>
                    ctr_we1_reg <= '1';
            end case;
            case ctr_opCode & ctr_Func is
                when "0011111" =>
                    ctr_we2_reg <= '1';
                when others =>
                    ctr_we2_reg <= '0';
            end case;
            case ctr_opCode is
                when "010" =>
                    ctr_we_mem <= '1';
                when others =>
                    ctr_we_mem <= '0';
            end case;

            case ctr_opCode & ctr_Func is
                when "0101100" => -- LDD
                    ctr_ALUorMem <= '1';
                when others =>
                    ctr_ALUorMem <= '0';
            end case;

            --I HAVE NO IDEA HOW TO SET THIS (ALI)
            case ctr_opCode & ctr_Func is
                when "0010010" | "0010011" | "0010110" | "0010111" | "0100000" | "0100001" =>
                    ctr_flags_en <= "1111";
                when "0010000" | "0010001" | "0011000" | "0011001" | "0011010" | "0011011" =>
                    ctr_flags_en <= "1100";
                when others =>
                    ctr_flags_en <= "0000";
            end case;

            case ctr_opCode is
                when "001" =>           -- ALU operation
                    ctr_ALUsel <= ctr_Func; -- same as function num
                when "010" =>           -- when Immediate operation
                    case ctr_Func is
                        when "0000" | "0011" | "1100" => -- ADDI or LDD or STD
                            ctr_ALUsel <= "1000";            -- additon
                        when "0001" =>                   -- SUBI
                            ctr_ALUsel <= "0111";            -- subtraction
                        when "0010" =>                   -- LDM
                            ctr_ALUsel <= "0101";            -- mov B
                        when others =>
                            ctr_ALUsel <= "0100";-- move
                    end case;
                when others =>
                    ctr_ALUsel <= "0100"; -- move
            end case;

        end if;

    end process;
end architecture ControllerArch2;
