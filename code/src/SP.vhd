library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--stack pointer that starts from address 2^12-1 and decrements by 2
entity SP is
    generic(
        WIDTH: integer := 12
    );
    port(
    reset: in std_logic;
    push: in std_logic;
    pop: in std_logic;
    pointer: out std_logic_vector(WIDTH - 1 downto 0)
);
end SP;

architecture SPArch of SP is

    signal sp: unsigned(WIDTH -1 downto 0);

begin

    process(reset, push, pop)
    begin
        if reset = '1' then
            sp <= to_unsigned(2 ** WIDTH - 1, sp'length);  -- Initialize to 2^12-1
        elsif push = '1' and sp /= to_unsigned(0, sp'length) then
            sp <= sp - 2;  -- Decrement by 2 on push
        elsif pop = '1' and sp /= to_unsigned(0, sp'length) then
            sp <= sp + 2;  -- Increment by 2 on pop
        end if;
    end process;

    pointer <= std_logic_vector(sp);
    
end SPArch;
