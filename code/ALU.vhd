library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
    port (
        A, B       : in std_logic_vector(31 downto 0);
        ALUControl : in std_logic_vector(3 downto 0); -- Changed to 4 bits

        Result    : out std_logic_vector(31 downto 0);
        ALU_flags : out std_logic_vector(0 to 3)
    );
end entity ALU;

architecture ALUArch of ALU is

    signal intermediate                : std_logic_vector(31 downto 0);
    signal A_sign, B_sign, Result_sign : std_logic;

    signal Zero     : std_logic;
    signal Negative : std_logic;
    signal Carry    : std_logic;
    signal Overflow : std_logic;

begin
    A_sign      <= A(31);
    B_sign      <= B(31);
    Result_sign <= intermediate(31);
    with ALUControl select
    intermediate <=
    -- NOT
    not A when "0000",
    --NEG
    std_logic_vector(0 - unsigned(A)) when "0001",
    --MOV
    A when "0100",
    --SWAP NOT COMPLETED
    B when "0101",
    --AND
    A and B when "1000",
    --OR
    A or B when "1001",
    --XOR
    A xor B when "1010",
    -- INC
    std_logic_vector(signed(A) + 1) when "0010",
    -- DEC
    std_logic_vector(signed(A) - 1) when "0011",
    -- ADD
    std_logic_vector(signed(A) + signed(B)) when "0110",
    -- SUB
    std_logic_vector(signed(A) - signed(B)) when "0111",
    -- CMP
    std_logic_vector(signed(A) - signed(B)) when "1011",
    -- other operations...
    (others => '0') when others;

    Carry <=
    '1' when (ALUControl = "0110" and A_sign = '1' and B_sign = '1') or -- ADD
    (ALUControl = "0010" and A_sign /= Result_sign) or                  -- INC
    (ALUControl = "0011" and A = X"00000000") or                        -- DEC
    (ALUControl = "0111" and signed(A) > signed(B)) else                -- SUB
    '0';

    Negative <= Result_sign;

    Overflow <=
    '1' when (ALUControl = "0010" and A_sign /= Result_sign) or              -- INC
    (ALUControl = "0011" and A_sign /= Result_sign) or                       -- DEC
    (ALUControl = "0110" and A_sign = B_sign and A_sign /= Result_sign) or   -- ADD
    (ALUControl = "0111" and A_sign /= B_sign and B_sign = Result_sign) or   -- SUB
    (ALUControl = "1011" and A_sign /= B_sign and A_sign = Result_sign) else -- CMP
    '0';

    Zero <= '1' when intermediate = std_logic_vector(to_signed(0, Result'length)) else
    '0';

    ALU_flags(0) <= Zero;
    ALU_flags(1) <= Negative;
    ALU_flags(2) <= Carry;
    ALU_flags(3) <= Overflow;
    Result    <= intermediate;
end architecture ALUArch;
