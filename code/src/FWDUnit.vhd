LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY FWDUnit IS
    PORT (
        RES, WE : IN STD_LOGIC;

        FWD_src1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        FWD_src2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        FWD_src1_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        FWD_src2_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        FWD_dst1Exec : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        FWD_wb1Exec : IN STD_LOGIC;

        FWD_Data1Exec : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        FWD_Data2Exec : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        FWD_dst2Exec : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        FWD_wb2Exec : IN STD_LOGIC;

        FWD_Data1Mem : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        FWD_Data2Mem : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        FWD_dst1Mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        FWD_wb1Mem : IN STD_LOGIC;
        FWD_dst2Mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        FWD_wb2Mem : IN STD_LOGIC;

        ctr_src1_use : IN STD_LOGIC;
        ctr_src2_use : IN STD_LOGIC;

        ctr_STD_use : IN STD_LOGIC;
        FWD_STD_val : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        --for std 
        FWD_STD_src : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        FWD_ALU_OPD_1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        FWD_ALU_OPD_2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        FWD_STD_Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)

    );
END ENTITY FWDUnit;

ARCHITECTURE FWD_Arch OF FWDUnit IS
BEGIN

    FWD_ALU_OPD_1 <=
        FWD_Data1Exec WHEN (FWD_dst1Exec = FWD_src1 AND FWD_wb1Exec = '1' AND ctr_src1_use = '1') ELSE
        FWD_Data2Exec WHEN (FWD_dst2Exec = FWD_src1 AND FWD_wb2Exec = '1' AND ctr_src1_use = '1') ELSE
        FWD_Data1Mem WHEN (FWD_dst1Mem = FWD_src1 AND FWD_wb1Mem = '1' AND ctr_src1_use = '1') ELSE
        FWD_Data2Mem WHEN (FWD_dst2Mem = FWD_src1 AND FWD_wb2Mem = '1' AND ctr_src1_use = '1') ELSE
        FWD_src1_Data;

    FWD_ALU_OPD_2 <=
        FWD_Data1Exec WHEN (FWD_dst1Exec = FWD_src2 AND FWD_wb1Exec = '1' AND ctr_src2_use = '1') ELSE
        FWD_Data2Exec WHEN (FWD_dst2Exec = FWD_src2 AND FWD_wb2Exec = '1' AND ctr_src2_use = '1') ELSE
        FWD_Data1Mem WHEN (FWD_dst1Mem = FWD_src2 AND FWD_wb1Mem = '1' AND ctr_src2_use = '1') ELSE
        FWD_Data2Mem WHEN (FWD_dst2Mem = FWD_src2 AND FWD_wb2Mem = '1' AND ctr_src2_use = '1') ELSE
        FWD_src2_Data;

    FWD_STD_Data <=
        FWD_Data1Exec WHEN (FWD_dst1Exec = FWD_STD_src AND FWD_wb1Exec = '1' AND ctr_STD_use = '1') ELSE
        FWD_Data2Exec WHEN (FWD_dst2Exec = FWD_STD_src AND FWD_wb2Exec = '1' AND ctr_STD_use = '1') ELSE
        FWD_Data1Mem WHEN (FWD_dst1Mem = FWD_STD_src AND FWD_wb1Mem = '1' AND ctr_STD_use = '1') ELSE
        FWD_Data2Mem WHEN (FWD_dst2Mem = FWD_STD_src AND FWD_wb2Mem = '1' AND ctr_STD_use = '1') ELSE
        FWD_STD_val;
END ARCHITECTURE FWD_Arch;