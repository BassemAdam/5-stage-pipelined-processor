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

architecture ALUArch  of ALU is
    signal intermediate: std_logic_vector(31 downto 0);
    begin
        with ALUControl select
            intermediate <=
            --ADD
                std_logic_vector(unsigned(A) + unsigned(B)) when "000",
            --SUB    
                std_logic_vector(unsigned(A) - unsigned(B)) when "001",
            --AND
                A and B when "010",
            --OR    
                A or B when "011",
            --XOR    
                A xor B when "100",
            --NOT A    
                not A when "101",
            --CMP     
            std_logic_vector(unsigned(A) - unsigned(B)) when "110",
          
            --Other    
                (others => '0') when others;        
        Zero <= '1' when intermediate=std_logic_vector(to_unsigned(0, Result'length)) else '0';
        Result <= intermediate;

end architecture ALUArch;
