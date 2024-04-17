library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE_Buffer is
    port (   
        clk, reset, WE : in  std_logic;
        Rsrc1_Val_in, Rsrc2_Val_in, Dst_in : in  std_logic_vector(31 downto 0);
        aluSelectors_in : in  std_logic_vector(10 downto 0); -- 11 instruction alu
        Rsrc1_Val_out, Rsrc2_Val_out, Dst_out : out std_logic_vector(31 downto 0);
        aluSelectors_out : out std_logic_vector(10 downto 0)
    );
end entity DE_Buffer;

architecture DE_Buffer_Arch of DE_Buffer is
begin 
    process(clk, reset)
    begin
        if reset = '1' then
            Rsrc1_Val_out <= (others => '0');
            Rsrc2_Val_out <= (others => '0');
            Dst_out <= (others => '0');
            aluSelectors_out <= (others => '0');
        elsif rising_edge(clk) then
            if WE = '1' then
                Rsrc1_Val_out <= Rsrc1_Val_in;
                Rsrc2_Val_out <= Rsrc2_Val_in;
                Dst_out <= Dst_in;
                aluSelectors_out <= aluSelectors_in;
            end if;
        end if;
    end process;
end architecture DE_Buffer_Arch;