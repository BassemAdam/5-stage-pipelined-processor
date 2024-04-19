library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EM_Buffer is
    port (   
        clk, reset, WE : in  std_logic;
        Dst_in : in  std_logic_vector(2 downto 0);
        ALU_OutValue_in : in  std_logic_vector(31 downto 0);
        ALU_OutValue_out : out std_logic_vector(31 downto 0);
        Dst_out : out std_logic_vector(2 downto 0)
    );
end entity EM_Buffer;

architecture EM_Buffer_Arch of EM_Buffer is
begin 
    process(clk, reset)
    begin
        if reset = '1' then
            ALU_OutValue_out <= (others => '0');
            Dst_out <= (others => '0');
        elsif rising_edge(clk) then
            if WE = '1' then
                ALU_OutValue_out <= ALU_OutValue_in;
                Dst_out <= Dst_in;
            end if;
        end if;
    end process;
end architecture EM_Buffer_Arch;