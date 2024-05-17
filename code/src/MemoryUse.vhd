library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MemoryUse is --for load and pop
    port (
        RES : in std_logic;
        DE_Ctrl_Pop_Flag : in std_logic;
        DE_src1 : in std_logic_vector(2 downto 0);
        DE_src2 : in std_logic_vector(2 downto 0);
        EM_dst : in std_logic_vector(2 downto 0);

        DE_SRC1_USE : IN STD_LOGIC;
        DE_SRC2_USE : IN STD_LOGIC;
        EM_WE : IN STD_LOGIC;

        stall_PopUse : out std_logic;
        flush_EM : out std_logic
    );
end entity MemoryUse;

architecture HDU_Arch of MemoryUse is
begin

    stall_PopUse <= '1' when DE_Ctrl_Pop_Flag = '1' and ((EM_dst = DE_src1 AND DE_SRC1_USE='1') or (EM_dst = DE_src2 AND DE_SRC2_USE='1')) and EM_WE ='1'  else '0';
    flush_EM <= '1' when DE_Ctrl_Pop_Flag = '1' and ((EM_dst = DE_src1 AND DE_SRC1_USE='1') or (EM_dst = DE_src2 AND DE_SRC2_USE='1')) and EM_WE ='1'  else '0';

end architecture HDU_Arch;