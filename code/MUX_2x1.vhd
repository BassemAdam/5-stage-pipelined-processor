library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity MUX_2x1 is
    generic(
        N : integer := 8
    );
    port(
        I0, I1 : in std_logic_vector(N-1 downto 0);
        S : in std_logic;
        O : out std_logic_vector(N-1 downto 0)
    );
end entity MUX_2x1;

architecture MUX21Arch of MUX_2x1 is
begin
    O <= I0 when S = '0' else I1;
end architecture MUX21Arch;