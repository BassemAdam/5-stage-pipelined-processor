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

        data : BUFFER STD_LOGIC_VECTOR(n - 1 DOWNTO 0); --so that i can read and write to
        immediate_out : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        IsImmediate : Out STD_LOGIC;
        correctedPc : OUT STD_LOGIC_VECTOR(k - 1 DOWNTO 0)
    );
END InstrCache;

ARCHITECTURE Behavioral OF InstrCache IS

    TYPE ram_type IS ARRAY (0 TO 2 ** m - 1) OF STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL ram : ram_type;

    begin

        process (clk, rst)
            variable temp_data : std_logic_vector(n - 1 downto 0);
        begin
            if rising_edge(clk) then
                if to_integer(unsigned(pc)) < 2 ** m then
                    temp_data := ram(to_integer(unsigned(pc)));
                    data <= temp_data;
                    IsImmediate <= '0';
                    IF temp_data(15 DOWNTO 13) = "010" THEN
                        immediate_out <= ram(to_integer(unsigned(pc)) + 1);
                        IsImmediate <= '1';
                        correctedPc <= std_logic_vector(unsigned(pc) + 2);
                      END IF;
                end if;
            end if;
        end process;

END ARCHITECTURE Behavioral;
