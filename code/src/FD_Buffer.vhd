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
        FD_IN_PORT : in std_logic_vector(31 downto 0); 

        FD_OpCode : out std_logic_vector(2 downto 0);
        FD_Rsrc1  : out std_logic_vector(2 downto 0);
        FD_Rsrc2  : out std_logic_vector(2 downto 0);
        FD_Rdst1  : out std_logic_vector(2 downto 0);
        FD_Rdst2  : out std_logic_vector(2 downto 0);
        FD_Func   : out std_logic_vector(3 downto 0);
        FD_InputPort : out std_logic_vector(31 downto 0);

        -- Passing through
        FD_isImm_in  : in std_logic
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

            FD_Rdst1  <= FD_Inst(12 downto 10);
            FD_Rdst2  <= FD_Inst(9 downto 7);
            FD_Rsrc1  <= FD_Inst(9 downto 7);
            FD_Rsrc2  <= FD_Inst(6 downto 4);
            FD_Func   <= FD_Inst(3 downto 0);
            FD_InputPort <= FD_IN_PORT;
            if FD_isImm_in = '1' then
                FD_OpCode <= "000";
            else
                FD_OpCode <= FD_Inst(15 downto 13);
            end if;
        end if;
    end process;

end architecture Behavioral;
