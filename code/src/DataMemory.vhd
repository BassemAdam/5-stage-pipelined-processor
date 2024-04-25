library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DataMemory is
    generic (
        DATA_WIDTH : integer := 16;
        ADDR_WIDTH : integer := 12
    );

    port (
        clk, RES : in std_logic;
        DM_MemR  : in std_logic;
        DM_MemW  : in std_logic;
        DM_RAddr : in unsigned(ADDR_WIDTH - 1 downto 0);
        DM_WAddr : in unsigned(ADDR_WIDTH - 1 downto 0);
        DM_WData : in unsigned(DATA_WIDTH - 1 downto 0);

        DM_RData : out unsigned(DATA_WIDTH - 1 downto 0)
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

            if DM_MemW = '1' then
                mem(to_integer(DM_WAddr))     <= DM_WData(15 downto 0);
                mem(to_integer(DM_WAddr) + 1) <= DM_WData(31 downto 16);
            end if;

            if DM_MemR = '1' then
                DM_RData <= mem(to_integer(DM_RAddr));
            end if;

        end if;

    end process;
end architecture DataMemory_arch;
