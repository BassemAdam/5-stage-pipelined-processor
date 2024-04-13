library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controller is
    generic(
        INST_WIDTH: integer := 16
    );
    port(
        clk: in std_logic;
        rst: in std_logic;
        instruction: in std_logic_vector(INST_WIDTH -1 downto 0);
        opCode: out std_logic_vector(6 downto 0);
        Rsrc1: out std_logic_vector(2 downto 0);
        Rsrc2: out std_logic_vector(2 downto 0);
        Rdest: out std_logic_vector(2 downto 0);
        hasImm: out std_logic;
        isBranch: out std_logic
       
    );
end entity controller;

architecture controllerArch of controller is

    

   begin
    -- reset
    opCode <= (others => '0') when rst = '1' else
   instruction(6 downto 0);

    hasImm <= '0' when rst = '1' else
    instruction(5);

    isBranch <= '0' when rst = '1' else
    instruction(6);

    Rsrc1 <= (others => '0') when rst = '1' else
    instruction(9 downto 7);

    Rsrc2 <= (others => '0') when rst = '1' else
    instruction(12 downto 10);

    Rdest <= (others => '0') when rst = '1' else
    instruction(15 downto 13);

    
   end architecture controllerArch;    