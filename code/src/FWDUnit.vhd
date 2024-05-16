library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FWD is
    port (
        clk, RES, WE : in std_logic;
        FWD_src1 : in std_logic_vector(2 downto 0);
        FWD_src2 : in std_logic_vector(2 downto 0);
        FWD_dstExec : in std_logic_vector(2 downto 0);
        FWD_wbExec : in std_logic;
        FWD_dstMem : in std_logic_vector(2 downto 0);
        FWD_wbMem : in std_logic;
        FWD_ALU_ALU_src1 : out std_logic;
        FWD_ALU_ALU_src2 : out std_logic;
        FWD_ALU_MEM_src1 : out std_logic;
        FWD_ALU_MEM_src2 : out std_logic
        );
end entity FWD;

architecture FWD_Arch of FWD is
begin
    process (clk, RES)
    begin
        if RES = '1' then
            FWD_ALU_ALU_src1 <= '0';
            FWD_ALU_ALU_src2 <= '0';
            FWD_ALU_MEM_src1 <= '0';
            FWD_ALU_MEM_src2 <= '0';
        elsif rising_edge(clk) then
            if WE = '1' then
                if FWD_wbExec ='1' and FWD_dstExec = FWD_src1 then
                    FWD_ALU_ALU_src1 <= '1';
                else
                    FWD_ALU_ALU_src1 <= '0';
                end if;
                if FWD_wbExec ='1' and FWD_dstExec = FWD_src2 then
                    FWD_ALU_ALU_src2 <= '1';
                else
                    FWD_ALU_ALU_src2 <= '0';
                end if;

                if FWD_wbMem = '1' and  FWD_dstMem = FWD_src1  then
                    FWD_ALU_MEM_src1 <= '1';
                else
                    FWD_ALU_MEM_src1 <= '0';
                end if;

                if FWD_wbMem = '1' and  FWD_dstMem = FWD_src2  then
                    FWD_ALU_MEM_src2 <= '1';
                else
                    FWD_ALU_MEM_src2 <= '0';
                end if ;
            end if;
        end if;
    end process;
end architecture FWD_Arch;
