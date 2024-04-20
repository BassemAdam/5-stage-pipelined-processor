library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE_Buffer is
    port (
        clk, reset, WE  : in std_logic;
        Rsrc1_Val_in    : in std_logic_vector(31 downto 0);
        Rsrc2_Val_in    : in std_logic_vector(31 downto 0);
        Dst_in          : in std_logic_vector(2 downto 0); -- Adjusted length to 3
        aluSelectors_in : in std_logic_vector(3 downto 0);
        DE_we_reg_in    : in std_logic;
        DE_AluOrMem_in  : in std_logic;

        DE_we_reg_out    : out std_logic;
        DE_AluOrMem_out  : out std_logic;
        Rsrc1_Val_out    : out std_logic_vector(31 downto 0);
        Rsrc2_Val_out    : out std_logic_vector(31 downto 0);
        Dst_out          : out std_logic_vector(2 downto 0);
        aluSelectors_out : out std_logic_vector(3 downto 0)
    );
end entity DE_Buffer;

architecture DE_Buffer_Arch of DE_Buffer is
begin
    process (clk, reset)
    begin
        if reset = '1' then
            DE_we_reg_out    <= '0';
            DE_AluOrMem_out  <= '0';
            Rsrc1_Val_out    <= (others => '0');
            Rsrc2_Val_out    <= (others => '0');
            Dst_out          <= (others => '0');
            aluSelectors_out <= (others => '0');
            elsif falling_edge(clk) then
            if WE = '1' then
                DE_we_reg_out    <= DE_we_reg_in;
                DE_AluOrMem_out  <= DE_AluOrMem_in;
                Rsrc1_Val_out    <= Rsrc1_Val_in;
                Rsrc2_Val_out    <= Rsrc2_Val_in;
                Dst_out          <= Dst_in;
                aluSelectors_out <= aluSelectors_in;
            end if;
        end if;
    end process;
end architecture DE_Buffer_Arch;
