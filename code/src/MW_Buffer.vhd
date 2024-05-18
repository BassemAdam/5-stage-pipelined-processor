library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MW_Buffer is
    port (
        clk, RES, WE,FLUSH  : in std_logic;
        MW_ALUorMem   : in std_logic;
        MW_ALUResult1 : in std_logic_vector(31 downto 0);
        MW_ALUResult2 : in std_logic_vector(31 downto 0);
        MW_MemResult  : in std_logic_vector(31 downto 0);

        MW_value1 : out std_logic_vector(31 downto 0);
        MW_value2 : out std_logic_vector(31 downto 0);

        -- Passing through

        MW_OUTport_en_out : out std_logic;
        MW_OUTport_en_in  : in std_logic;
        MW_we1_reg_in  : in std_logic;
        MW_we1_reg_out : out std_logic;
        MW_we2_reg_in  : in std_logic;
        MW_we2_reg_out : out std_logic;
        MW_Rdst1_in     : in std_logic_vector(2 downto 0);
        MW_Rdst1_out    : out std_logic_vector(2 downto 0);
        MW_Rdst2_in     : in std_logic_vector(2 downto 0);
        MW_Rdst2_out    : out std_logic_vector(2 downto 0);
        MW_POP_PC_in : IN STD_LOGIC;
        MW_POP_PC_out : OUT STD_LOGIC

    );
end entity MW_Buffer;

architecture MW_Buffer_Arch of MW_Buffer is
begin
    process (clk, RES)
    begin
        if RES = '1' then
            MW_we1_reg_out <= '0';
            MW_we2_reg_out <= '0';
            MW_value1      <= (others => '0');
            MW_value2      <= (others => '0');
            MW_Rdst1_out    <= (others => '0');
            MW_Rdst2_out    <= (others => '0');
            MW_OUTport_en_out <= '0';
            MW_POP_PC_out <= '0';
        elsif falling_edge(clk) then
            if WE = '1' then
                if (MW_ALUorMem = '1') then
                    MW_value1 <= MW_MemResult;
                else
                    MW_value1 <= MW_ALUResult1;
                    MW_value2 <= MW_ALUResult2;
                end if;
                MW_OUTport_en_out <= MW_OUTport_en_in;
                MW_we1_reg_out <= MW_we1_reg_in;
                MW_we2_reg_out <= MW_we2_reg_in;
                MW_Rdst1_out    <= MW_Rdst1_in;
                MW_Rdst2_out    <= MW_Rdst2_in;
                MW_POP_PC_out <= MW_POP_PC_in;
            end if;
        end if;
    end process;
end architecture MW_Buffer_Arch;
