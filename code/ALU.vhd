library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
    port(
        A, B: in std_logic_vector(31 downto 0);
        ALUControl: in std_logic_vector(6 downto 0); -- Changed to 4 bits
        Result: out std_logic_vector(31 downto 0);
        Zero: out std_logic;
        Negative: out std_logic;
        Carry: out std_logic;
        Overflow: out std_logic
    );
end entity ALU;

architecture ALUArch  of ALU is
    signal intermediate: std_logic_vector(32 downto 0);
    signal A_sign, B_sign, Result_sign: std_logic;
begin
    A_sign <= A(31);
    B_sign <= B(31);
    Result_sign <= intermediate(31);
    with ALUControl select
        intermediate <=
        --NOT
            not A when "0010000",
        --NEG
            std_logic_vector(0 - unsigned(A)) when "0010001",
        --INC
            std_logic_vector(unsigned(A) + 1) when "0010010",
        --DEC
            std_logic_vector(unsigned(A) - 1) when "0010011",
        --MOV
            A when "0010100",
        --SWAP NOT COMPLETED
            B when "0010101",
        --ADD
            std_logic_vector(unsigned(A) + unsigned(B)) when "0010110",
        --SUB
            std_logic_vector(unsigned(A) - unsigned(B)) when "0010111",
        --AND
            A and B when "0011000",
        --OR
            A or B when "0011001",
        --XOR
            A xor B when "0011010",
        --CMP
            std_logic_vector(unsigned(A) - unsigned(B)) when "0011011",
        --Default
            (others => '0') when others;
        Carry <= intermediate(32); -- Carry is the 33rd bit
        Negative <= '0' when ALUControl /= "0010011" and ALUControl /= "0010111" else intermediate(32);
        Overflow <= '1' when (ALUControl = "0010010" and A_sign /= Result_sign) or -- INC
        (ALUControl = "0010011" and A_sign /= Result_sign) or -- DEC
        (ALUControl = "0010110" and A_sign = B_sign and A_sign /= Result_sign) or -- ADD
        (ALUControl = "0010111" and A_sign /= B_sign and A_sign /= Result_sign) else -- SUB
        '0';
        Zero <= '1' when intermediate(31 downto 0)=std_logic_vector(to_unsigned(0, Result'length)) else '0';
        Result <= intermediate(31 downto 0);

end architecture ALUArch;