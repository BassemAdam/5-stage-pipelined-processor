library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity nBuffer is
    generic (
        N : positive := 16 --instruction width
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        din : in std_logic_vector(N-1 downto 0);
        dout : out std_logic_vector(N-1 downto 0)
    );
end entity nBuffer;


architecture mBufferArch of nBuffer is
    signal hold_dout : std_logic_vector(N-1 downto 0);
    
begin
    
    process(clk, rst)
    begin
        if rst = '1' then
            dout <= (others => '0');
            hold_dout <= (others => '0');
        elsif rising_edge(clk) then --read on rising edge
            dout <= hold_dout;
        elsif falling_edge(clk) then --write on falling edge
            hold_dout <= din;    
        end if;
    end process;
    
end architecture mBufferArch;
