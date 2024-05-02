library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity InstrCache is
    generic (
        n : integer := 16; -- number of bits per instruction
        m : integer := 12; -- height of the cache
        k : integer := 32  -- pc size
    );
    port (
        clk, RES : in std_logic;
        IC_PC    : in std_logic_vector(k - 1 downto 0);

        IC_data        : out std_logic_vector(n - 1 downto 0) --so that i can read and write to
    );
end InstrCache;

architecture Behavioral of InstrCache is

    type ram_type is array (0 to 2 ** m - 1) of std_logic_vector(n - 1 downto 0);
    signal ram : ram_type;

begin

    process (clk, RES)
        variable temp_data : std_logic_vector(n - 1 downto 0);
    begin
        if rising_edge(clk) then
            if to_integer(unsigned(IC_PC)) < 2 ** m then
                IC_data <= ram(to_integer(unsigned(IC_PC)));
            end if;
        end if;
    end process;

end architecture Behavioral;
