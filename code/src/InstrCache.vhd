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

        IC_isImm       : out std_logic;
        IC_Imm         : out std_logic_vector(n - 1 downto 0);
        IC_data        : buffer std_logic_vector(n - 1 downto 0); --so that i can read and write to
        IC_correctedPC : out std_logic_vector(k - 1 downto 0)
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
                temp_data := ram(to_integer(unsigned(IC_PC)));
                IC_data  <= temp_data;
                IC_isImm <= '0';
                if temp_data(15 downto 13) = "010" then
                    IC_Imm         <= ram(to_integer(unsigned(IC_PC)) + 1);
                    IC_isImm       <= '1';
                    IC_correctedPC <= std_logic_vector(unsigned(IC_PC) + 2);
                end if;
            end if;
        end if;
    end process;

end architecture Behavioral;
