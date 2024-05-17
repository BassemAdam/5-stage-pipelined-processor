library ieee;
use ieee.std_logic_1164.ALL;

entity MUX_2x1 is 
    generic(n:integer:=31);
    port(
        A: in STD_LOGIC_VECTOR(n downto 0);
        B: in STD_LOGIC_VECTOR(n downto 0);
        Sel: in STD_LOGIC;
        F: out STD_LOGIC_VECTOR(n downto 0)
    );
end entity MUX_2x1;

architecture mux2x1 of MUX_2x1 is 
begin
    F <= A when Sel = '0' else B;
end architecture mux2x1;