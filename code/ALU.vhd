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
            --ADD
                A + B when "000",
            --SUB    
                A - B when "001",
            --AND
                A and B when "010",
            --OR    
                A or B when "011",
            --XOR    
                A xor B when "100",
            --NOT A    
                not A when "101",
            --CMP     
                A - B when "110",
                (others => '0') when others;
        Zero <= '1' when Result = (others => '0') else '0';

end architecture ALU;
