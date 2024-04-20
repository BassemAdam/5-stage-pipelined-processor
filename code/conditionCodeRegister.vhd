library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity conditionCodeRegister is
    port (
        rst : in std_logic;
        cin : in std_logic;
        ovf : in std_logic;
        opResult : in std_logic_vector(31 downto 0);
        
        flags : out std_logic_vector(3 downto 0)
    );
end entity conditionCodeRegister;

architecture conditionCodeRegisterArch of conditionCodeRegister is

    begin
        process (rst, cin, ovf, opResult)
        begin
        if rst = '1' then
            flags <= "0000";
        end if;
        
        --zero flag
        if opResult = X"00000000" then
            flags(0) <= '1';
        end if;

        --negative flag
        if opResult(31) = '1' then
            flags(1) <= '1';
        end if;

        --carry flag
        if cin = '1' then
            flags(2) <= '1';
        end if;

        --overflow flag
        if ovf = '1' then
            flags(3) <= '1';
        end if;

    end process;

    end architecture conditionCodeRegisterArch;
