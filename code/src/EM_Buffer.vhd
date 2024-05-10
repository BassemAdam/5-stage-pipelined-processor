library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EM_Buffer is
    port (
        clk, RES, WE : in std_logic;

        -- Passing through
        EM_OUTport_en_out : out std_logic;
        EM_OUTport_en_in     : in std_logic;
        EM_ALUorMem_in    : in std_logic;
        EM_ALUorMem_out   : out std_logic;
        EM_we1_reg_in     : in std_logic;
        EM_we1_reg_out    : out std_logic;
        EM_we2_reg_in     : in std_logic;
        EM_we2_reg_out    : out std_logic;
        EM_Rdst1_in        : in std_logic_vector(2 downto 0);
        EM_Rdst1_out       : out std_logic_vector(2 downto 0);
        EM_Rdst2_in        : in std_logic_vector(2 downto 0);
        EM_Rdst2_out       : out std_logic_vector(2 downto 0);
        EM_ALUResult1_in  : in std_logic_vector(31 downto 0);
        EM_ALUResult1_out : out std_logic_vector(31 downto 0);
        EM_ALUResult2_in  : in std_logic_vector(31 downto 0);
        EM_ALUResult2_out : out std_logic_vector(31 downto 0);

        --MEMORY OPERATIONS SIGNALS
        EM_MemW_in : IN STD_LOGIC;
        EM_MemW_out : OUT STD_LOGIC;
        EM_MemR_in : IN STD_LOGIC;
        EM_MemR_out : OUT STD_LOGIC;
        EM_Push_in : IN STD_LOGIC;
        EM_Push_out : OUT STD_LOGIC;
        EM_Pop_in : IN STD_LOGIC;
        EM_Pop_out : OUT STD_LOGIC;
        EM_Protect_in : IN STD_LOGIC;
        EM_Protect_out : OUT STD_LOGIC;
        EM_Free_in : IN STD_LOGIC;
        EM_Free_out : OUT STD_LOGIC
        --END MEMORY OPERATIONS SIGNALS
        );
end entity EM_Buffer;

architecture EM_Buffer_Arch of EM_Buffer is
begin
    process (clk, RES)
    begin
        if RES = '1' then
            EM_we1_reg_out    <= '0';
            EM_we2_reg_out    <= '0';
            EM_ALUorMem_out   <= '0';
            EM_ALUResult1_out <= (others => '0');
            EM_ALUResult2_out <= (others => '0');
            EM_Rdst1_out       <= (others => '0');
            EM_Rdst2_out       <= (others => '0');
            EM_OUTport_en_out <= '0';
            --MEMORY OPERATIONS SIGNALS
            EM_MemW_out <= '0';
            EM_MemR_out <= '0';
            EM_Push_out <= '0';
            EM_Pop_out <= '0';
            EM_Protect_out <= '0';
            EM_Free_out <= '0';
            --END MEMORY OPERATIONS SIGNALS
        elsif falling_edge(clk) then
            if WE = '1' then
                EM_OUTport_en_out <= EM_OUTport_en_in;
                EM_ALUorMem_out   <= EM_ALUorMem_in;
                EM_we1_reg_out    <= EM_we1_reg_in;
                EM_we2_reg_out    <= EM_we2_reg_in;
                EM_ALUResult1_out <= EM_ALUResult1_in;
                EM_ALUResult2_out <= EM_ALUResult2_in;
                EM_Rdst1_out       <= EM_Rdst1_in;
                EM_Rdst2_out       <= EM_Rdst2_in;
                --MEMORY OPERATIONS SIGNALS
                EM_MemW_out <= EM_MemW_in;
                EM_MemR_out <= EM_MemR_in;
                EM_Push_out <= EM_Push_in;
                EM_Pop_out <= EM_Pop_in;
                EM_Protect_out <= EM_Protect_in;
                EM_Free_out <= EM_Free_in;
                --END MEMORY OPERATIONS SIGNALS

            end if;
        end if;
    end process;
end architecture EM_Buffer_Arch;
