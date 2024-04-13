library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
    port(
        A, B: in std_logic_vector(31 downto 0);
        ALUControl: in std_logic_vector(2 downto 0);
        Result: out std_logic_vector(31 downto 0);
        Zero: out std_logic
    );
end entity ALU;

architecture  of ALU is
    begin
        with ALUControl select
            Result <=
                A + B when "000",
                A - B when "001",
                A and B when "010",
                A or B when "011",
                A xor B when "100",
                not A when "101",
                not B when "110",
                (others => '0') when others;
        Zero <= '1' when Result = (others => '0') else '0';

end architecture ALU;
