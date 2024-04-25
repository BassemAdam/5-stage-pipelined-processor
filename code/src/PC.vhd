library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity PC is
    generic (
        N : integer := 32
    );
    port (
        clk, RES    : in std_logic;
        PC_en       : in std_logic;
        PC_branch   : in std_logic;
        PC_branchPC : in std_logic_vector(N - 1 downto 0);

        PC_isImm       : in std_logic;
        PC_correctedPC : in std_logic_vector(N - 1 downto 0);

        PC_PC : out std_logic_vector(N - 1 downto 0)
    );
end entity PC;

architecture PC_ARCH of PC is

    signal pcNext          : std_logic_vector(N - 1 downto 0);
    signal lastCorrectedPc : std_logic_vector(N - 1 downto 0);

begin

    process (RES, clk, PC_correctedPC)
    begin
        if RES = '1' then
            pcNext <= (others => '0');

        elsif falling_edge(clk) then

            if PC_isImm = '1' and PC_correctedPC /= lastCorrectedPc then
                pcNext          <= PC_correctedPC;
                lastCorrectedPc <= PC_correctedPC;

            elsif PC_branch = '1' then
                pcNext <= PC_branchPC;

            elsif PC_en = '1' then
                pcNext <= std_logic_vector(unsigned(pcNext) + 1);
            end if;

        end if;
    end process;

    PC_PC <= pcNext;

end architecture PC_ARCH;
