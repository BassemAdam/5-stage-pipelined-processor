library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EM_Buffer is
    port (
        clk, RES, WE : in std_logic;

        -- Passing through
        EM_OUTport_en_out : out std_logic;
        EM_OUTport_en_in     : in std_logic;
        EM_ALUorMem_in    : in std_logic;
        EM_ALUorMem_out   : out std_logic;
        EM_we1_reg_in     : in std_logic;
        EM_we1_reg_out    : out std_logic;
        EM_we2_reg_in     : in std_logic;
        EM_we2_reg_out    : out std_logic;
        EM_Rdst1_in        : in std_logic_vector(2 downto 0);
        EM_Rdst1_out       : out std_logic_vector(2 downto 0);
        EM_Rdst2_in        : in std_logic_vector(2 downto 0);
        EM_Rdst2_out       : out std_logic_vector(2 downto 0);
        EM_ALUResult1_in  : in std_logic_vector(31 downto 0);
        EM_ALUResult1_out : out std_logic_vector(31 downto 0);
        EM_ALUResult2_in  : in std_logic_vector(31 downto 0);
        EM_ALUResult2_out : out std_logic_vector(31 downto 0)
        );
end entity EM_Buffer;

architecture EM_Buffer_Arch of EM_Buffer is
begin
    process (clk, RES)
    begin
        if RES = '1' then
            EM_we1_reg_out    <= '0';
            EM_we2_reg_out    <= '0';
            EM_ALUorMem_out   <= '0';
            EM_ALUResult1_out <= (others => '0');
            EM_ALUResult2_out <= (others => '0');
            EM_Rdst1_out       <= (others => '0');
            EM_Rdst2_out       <= (others => '0');
            EM_OUTport_en_out <= '0';
        elsif falling_edge(clk) then
            if WE = '1' then
                EM_OUTport_en_out <= EM_OUTport_en_in;
                EM_ALUorMem_out   <= EM_ALUorMem_in;
                EM_we1_reg_out    <= EM_we1_reg_in;
                EM_we2_reg_out    <= EM_we2_reg_in;
                EM_ALUResult1_out <= EM_ALUResult1_in;
                EM_ALUResult2_out <= EM_ALUResult2_in;
                EM_Rdst1_out       <= EM_Rdst1_in;
                EM_Rdst2_out       <= EM_Rdst2_in;
            end if;
        end if;
    end process;
end architecture EM_Buffer_Arch;
