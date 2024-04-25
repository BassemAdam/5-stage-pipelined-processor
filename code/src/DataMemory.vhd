library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DataMemory is
    generic (
        DATA_WIDTH : integer := 16;
        ADDR_WIDTH : integer := 12
    );

    port (
        clk, RES  : in std_logic;
        memWrite  : in std_logic;
        memRead   : in std_logic;
        writeAddr : in unsigned(ADDR_WIDTH - 1 downto 0);
        readAddr  : in unsigned(ADDR_WIDTH - 1 downto 0);
        writeData : in unsigned(DATA_WIDTH - 1 downto 0);

        readData : out unsigned(DATA_WIDTH - 1 downto 0)
    );
end entity DataMemory;

architecture DataMemory_arch of dataMemory is

    type memory is array(0 to 2 ** ADDR_WIDTH - 1) of unsigned(DATA_WIDTH - 1 downto 0);
    signal mem : memory := (others => (others => '0'));

begin
    process (clk, RES)
    begin

        if RES = '1' then
            mem <= (others => (others => '0'));

        elsif rising_edge(clk) then

            if memWrite = '1' then
                mem(to_integer(writeAddr))     <= writeData(15 downto 0);
                mem(to_integer(writeAddr) + 1) <= writeData(31 downto 16);
            end if;

            if memRead = '1' then
                readData <= mem(to_integer(readAddr));
            end if;
            
        end if;

    end process;
end architecture DataMemory_arch;
