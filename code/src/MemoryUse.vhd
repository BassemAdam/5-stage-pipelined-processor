library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MemoryUse is --for load and pop
    port (
        RES : in std_logic;
        DE_Ctrl_Pop_Flag : in std_logic;
        FD_src1 : in std_logic_vector(2 downto 0);
        FD_src2 : in std_logic_vector(2 downto 0);
        DE_dst : in std_logic_vector(2 downto 0);

        FD_SRC1_USE : IN STD_LOGIC;
        FD_SRC2_USE : IN STD_LOGIC;
        DE_WE : IN STD_LOGIC;

        stall_PopUse : out std_logic;
        flush_DM : out std_logic
    );
end entity MemoryUse;

architecture HDU_Arch of MemoryUse is
begin

    stall_PopUse <= '1' when DE_Ctrl_Pop_Flag = '1' and ((DE_dst = FD_src1 AND FD_SRC1_USE='1') or (DE_dst = FD_src2 AND FD_SRC2_USE='1')) and DE_WE ='1'  else '0';
    flush_DM <= '1' when DE_Ctrl_Pop_Flag = '1' and ((DE_dst = FD_src1 AND FD_SRC1_USE='1') or (DE_dst = FD_src2 AND FD_SRC2_USE='1')) and DE_WE ='1'  else '0';

end architecture HDU_Arch;