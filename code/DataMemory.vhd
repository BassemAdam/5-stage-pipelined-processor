library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dataMemory is port(
    rst : in std_logic;
    clk : in std_logic;
    memWrite : in std_logic;
    memRead : in std_logic;
    writeAddress : in unsigned(11 downto 0);
    readAddress : in unsigned(11 downto 0);
    writeData : in unsigned(31 downto 0);
    readData : out unsigned(31 downto 0)
);
end entity dataMemory;

architecture dataMemory_arch of dataMemory is
    type memory is array(0 to 4095) of unsigned(31 downto 0);
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

