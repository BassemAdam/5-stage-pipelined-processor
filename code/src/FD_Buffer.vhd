library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity FD_Buffer is
    port (
        clk, RES : in std_logic;
        WE       : in std_logic;
        --16 bits from instruction memory
        Inst : in std_logic_vector(15 downto 0);

        FD_isImm_in : in std_logic;
        FD_Imm_in   : in std_logic_vector(15 downto 0);

        OpCode : out std_logic_vector(2 downto 0);
        Src1   : out std_logic_vector(2 downto 0);
        Src2   : out std_logic_vector(2 downto 0);
        dst1   : out std_logic_vector(2 downto 0);
        dst2   : out std_logic_vector(2 downto 0);
        Func   : out std_logic_vector(3 downto 0);

        FD_isImm_out : out std_logic;
        FD_Imm_out   : out std_logic_vector(15 downto 0)
    );
end entity FD_Buffer;

architecture Behavioral of FD_Buffer is

begin
    process (CLK, RES)
    begin
        if RES = '1' then
            -- Asynchronous RES
            OpCode <= (others => '0');
            Src1   <= (others => '0');
            Src2   <= (others => '0');
            dst1   <= (others => '0');
            dst2   <= (others => '0');
            Func   <= (others => '0');
        elsif falling_edge(clk) and WE = '1' then

            OpCode <= Inst(15 downto 13);
            dst1   <= Inst(12 downto 10);
            dst2   <= Inst(9 downto 7);
            Src1   <= Inst(9 downto 7);
            Src2   <= Inst(6 downto 4);
            Func   <= Inst(3 downto 0);

            if FD_isImm_in = '1' then
                FD_Imm_out <= FD_Imm_in;
            end if;

            FD_isImm_out <= FD_isImm_in;
        end if;
    end process;

end architecture Behavioral;
