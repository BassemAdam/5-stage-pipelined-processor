library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE_Buffer is
    port (
        clk, RES, WE : in std_logic;
        DE_Rsrc1_Val : in std_logic_vector(31 downto 0);
        DE_Rsrc2_Val : in std_logic_vector(31 downto 0);
        DE_Imm       : in std_logic_vector(15 downto 0);
        DE_isImm     : in std_logic;

        DE_ALUopd1 : out std_logic_vector(31 downto 0);
        DE_ALUopd2 : out std_logic_vector(31 downto 0);

        -- Passing through
        DE_we1_reg_in   : in std_logic;
        DE_we1_reg_out  : out std_logic;
        DE_we2_reg_in   : in std_logic;
        DE_we2_reg_out  : out std_logic;
        DE_ALUorMem_in  : in std_logic;
        DE_ALUorMem_out : out std_logic;
        DE_flags_en_in  : in std_logic_vector (0 to 3);
        DE_flags_en_out : out std_logic_vector (0 to 3);
        DE_Rdst1_in     : in std_logic_vector(2 downto 0);
        DE_Rdst2_in     : in std_logic_vector(2 downto 0);
        DE_Rdst1_out    : out std_logic_vector(2 downto 0);
        DE_Rdst2_out    : out std_logic_vector(2 downto 0);
        DE_ALUsel_in    : in std_logic_vector(3 downto 0);
        DE_ALUsel_out   : out std_logic_vector(3 downto 0)
    );
end entity DE_Buffer;

architecture DE_Buffer_Arch of DE_Buffer is
begin
    process (clk, RES)
        variable DE_ALUopd2_var : std_logic_vector(31 downto 0);
    begin
        if RES = '1' then
            DE_we1_reg_out  <= '0';
            DE_ALUorMem_out <= '0';
            DE_flags_en_out <= (others => '0');
            DE_ALUopd1      <= (others => '0');
            DE_ALUopd2      <= (others => '0');
            DE_Rdst1_out    <= (others => '0');
            DE_Rdst2_out    <= (others => '0');
            DE_ALUsel_out   <= (others => '0');

        elsif falling_edge(clk) then

            if WE = '1' then
                DE_we1_reg_out  <= DE_we1_reg_in;
                DE_we2_reg_out  <= DE_we2_reg_in;
                DE_ALUorMem_out <= DE_ALUorMem_in;
                DE_ALUopd1      <= DE_Rsrc1_Val;
                DE_flags_en_out <= DE_flags_en_in;

                if DE_isImm = '1' then
                    DE_ALUopd2_var := X"0000" & DE_Imm;
                else
                    DE_ALUopd2_var := DE_Rsrc2_Val;
                end if;

                DE_ALUopd2    <= DE_ALUopd2_var;
                DE_Rdst1_out  <= DE_Rdst1_in;
                DE_Rdst2_out  <= DE_Rdst2_in;
                DE_ALUsel_out <= DE_ALUsel_in;
            end if;
        end if;
    end process;
end architecture DE_Buffer_Arch;
