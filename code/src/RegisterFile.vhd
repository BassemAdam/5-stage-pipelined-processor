library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity RegisterFile is
    generic (
        w : integer := 3;
        n : integer := 32
    );
    port (
        clk, RES : in std_logic;

        RE_we1    : in std_logic;
        RF_we2    : in std_logic;
        RF_Rdst1   : in std_logic_vector(w - 1 downto 0);
        RF_Rdst2   : in std_logic_vector(w - 1 downto 0);
        RF_Wdata1 : in std_logic_vector(n - 1 downto 0);
        RF_Wdata2 : in std_logic_vector(n - 1 downto 0);

        RF_Rsrc1 : in std_logic_vector(w - 1 downto 0);
        RF_Rsrc2 : in std_logic_vector(w - 1 downto 0);

        RF_Rdata1 : out std_logic_vector(n - 1 downto 0);
        RF_Rdata2 : out std_logic_vector(n - 1 downto 0)
    );
end entity RegisterFile;

architecture Behavioral of RegisterFile is
    type register_array is array (0 to 2 ** w - 1) of std_logic_vector(n - 1 downto 0);
    signal q_registers : register_array;

begin

    process (clk, RES)
    begin
        if RES = '1' then
            q_registers <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if RE_we1 = '1' then
                q_registers(TO_INTEGER(unsigned(RF_Rdst1))) <= RF_Wdata1;
            end if;
            if RF_we2 = '1' then
                q_registers(TO_INTEGER(unsigned(RF_Rdst2))) <= RF_Wdata2;
            end if;
        end if;
    end process;

    RF_Rdata1 <= q_registers(TO_INTEGER(unsigned(RF_Rsrc1)));
    RF_Rdata2 <= q_registers(TO_INTEGER(unsigned(RF_Rsrc2)));

end architecture Behavioral;
