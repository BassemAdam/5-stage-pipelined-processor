LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MemoryUse IS --for load and pop
    PORT (
        RES : IN STD_LOGIC;
        DE_Ctrl_Pop_Flag : IN STD_LOGIC;
        FD_src1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        FD_src2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        DE_dst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        FD_SRC1_USE : IN STD_LOGIC;
        FD_SRC2_USE : IN STD_LOGIC;
        DE_WE : IN STD_LOGIC;

        stall_PopUse : OUT STD_LOGIC;
        flush_DM : OUT STD_LOGIC
    );
END ENTITY MemoryUse;

ARCHITECTURE HDU_Arch OF MemoryUse IS
BEGIN

    stall_PopUse <= '1' WHEN DE_Ctrl_Pop_Flag = '1' AND ((DE_dst = FD_src1 AND FD_SRC1_USE = '1') OR (DE_dst = FD_src2 AND FD_SRC2_USE = '1')) AND DE_WE = '1' ELSE
        '0';
    flush_DM <= '1' WHEN DE_Ctrl_Pop_Flag = '1' AND ((DE_dst = FD_src1 AND FD_SRC1_USE = '1') OR (DE_dst = FD_src2 AND FD_SRC2_USE = '1')) AND DE_WE = '1' ELSE
        '0';

END ARCHITECTURE HDU_Arch;