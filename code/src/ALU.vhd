library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
    port (
        A, B : in std_logic_vector(31 downto 0);
        sel  : in std_logic_vector(3 downto 0); -- Changed to 4 bits

        Result1 : out std_logic_vector(31 downto 0);
        Result2 : out std_logic_vector(31 downto 0); -- Added for SWAP
        flags   : out std_logic_vector(0 to 3)
    );
end entity ALU;

architecture ALUArch of ALU is

    signal temp           : std_logic_vector(31 downto 0);
    signal A_sign, B_sign : std_logic;
    signal Result_sign    : std_logic;

    signal Zero     : std_logic;
    signal Negative : std_logic;
    signal Carry    : std_logic;
    signal Overflow : std_logic;

begin
    A_sign      <= A(31);
    B_sign      <= B(31);
    Result_sign <= temp(31);
    with sel select
        temp <=
        not A when "0000",                             -- NOT
        std_logic_vector(0 - unsigned(A)) when "0001", -- NEG
        A when "0100",                                 -- MOV A
        B when "0101",                                 -- MOV B used in LDM Functionality
        A when "1111",                                 -- SWAP
        A and B when "1000",                           -- AND
        A or B when "1001",                            -- OR
        A xor B when "1010",                           -- XOR

        std_logic_vector(signed(A) + 1) when "0010",         -- INC
        std_logic_vector(signed(A) - 1) when "0011",         -- DEC
        std_logic_vector(signed(A) + signed(B)) when "0110", -- ADD
        std_logic_vector(signed(A) - signed(B)) when "0111", -- SUB
        std_logic_vector(signed(A) - signed(B)) when "1011", -- COM
        -- other operations...
        (others => '0') when others;

    with sel select
        Result2 <=
        B when "1111",
        (others => '0') when others;

    Zero <=
        '1' when temp = std_logic_vector(to_signed(0, temp'length)) else
        '0';

    with sel select
        Carry <=
        (not temp(31) and (A(31))) when "0010",                                            -- INC
        (not A(31) and (temp(31))) when "0011",                                            -- DEC
        (not temp(31) and (A(31) or B(31))) or (temp(31) and A(31) and B(31)) when "0110", -- ADD
        (not A(31) and (temp(31) or B(31))) or (A(31) and temp(31) and B(31)) when "0111", -- SUB
        '0' when others;
    -- Carry <=
    --     '1' when (sel = "0110" and A_sign = '1' and B_sign = '1') or -- ADD
    --     (sel = "0010" and A_sign /= Result_sign) or                  -- INC
    --     (sel = "0011" and A = X"00000000") or                        -- DEC
    --     (sel = "0111" and signed(A) > signed(B)) else                -- SUB
    --     '0';

    Negative <= Result_sign;

    with sel select
        Overflow <=
        (A(31) xnor '0') and (temp(31) xor A(31)) when "0010" | "0011",  -- INC, DEC
        (A(31) xnor B(31)) and (temp(31) xor A(31))when "0110" | "0111", -- ADD, SUB
        '0' when others;
    -- Overflow <=
    --     '1' when (sel = "0010" and A_sign /= Result_sign) or              -- INC
    --     (sel = "0011" and A_sign /= Result_sign) or                       -- DEC
    --     (sel = "0110" and A_sign = B_sign and A_sign /= Result_sign) or   -- ADD
    --     (sel = "0111" and A_sign /= B_sign and B_sign = Result_sign) or   -- SUB
    --     (sel = "1011" and A_sign /= B_sign and A_sign = Result_sign) else -- CMP
    --     '0';

    flags(0) <= Zero;
    flags(1) <= Negative;
    flags(2) <= Carry;
    flags(3) <= Overflow;
    Result1  <= temp;

end architecture ALUArch;
