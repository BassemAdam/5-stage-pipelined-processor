library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FD_Buffer is
    port (
        clk : in std_logic;
        reset : in std_logic;
        IC_Stream : in std_logic_vector(31 downto 0); --incoming data from instruction memory
        opCode : out std_logic_vector(6 downto 0); --opcode
        Rsrc1 : out std_logic_vector(2 downto 0); --source register 1
        Rsrc2 : out std_logic_vector(2 downto 0); --source register 2
        Rdest : out std_logic_vector(2 downto 0); --destination register
        immediate : out std_logic_vector(15 downto 0) --immediate value
    );
end entity FD_Buffer;


--Fecth decode buffer reads in rising edge and  writes in falling edge
architecture fd_arch of FD_Buffer is
    signal IC_Stream_reg : std_logic_vector(31 downto 0);
    begin
        process(clk,reset)
        begin
            if reset = '1' then
                opCode <= (others => '0');
                Rsrc1 <= (others => '0');
                Rsrc2 <= (others => '0');
                Rdest <= (others => '0');
            elsif rising_edge(clk) then
                opCode <= IC_Stream_reg(0 to 6);
                Rsrc1 <= IC_Stream_reg(7 to 9);
                Rsrc2 <= IC_Stream_reg(10 to 12);
                Rdest <= IC_Stream_reg(13 to 15);
                immediate <= IC_Stream_reg(16 to 31);
            elsif falling_edge(clk) then
                IC_Stream_reg <= IC_Stream;
            end if;        

        end process;    
end architecture fd_arch;    
