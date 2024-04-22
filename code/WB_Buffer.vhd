library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WB_Buffer is
    port (
        clk, reset, WE : in std_logic;
        --ALU_COUT : in std_logic;
        Dst_in          : in std_logic_vector(2 downto 0);
        Dst_in_2          : in std_logic_vector(2 downto 0);
        ALU_OutValue_in : in std_logic_vector(31 downto 0);
        ALU_OutValue_in_2 : in std_logic_vector(31 downto 0);
        MemOutValue_in  : in std_logic_vector(31 downto 0);
        WB_we_reg_in    : in std_logic;
        WB_we_reg_in_2    : in std_logic;
        WB_AluOrMem_in  : in std_logic;

        WB_we_reg_out : out std_logic;
        WB_we_reg_out_2 : out std_logic;
        --ALU_COUT_OUT : out std_logic;
        WB_value_out : out std_logic_vector(31 downto 0);
        WB_value_out_2 : out std_logic_vector(31 downto 0);
        Dst_out      : out std_logic_vector(2 downto 0);
        Dst_out_2      : out std_logic_vector(2 downto 0)
    );
end entity WB_Buffer;

architecture WB_Buffer_Arch of WB_Buffer is
begin
    process (clk, reset)
    begin
        if reset = '1' then
            WB_we_reg_out    <= '0';
            WB_we_reg_out_2    <= '0';
            WB_value_out <= (others => '0');
            WB_value_out_2 <= (others => '0');
            Dst_out          <= (others => '0');
            Dst_out_2          <= (others => '0');
        elsif falling_edge(clk) then
            if WE = '1' then
                if (WB_AluOrMem_in = '1') then
                    WB_value_out <= MemOutValue_in;
                else
                    WB_value_out <= ALU_OutValue_in;
                    WB_value_out_2 <= ALU_OutValue_in_2;
                end if;
                WB_we_reg_out    <= WB_we_reg_in;
                WB_we_reg_out_2    <= WB_we_reg_in_2;
                Dst_out          <= Dst_in;
                Dst_out_2          <= Dst_in_2;
            end if;
        end if;
    end process;
end architecture WB_Buffer_Arch;
