library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dataMemory is
    generic(
        DATA_WIDTH : integer := 32;
        ADDR_WIDTH : integer := 12
    );
    
    port(
    rst : in std_logic;
    clk : in std_logic;
    memWrite : in std_logic;
    memRead : in std_logic;
    writeAddress : in unsigned(ADDR_WIDTH - 1 downto 0);
    readAddress : in unsigned(ADDR_WIDTH - 1 downto 0);
    writeData : in unsigned(DATA_WIDTH - 1 downto 0);
    readData : out unsigned(DATA_WIDTH - 1 downto 0)
);
end entity dataMemory;

architecture dataMemory_arch of dataMemory is
    type memory is array(0 to 2 ** ADDR_WIDTH - 1) of unsigned(DATA_WIDTH -1 downto 0);
    signal mem : memory := (others => (others => '0'));
begin
    process(clk, rst)
    begin
        if rst = '1' then
            mem <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if memWrite = '1' then
                mem(to_integer(writeAddress)) <= writeData;
            end if;
            if memRead = '1' then
                readData <= mem(to_integer(readAddress));
            end if;
        end if;
    end process;
end architecture dataMemory_arch;

