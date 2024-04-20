LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU IS
    PORT (
        A, B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ALUControl : IN STD_LOGIC_VECTOR(6 DOWNTO 0); -- Changed to 4 bits
        Result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Zero : OUT STD_LOGIC;
        Negative : OUT STD_LOGIC;
        Carry : OUT STD_LOGIC;
        Overflow : OUT STD_LOGIC
    );
END ENTITY ALU;

ARCHITECTURE ALUArch OF ALU IS

    SIGNAL intermediate : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL A_sign, B_sign, Result_sign : STD_LOGIC;

BEGIN
    A_sign <= A(31);
    B_sign <= B(31);
    Result_sign <= intermediate(31);
    WITH ALUControl SELECT
        intermediate <=
        -- NOT
        NOT A WHEN "0010000",
        --NEG
        STD_LOGIC_VECTOR(0 - unsigned(A)) WHEN "0010001",
        --MOV
        A WHEN "0010100",
        --SWAP NOT COMPLETED
        B WHEN "0010101",
        --AND
        A AND B WHEN "0011000",
        --OR
        A OR B WHEN "0011001",
        --XOR
        A XOR B WHEN "0011010",
        -- INC
        STD_LOGIC_VECTOR(signed(A) + 1) WHEN "0010010",
        -- DEC
        STD_LOGIC_VECTOR(signed(A) - 1) WHEN "0010011",
        -- ADD
        STD_LOGIC_VECTOR(signed(A) + signed(B)) WHEN "0010110",
        -- SUB
        STD_LOGIC_VECTOR(signed(A) - signed(B)) WHEN "0010111",
        -- CMP
        STD_LOGIC_VECTOR(signed(A) - signed(B)) WHEN "0011011",
        -- other operations...
        (OTHERS => '0') WHEN OTHERS;

    Carry <= '1' WHEN (ALUControl = "0010110" AND A_sign = '1' AND B_sign = '1') OR -- ADD
        (ALUControl = "0010010" AND A_sign /= Result_sign) OR -- INC
        (ALUControl = "0010011" AND A = X"00000000") OR -- DEC
        (ALUControl = "0010111" AND signed(A) > signed(B)) ELSE -- SUB
        '0';

    Negative <= Result_sign;

    Overflow <= '1' WHEN (ALUControl = "0010010" AND A_sign /= Result_sign) OR -- INC
        (ALUControl = "0010011" AND A_sign /= Result_sign) OR -- DEC
        (ALUControl = "0010110" AND A_sign = B_sign AND A_sign /= Result_sign) OR -- ADD
        (ALUControl = "0010111" AND A_sign /= B_sign AND B_sign = Result_sign) OR -- SUB
        (ALUControl = "0011011" AND A_sign /= B_sign AND A_sign = Result_sign) ELSE -- CMP
        '0';

    Zero <= '1' WHEN intermediate = STD_LOGIC_VECTOR(to_signed(0, Result'length)) ELSE
        '0';

    Result <= intermediate;
END ARCHITECTURE ALUArch;