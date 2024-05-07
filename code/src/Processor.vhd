library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Processor is
    port (
        clk       : in std_logic;
        reset, we : in std_logic;
        INT_In    : in std_logic; -- interrupt signal
        IN_PORT   : in std_logic_vector(7 downto 0);

        exception : out std_logic; -- exception signal
        OUT_PORT  : out std_logic_vector(7 downto 0)
    );
end entity Processor;

architecture ProcessorArch of Processor is

    ------------------------------------COMPONENTS------------------------------------
    component PC is
        GENERIC (
            N : INTEGER := 32
        );
        PORT (
            clk, RES : IN STD_LOGIC;
            PC_en : IN STD_LOGIC;
            PC_Interrupt : IN STD_LOGIC;
            PC_branch : IN STD_LOGIC;
            PC_branchPC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            PC_InterruptPC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            PC_ResetPC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            
            PC_PC : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    end component;

    component InstrCache is
        generic (
            n : integer := 16; -- number of bits per instruction
            m : integer := 12; -- height of the cache
            k : integer := 32  -- pc size
        );
        port (
            clk, RES : in std_logic;
            IC_PC    : in std_logic_vector(k - 1 downto 0);
    
            IC_data        : out std_logic_vector(n - 1 downto 0); --so that i can read and write to
            PC_Reset       : out std_logic_vector(k - 1 downto 0); --to reset the PC
            PC_Interrupt   : out std_logic_vector(k - 1 downto 0) --to interrupt the PC
        );
    end component;

    component FD_Buffer is
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
            FD_isImm_in  : in std_logic
        );
    end component FD_Buffer;

    component RegisterFile is
        generic (
            w : integer := 3;
            n : integer := 32
        );
        port (
            clk, RES : in std_logic;

            RE_we1    : in std_logic;
            RF_we2    : in std_logic;
            RF_Rdst1  : in std_logic_vector(w - 1 downto 0);
            RF_Rdst2  : in std_logic_vector(w - 1 downto 0);
            RF_Wdata1 : in std_logic_vector(n - 1 downto 0);
            RF_Wdata2 : in std_logic_vector(n - 1 downto 0);

            RF_Rsrc1 : in std_logic_vector(w - 1 downto 0);
            RF_Rsrc2 : in std_logic_vector(w - 1 downto 0);

            RF_Rdata1 : out std_logic_vector(n - 1 downto 0);
            RF_Rdata2 : out std_logic_vector(n - 1 downto 0)
        );
    end component;

    component controller is
        generic (
            INST_WIDTH : integer := 16
        );
        port (
            clk        : in std_logic;
            RES        : in std_logic;
            ctr_opCode : in std_logic_vector(2 downto 0);
            ctr_Func   : in std_logic_vector(3 downto 0);

            ctr_hasImm   : out std_logic;
            ctr_ALUsel   : out std_logic_vector(3 downto 0);
            ctr_flags_en : out std_logic_vector(0 to 3);
            ctr_we1_reg  : out std_logic;
            ctr_we2_reg  : out std_logic;
            ctr_we_mem   : out std_logic;
            ctr_ALUorMem : out std_logic

            -- Passing through should be none its not a buffer
        );
    end component controller;

    component DE_Buffer is
        port (
            clk, RES, WE : in std_logic;
            DE_Rsrc1_Val : in std_logic_vector(31 downto 0);
            DE_Rsrc2_Val : in std_logic_vector(31 downto 0);
            DE_Imm       : in std_logic_vector(15 downto 0);
            DE_isImm     : in std_logic;

            DE_ALUopd1 : out std_logic_vector(31 downto 0);
            DE_ALUopd2 : out std_logic_vector(31 downto 0);

            -- Passing through
            DE_we1_reg_in   : in std_logic;
            DE_we1_reg_out  : out std_logic;
            DE_we2_reg_in   : in std_logic;
            DE_we2_reg_out  : out std_logic;
            DE_ALUorMem_in  : in std_logic;
            DE_ALUorMem_out : out std_logic;
            DE_flags_en_in  : in std_logic_vector (0 to 3);
            DE_flags_en_out : out std_logic_vector (0 to 3);
            DE_Rdst1_in     : in std_logic_vector(2 downto 0);
            DE_Rdst2_in     : in std_logic_vector(2 downto 0);
            DE_Rdst1_out    : out std_logic_vector(2 downto 0);
            DE_Rdst2_out    : out std_logic_vector(2 downto 0);
            DE_ALUsel_in    : in std_logic_vector(3 downto 0);
            DE_ALUsel_out   : out std_logic_vector(3 downto 0)
        );
    end component;

    component ALU is
        port (
            A, B    : in std_logic_vector(31 downto 0);
            ALU_sel : in std_logic_vector(3 downto 0); -- Changed to 4 bits

            ALU_Result1 : out std_logic_vector(31 downto 0);
            ALU_Result2 : out std_logic_vector(31 downto 0); -- Added for SWAP
            ALU_flags   : out std_logic_vector(0 to 3)
        );
    end component;

    component EM_Buffer is
        port (
            clk, RES, WE : in std_logic;

            -- Passing through
            EM_ALUorMem_in    : in std_logic;
            EM_ALUorMem_out   : out std_logic;
            EM_we1_reg_in     : in std_logic;
            EM_we1_reg_out    : out std_logic;
            EM_we2_reg_in     : in std_logic;
            EM_we2_reg_out    : out std_logic;
            EM_Rdst1_in       : in std_logic_vector(2 downto 0);
            EM_Rdst1_out      : out std_logic_vector(2 downto 0);
            EM_Rdst2_in       : in std_logic_vector(2 downto 0);
            EM_Rdst2_out      : out std_logic_vector(2 downto 0);
            EM_ALUResult1_in  : in std_logic_vector(31 downto 0);
            EM_ALUResult1_out : out std_logic_vector(31 downto 0);
            EM_ALUResult2_in  : in std_logic_vector(31 downto 0);
            EM_ALUResult2_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component DataMemory is
        generic (
            DATA_WIDTH : integer := 32;
            ADDR_WIDTH : integer := 12
        );
        port (
            clk, RES : in std_logic;
            DM_MemR  : in std_logic;
            DM_MemW  : in std_logic;
            DM_RAddr : in unsigned(ADDR_WIDTH - 1 downto 0);
            DM_WAddr : in unsigned(ADDR_WIDTH - 1 downto 0);
            DM_WData : in unsigned(DATA_WIDTH - 1 downto 0);

            DM_RData : out unsigned(DATA_WIDTH - 1 downto 0)
        );
    end component;

    component MW_Buffer is
        port (
            clk, RES, WE  : in std_logic;
            MW_ALUorMem   : in std_logic;
            MW_ALUResult1 : in std_logic_vector(31 downto 0);
            MW_ALUResult2 : in std_logic_vector(31 downto 0);
            MW_MemResult  : in std_logic_vector(31 downto 0);

            MW_value1 : out std_logic_vector(31 downto 0);
            MW_value2 : out std_logic_vector(31 downto 0);

            -- Passing through
            MW_we1_reg_in  : in std_logic;
            MW_we1_reg_out : out std_logic;
            MW_we2_reg_in  : in std_logic;
            MW_we2_reg_out : out std_logic;
            MW_Rdst1_in    : in std_logic_vector(2 downto 0);
            MW_Rdst1_out   : out std_logic_vector(2 downto 0);
            MW_Rdst2_in    : in std_logic_vector(2 downto 0);
            MW_Rdst2_out   : out std_logic_vector(2 downto 0)
        );
    end component MW_Buffer;

    component SP is
        generic (
            WIDTH : integer := 12
        );
        port (
            RES     : in std_logic;
            SP_Push : in std_logic;
            SP_Pop  : in std_logic;

            SP_SP : out std_logic_vector(WIDTH - 1 downto 0)
        );
    end component;

    component CCR is
        port (
            clk, RES     : in std_logic;
            CCR_flags_in : in std_logic_vector (0 to 3);
            CCR_flags_en : in std_logic_vector (0 to 3);

            CCR_flags_out : out std_logic_vector (0 to 3)
        );
    end component CCR;

    ------------------------------------COMPONENTS END-----------------------------------

    ------------------------------------SIGNALS------------------------------------
    -- PC signals
    signal PC_en : std_logic;
    signal PC_PC : std_logic_vector(31 downto 0);
    -- PC signals end

    -- Instruction Cache signals
    signal IC_Inst        : std_logic_vector(15 downto 0);
    signal IC_InterruptPC : std_logic_vector(31 downto 0);
    signal IC_ResetPC     : std_logic_vector(31 downto 0);
    -- Instruction Cache signals end

    -- FD Buffer signals
    signal FD_OpCode : std_logic_vector(2 downto 0);
    signal FD_Rsrc1  : std_logic_vector(2 downto 0);
    signal FD_Rsrc2  : std_logic_vector(2 downto 0);
    signal FD_Rdst1  : std_logic_vector(2 downto 0);
    signal FD_Rdst2  : std_logic_vector(2 downto 0);
    signal FD_Func   : std_logic_vector(3 downto 0);

    -- FD Buffer signals end

    -- Register File signals
    signal RF_Rdata1 : std_logic_vector(31 downto 0);
    signal RF_Rdata2 : std_logic_vector(31 downto 0);
    -- Register File signals end

    -- DE Buffer signals
    signal DE_ALUopd1 : std_logic_vector(31 downto 0);
    signal DE_ALUopd2 : std_logic_vector(31 downto 0);

    signal DE_we1_reg_out  : std_logic;
    signal DE_we2_reg_out  : std_logic;
    signal DE_ALUorMem_out : std_logic;
    signal DE_flags_en_out : std_logic_vector (0 to 3);
    signal DE_Rdst1_out    : std_logic_vector(2 downto 0);
    signal DE_Rdst2_out    : std_logic_vector(2 downto 0);
    signal DE_ALUsel_out   : std_logic_vector(3 downto 0);
    -- DE Buffer signals end

    -- ALU signals
    signal ALU_Result1 : std_logic_vector(31 downto 0);
    signal ALU_Result2 : std_logic_vector(31 downto 0);
    signal ALU_flags   : std_logic_vector(0 to 3);
    -- ALU signals end

    -- EM Buffer signals 
    signal EM_ALUorMem_out   : std_logic;
    signal EM_we1_reg_out    : std_logic;
    signal EM_we2_reg_out    : std_logic;
    signal EM_Rdst1_out      : std_logic_vector(2 downto 0);
    signal EM_Rdst2_out      : std_logic_vector(2 downto 0);
    signal EM_ALUResult1_out : std_logic_vector(31 downto 0);
    signal EM_ALUResult2_out : std_logic_vector(31 downto 0);
    -- EM Buffer signals end

    -- MW Buffer signals
    signal MW_value1 : std_logic_vector(31 downto 0);
    signal MW_value2 : std_logic_vector(31 downto 0);

    signal MW_we1_reg_out : std_logic;
    signal MW_we2_reg_out : std_logic;
    signal MW_Rdst1_out   : std_logic_vector(2 downto 0);
    signal MW_Rdst2_out   : std_logic_vector(2 downto 0);
    -- MW Buffer signals end

    -- CCR signals
    signal CCR_flags : std_logic_vector(3 downto 0);
    -- CCR signals end

    -- Controller Signals (most of the are not connected)
    signal ctr_hasImm   : std_logic;
    signal ctr_ALUsel   : std_logic_vector(3 downto 0);
    signal ctr_flags_en : std_logic_vector(0 to 3);
    signal ctr_we1_reg  : std_logic;
    signal ctr_we2_reg  : std_logic;
    signal ctr_we_mem   : std_logic;
    signal ctr_ALUorMem : std_logic;
    -- Controller signals end

    ------------------------------------SIGNALS END-----------------------------------

begin

    ------------------------------------PORTS------------------------------------

    -- map PC
    pc1 : PC port map(
        clk => clk,
        --from control signals 
        RES       => reset,
        PC_branch => '0',
        PC_en     => PC_en,
        PC_Interrupt => '0',  -- PROBABLY NEED TO CHANGE THIS AND TAKE IT AS AN INPUT TO THE PROCESSOR

        PC_branchPC => (others => '0'),
        PC_InterruptPC => IC_InterruptPC,
        PC_ResetPC => IC_ResetPC,

        PC_PC => PC_PC
    );
    -- map PC end

    -- map instruction cache
    instrCache1 : InstrCache port map(
        clk   => clk,
        RES   => reset,
        IC_PC => PC_PC,

        IC_data        => IC_Inst,
        PC_Reset       => IC_ResetPC,
        PC_Interrupt   => IC_InterruptPC
    );
    -- map instruction cacheend

    -- map FD buffer
    fdBuffer1 : FD_Buffer port map(
        clk     => clk,
        RES     => reset,
        WE      => we,
        FD_Inst => IC_Inst,

        FD_OpCode => FD_OpCode,
        FD_Rsrc1  => FD_Rsrc1,
        FD_Rsrc2  => FD_Rsrc2,
        FD_Rdst1  => FD_Rdst1,
        FD_Rdst2  => FD_Rdst2,
        FD_Func   => FD_Func,

        -- Passing through
        FD_isImm_in => ctr_hasImm
    );
    -- map FD buffer end

    -- map RegistersFiles
    Regfile : RegisterFile port map(
        clk => clk,
        RES => reset,

        RE_we1    => MW_we1_reg_out,
        RF_we2    => MW_we2_reg_out,
        RF_Rdst1  => MW_Rdst1_out,
        RF_Rdst2  => MW_Rdst2_out,
        RF_Wdata1 => MW_value1,
        RF_Wdata2 => MW_value2,

        RF_Rsrc1 => FD_Rsrc1,
        RF_Rsrc2 => FD_Rsrc2,

        RF_Rdata1 => RF_Rdata1,
        RF_Rdata2 => RF_Rdata2
    );
    -- map RegistersFiles end

    -- map DE buffer
    deBuffer1 : DE_Buffer port map(
        clk          => clk,
        RES          => reset,
        WE           => we,
        DE_Rsrc1_Val => RF_Rdata1,
        DE_Rsrc2_Val => RF_Rdata2,
        DE_Imm       => IC_Inst,
        DE_isImm     => ctr_hasImm,

        DE_ALUopd1 => DE_ALUopd1,
        DE_ALUopd2 => DE_ALUopd2,

        -- Passing through
        DE_we1_reg_in  => ctr_we1_reg,
        DE_we2_reg_in  => ctr_we2_reg,
        DE_ALUorMem_in => ctr_ALUorMem,
        DE_flags_en_in => ctr_flags_en,
        DE_Rdst1_in    => FD_Rdst1,
        DE_Rdst2_in    => FD_Rdst2,
        DE_ALUsel_in   => ctr_ALUsel,

        DE_we1_reg_out  => DE_we1_reg_out,
        DE_we2_reg_out  => DE_we2_reg_out,
        DE_ALUorMem_out => DE_ALUorMem_out,
        DE_flags_en_out => DE_flags_en_out,
        DE_Rdst1_out    => DE_Rdst1_out,
        DE_Rdst2_out    => DE_Rdst2_out,
        DE_ALUsel_out   => DE_ALUsel_out
    );
    -- map DE buffer end

    -- map ALU
    alu1 : ALU port map(
        A       => DE_ALUopd1,
        B       => DE_ALUopd2,
        ALU_sel => DE_ALUsel_out,

        ALU_Result1 => ALU_Result1,
        ALU_Result2 => ALU_Result2,
        ALU_flags   => ALU_flags
    );
    -- map ALU end

    -- map EM buffer
    emBuffer1 : EM_Buffer port map(
        clk => clk,
        RES => reset,
        WE  => we,

        -- Passing through
        EM_ALUorMem_in   => DE_ALUorMem_out,
        EM_we1_reg_in    => DE_we1_reg_out,
        EM_we2_reg_in    => DE_we2_reg_out,
        EM_Rdst1_in      => DE_Rdst1_out,
        EM_Rdst2_in      => DE_Rdst2_out,
        EM_ALUResult1_in => ALU_Result1,
        EM_ALUResult2_in => ALU_Result2,

        EM_ALUorMem_out   => EM_ALUorMem_out,
        EM_we1_reg_out    => EM_we1_reg_out,
        EM_we2_reg_out    => EM_we2_reg_out,
        EM_Rdst1_out      => EM_Rdst1_out,
        EM_Rdst2_out      => EM_Rdst2_out,
        EM_ALUResult1_out => EM_ALUResult1_out,
        EM_ALUResult2_out => EM_ALUResult2_out
    );
    -- map EM buffer end

    -- map MW buffer
    MW_Buffer1 : MW_Buffer port map(
        clk           => clk,
        RES           => reset,
        WE            => we,
        MW_ALUorMem   => EM_ALUorMem_out,
        MW_ALUResult1 => EM_ALUResult1_out,
        MW_ALUResult2 => EM_ALUResult2_out,
        MW_MemResult => (others => '0'),

        MW_value1 => MW_value1,
        MW_value2 => MW_value2,

        -- Passing through
        MW_we1_reg_in => EM_we1_reg_out,
        MW_we2_reg_in => EM_we2_reg_out,
        MW_Rdst1_in   => EM_Rdst1_out,
        MW_Rdst2_in   => EM_Rdst2_out,

        MW_we1_reg_out => MW_we1_reg_out,
        MW_we2_reg_out => MW_we2_reg_out,
        MW_Rdst1_out   => MW_Rdst1_out,
        MW_Rdst2_out   => MW_Rdst2_out
    );
    -- map MW buffer end

    -- map controller 
    Ctrl : controller generic map(16)
    port map(
        clk        => clk,
        RES        => reset,
        ctr_opCode => FD_OpCode,
        ctr_Func   => FD_Func,

        ctr_hasImm   => ctr_hasImm,
        ctr_ALUsel   => ctr_ALUsel,
        ctr_flags_en => ctr_flags_en,
        ctr_we1_reg  => ctr_we1_reg,
        ctr_we2_reg  => ctr_we2_reg,
        ctr_we_mem   => ctr_we_mem,
        ctr_ALUorMem => ctr_ALUorMem
    );
    -- map controller end

    -- map CCR
    CCR1 : CCR port map(
        clk          => clk,
        RES          => reset,
        CCR_flags_in => ALU_flags,
        CCR_flags_en => DE_flags_en_out,

        CCR_flags_out => CCR_flags
    );
    -- map CCR end

    ------------------------------------PORTS END----------------------------------
    ------------------------------------PROCESS------------------------------------
    -- i added those because we will need them later and for test cases
    -- process for the output port 
    -- process (clk)
    -- begin
    --     if rising_edge(clk) then
    --         if ctr_ALUorMem = '1' then
    --             OUT_PORT <= MW_value1;
    --         else
    --             OUT_PORT <= (others => '0');
    --         end if;
    --     end if;
    -- end process;

    -- -- process for the exception signal
    -- process (clk)
    -- begin
    --     if rising_edge(clk) then
    --         if ctr_int = '1' then
    --             exception <= '1';
    --         else
    --             exception <= '0';
    --         end if;
    --     end if;
    -- end process;
    ----------------------------------END PROCESS----------------------------------

end architecture ProcessorArch;
