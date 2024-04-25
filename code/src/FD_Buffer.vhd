library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity FD_Buffer is
    port (
        clk     : in std_logic;
        RES     : in std_logic;
        WE      : in std_logic;
        FD_Inst : in std_logic_vector(15 downto 0); -- 16 bits from instruction memory

        FD_OpCode : out std_logic_vector(2 downto 0);
        FD_Rsrc1  : out std_logic_vector(2 downto 0);
        FD_Rsrc2  : out std_logic_vector(2 downto 0);
        FD_Rdst1  : out std_logic_vector(2 downto 0);
        FD_Rdst2  : out std_logic_vector(2 downto 0);
        FD_Func   : out std_logic_vector(3 downto 0);

        -- Passing through
        FD_isImm_in  : in std_logic;
        FD_isImm_out : out std_logic;
        FD_Imm_in    : in std_logic_vector(15 downto 0);
        FD_Imm_out   : out std_logic_vector(15 downto 0)
    );
end entity FD_Buffer;

architecture Behavioral of FD_Buffer is

begin
    process (CLK, RES)
    begin
        if RES = '1' then
            -- Asynchronous RES
            FD_OpCode <= (others => '0');
            FD_Rsrc1  <= (others => '0');
            FD_Rsrc2  <= (others => '0');
            FD_Rdst1  <= (others => '0');
            FD_Rdst2  <= (others => '0');
            FD_Func   <= (others => '0');
        elsif falling_edge(clk) and WE = '1' then

            FD_OpCode <= FD_Inst(15 downto 13);
            FD_Rdst1  <= FD_Inst(12 downto 10);
            FD_Rdst2  <= FD_Inst(9 downto 7);
            FD_Rsrc1  <= FD_Inst(9 downto 7);
            FD_Rsrc2  <= FD_Inst(6 downto 4);
            FD_Func   <= FD_Inst(3 downto 0);

            if FD_isImm_in = '1' then
                FD_Imm_out <= FD_Imm_in;
            end if;

            FD_isImm_out <= FD_isImm_in;
        end if;
    end process;

end architecture Behavioral;
