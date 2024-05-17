library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MemoryUse is --for load and pop
    port (
        RES : in std_logic;
        DE_Ctrl_MemRead : in std_logic;
        DE_src1 : in std_logic_vector(2 downto 0);
        DE_src2 : in std_logic_vector(2 downto 0);
        EM_dst : in std_logic_vector(2 downto 0);
        stall : out std_logic
    );
end entity MemoryUse;

architecture HDU_Arch of MemoryUse is
begin
    process (RES, DE_Ctrl_MemRead, DE_src1, DE_src2, EM_dst)
    begin
        if RES = '1' then
            stall <= '0';
        else
            -- Detect load-use hazard
            if DE_Ctrl_MemRead = '1' and (EM_dst = DE_src1 or EM_dst = DE_src2) then
                stall <= '1';  -- Stall the pipeline
            else
                stall <= '0';  -- No hazard detected
            end if;
        end if;
    end process;
end architecture HDU_Arch;