LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU IS
    PORT (
        A, B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ALU_sel : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Changed to 4 bits

        ALU_Result1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ALU_Result2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Added for SWAP
        ALU_flags : OUT STD_LOGIC_VECTOR(0 TO 3)
    );
END ENTITY ALU;

ARCHITECTURE ALUArch OF ALU IS

    SIGNAL temp : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL A_sign, B_sign : STD_LOGIC;
    SIGNAL Result_sign : STD_LOGIC;

    SIGNAL Zero : STD_LOGIC;
    SIGNAL Negative : STD_LOGIC;
    SIGNAL Carry : STD_LOGIC;
    SIGNAL Overflow : STD_LOGIC;

BEGIN
    A_sign <= A(31);
    B_sign <= B(31);
    Result_sign <= temp(31);
    WITH ALU_sel SELECT
        temp <=
        NOT A WHEN "0000", -- NOT
        STD_LOGIC_VECTOR(0 - unsigned(A)) WHEN "0001", -- NEG
        A WHEN "0100", -- MOV A
        B WHEN "0101", -- MOV B used in LDM Functionality
        B WHEN "1111", -- SWAP
        A AND B WHEN "1000", -- AND
        A OR B WHEN "1001", -- OR
        A XOR B WHEN "1010", -- XOR

        STD_LOGIC_VECTOR(signed(A) + 1) WHEN "0010", -- INC
        STD_LOGIC_VECTOR(signed(A) - 1) WHEN "0011", -- DEC
        STD_LOGIC_VECTOR(signed(A) + signed(B)) WHEN "0110", -- ADD
        STD_LOGIC_VECTOR(signed(A) - signed(B)) WHEN "0111", -- SUB
        STD_LOGIC_VECTOR(signed(A) - signed(B)) WHEN "1011", -- COM
        -- other operations...
        (OTHERS => '0') WHEN OTHERS;

    WITH ALU_sel SELECT
        ALU_Result2 <=
        A WHEN "1111",
        (OTHERS => '0') WHEN OTHERS;

    Zero <=
        '1' WHEN temp = STD_LOGIC_VECTOR(to_signed(0, temp'length)) ELSE
        '0';

    WITH ALU_sel SELECT
        Carry <=
        (NOT temp(31) AND (A(31))) WHEN "0010", -- INC
        (NOT A(31) AND (temp(31))) WHEN "0011", -- DEC
        (NOT temp(31) AND (A(31) OR B(31))) OR (temp(31) AND A(31) AND B(31)) WHEN "0110", -- ADD
        (NOT A(31) AND (temp(31) OR B(31))) OR (A(31) AND temp(31) AND B(31)) WHEN "0111", -- SUB
        '0' WHEN OTHERS;
    -- Carry <=
    --     '1' when (ALU_sel = "0110" and A_sign = '1' and B_sign = '1') or -- ADD
    --     (ALU_sel = "0010" and A_sign /= Result_sign) or                  -- INC
    --     (ALU_sel = "0011" and A = X"00000000") or                        -- DEC
    --     (ALU_sel = "0111" and signed(A) > signed(B)) else                -- SUB
    --     '0';

    Negative <= Result_sign;

    WITH ALU_sel SELECT
        Overflow <=
        (A(31) XNOR '0') AND (temp(31) XOR A(31)) WHEN "0010" | "0011", -- INC, DEC
        (A(31) XNOR B(31)) AND (temp(31) XOR A(31))WHEN "0110" | "0111", -- ADD, SUB
        '0' WHEN OTHERS;
    -- Overflow <=
    --     '1' when (ALU_sel = "0010" and A_sign /= Result_sign) or              -- INC
    --     (ALU_sel = "0011" and A_sign /= Result_sign) or                       -- DEC
    --     (ALU_sel = "0110" and A_sign = B_sign and A_sign /= Result_sign) or   -- ADD
    --     (ALU_sel = "0111" and A_sign /= B_sign and B_sign = Result_sign) or   -- SUB
    --     (ALU_sel = "1011" and A_sign /= B_sign and A_sign = Result_sign) else -- CMP
    --     '0';

    ALU_flags(0) <= Zero;
    ALU_flags(1) <= Negative;
    ALU_flags(2) <= Carry;
    ALU_flags(3) <= Overflow;
    ALU_Result1 <= temp;

END ARCHITECTURE ALUArch;