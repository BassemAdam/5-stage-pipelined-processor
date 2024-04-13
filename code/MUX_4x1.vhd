library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity MUX_4x1 is
    generic(
        N : integer := 8
    );
    port(
        I0, I1, I2, I3 : in std_logic_vector(N - 1  downto 0);
        S : in std_logic_vector(1 downto 0);
        O : out std_logic_vector(N - 1  downto 0)
    );
end entity MUX_4x1;

architecture MUX41Arch of MUX_4x1 is
    begin
    with S select
        O <= I0 when "00",
             I1 when "01",
             I2 when "10",
             I3 when others;

end architecture MUX41Arch;
