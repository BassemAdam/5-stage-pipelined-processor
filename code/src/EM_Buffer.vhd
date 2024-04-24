library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EM_Buffer is
    port (   
        clk, reset, WE : in  std_logic;
        Dst_in : in  std_logic_vector(2 downto 0);
        Dst_in_2 : in  std_logic_vector(2 downto 0);
        ALU_OutValue_in : in  std_logic_vector(31 downto 0);
        ALU_OutValue_in_2 : in  std_logic_vector(31 downto 0);
        EM_we_reg_in : in std_logic;
        EM_we_reg_in_2 : in std_logic;
        EM_AluOrMem_in : in std_logic;
        
        EM_AluOrMem_out : out std_logic;
        EM_we_reg_out : out std_logic;
        EM_we_reg_out_2 : out std_logic;
        ALU_OutValue_out : out std_logic_vector(31 downto 0);
        ALU_OutValue_out_2 : out std_logic_vector(31 downto 0);
        Dst_out : out std_logic_vector(2 downto 0);
        Dst_out_2 : out std_logic_vector(2 downto 0)
    );
end entity EM_Buffer;

architecture EM_Buffer_Arch of EM_Buffer is
begin 
    process(clk, reset)
    begin
        if reset = '1' then
            EM_we_reg_out <= '0';
            EM_we_reg_out_2 <= '0';
            EM_AluOrMem_out <= '0';
            ALU_OutValue_out <= (others => '0');
            ALU_OutValue_out_2 <= (others => '0');
            Dst_out <= (others => '0');
            Dst_out_2 <= (others => '0'); 
        elsif falling_edge(clk) then
            if WE = '1' then
                EM_AluOrMem_out <= EM_AluOrMem_in;
                EM_we_reg_out <= EM_we_reg_in;
                EM_we_reg_out_2 <= EM_we_reg_in_2;
                ALU_OutValue_out <= ALU_OutValue_in;
                ALU_OutValue_out_2 <= ALU_OutValue_in_2;
                Dst_out <= Dst_in;
                Dst_out_2 <= Dst_in_2;
            end if;
        end if;
    end process;
end architecture EM_Buffer_Arch;