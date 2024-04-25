library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity PC is
    generic (
        N : integer := 32
    );
    port (
        clk, RES : in std_logic;
        branch   : in std_logic;
        enable   : in std_logic;
        pcBranch : in std_logic_vector(N - 1 downto 0);

        isImmFromInstr : in std_logic;
        correctedPc    : in std_logic_vector(N - 1 downto 0);

        pc : out std_logic_vector(N - 1 downto 0)
    );
end entity PC;

architecture PC_ARCH of PC is

    signal pcNext          : std_logic_vector(N - 1 downto 0);
    signal lastCorrectedPc : std_logic_vector(N - 1 downto 0);

begin

    process (RES, clk, correctedPc)
    begin
        if RES = '1' then
            pcNext <= (others => '0');

        elsif falling_edge(clk) then

            if isImmFromInstr = '1' and correctedPc /= lastCorrectedPc then
                pcNext          <= correctedPc;
                lastCorrectedPc <= correctedPc;

            elsif branch = '1' then
                pcNext <= pcBranch;

            elsif enable = '1' then
                pcNext <= std_logic_vector(unsigned(pcNext) + 1);
            end if;

        end if;
    end process;

    pc <= pcNext;

end architecture PC_ARCH;
