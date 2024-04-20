
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CCR is
    port (
        clk, RES : in std_logic;
        flags_in : in std_logic_vector (0 to 3);
        flags_en : in std_logic_vector (0 to 3);

        flags_out : out std_logic_vector (0 to 3)
    );
end entity CCR;

architecture arch1 of CCR is

begin

    process (clk, RES)
    begin

        if RES = '1' then
            flags_out <= "0000";
        elsif rising_edge(clk) then

            if flags_en(0) = '1' then
                flags_out(0) <= flags_in(0);
            end if;

            if flags_en(1) = '1' then
                flags_out(1) <= flags_in(1);
            end if;

            if flags_en(1) = '1' then
                flags_out(1) <= flags_in(1);
            end if;

            if flags_en(1) = '1' then
                flags_out(1) <= flags_in(1);
            end if;

        end if;

    end process;

end architecture arch1;
