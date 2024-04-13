LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY InstrCache IS
    GENERIC (
        n : INTEGER := 16; -- number of bits per instruction
        m : INTEGER := 12; -- height of the cache
        k : INTEGER := 32 -- pc size
    );
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        pc : IN STD_LOGIC_VECTOR(k - 1 DOWNTO 0);
        data : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
    );
END InstrCache;
ARCHITECTURE Behavioral OF InstrCache IS
    TYPE ram_type IS ARRAY (0 TO 2 ** m - 1) OF STD_LOGIC_VECTOR(m - 1 DOWNTO 0);
    SIGNAL ram : ram_type;
    begin
        process (clk, rst)
        begin
            if rising_edge(clk) then
                if to_integer(unsigned(pc)) < 2 ** m then
                    data <= ram(to_integer(unsigned(pc)));
                end if;
            end if;
        end process;
END ARCHITECTURE Behavioral;