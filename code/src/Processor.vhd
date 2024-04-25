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
        generic (
            N : integer := 32
        );
        port (
            clk, RES : in std_logic;
            branch   : in std_logic;
            enable   : in std_logic;
            pcBranch : in std_logic_vector(N - 1 downto 0);

            isImmFromInstr : in std_logic;
            correctedPc    : in std_logic_vector(N - 1 downto 0);

            pc : out std_logic_vector(N - 1 downto 0)
        );
    end component;

    component InstrCache is
        generic (
            n : integer := 16; -- number of bits per instruction
            m : integer := 12; -- height of the cache
            k : integer := 32  -- pc size
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            pc  : in std_logic_vector(k - 1 downto 0);

            data          : buffer std_logic_vector(n - 1 downto 0); --so that i can read and write to
            immediate_out : out std_logic_vector(n - 1 downto 0);
            IsImmediate   : out std_logic;
            correctedPc   : out std_logic_vector(k - 1 downto 0)
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
            FD_isImm_in  : in std_logic;
            FD_isImm_out : out std_logic;
            FD_Imm_in    : in std_logic_vector(15 downto 0);
            FD_Imm_out   : out std_logic_vector(15 downto 0)
        );
    end component FD_Buffer;

    component RegisterFile is
        generic (
            w : integer := 3;
            n : integer := 32
        );
        port (
            clk, rst                     : in std_logic;
            Rsrc1_address, Rsrc2_address : in std_logic_vector(w - 1 downto 0);
            Rdest                        : in std_logic_vector(w - 1 downto 0);
            Rdest_2                      : in std_logic_vector(w - 1 downto 0);
            WBdata                       : in std_logic_vector(n - 1 downto 0);
            WBdata_2                     : in std_logic_vector(n - 1 downto 0);
            writeEnable                  : in std_logic;
            writeEnable_2                : in std_logic;
            Rsrc1_data, Rsrc2_data       : out std_logic_vector(n - 1 downto 0)
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
            A, B : in std_logic_vector(31 downto 0);
            sel  : in std_logic_vector(3 downto 0); -- Changed to 4 bits

            Result1 : out std_logic_vector(31 downto 0);
            Result2 : out std_logic_vector(31 downto 0); -- Added for SWAP
            flags   : out std_logic_vector(0 to 3)
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
            clk, RES  : in std_logic;
            memWrite  : in std_logic;
            memRead   : in std_logic;
            writeAddr : in unsigned(ADDR_WIDTH - 1 downto 0);
            readAddr  : in unsigned(ADDR_WIDTH - 1 downto 0);
            writeData : in unsigned(DATA_WIDTH - 1 downto 0);

            readData : out unsigned(DATA_WIDTH - 1 downto 0)
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
            reset : in std_logic;
            push  : in std_logic;
            pop   : in std_logic;

            pointer : out std_logic_vector(WIDTH - 1 downto 0)
        );
    end component;

    component CCR is
        port (
            clk, RES : in std_logic;
            flags_in : in std_logic_vector (0 to 3);
            flags_en : in std_logic_vector (0 to 3);

            flags_out : out std_logic_vector (0 to 3)
        );
    end component CCR;

    ------------------------------------COMPONENTS END-----------------------------------

    ------------------------------------SIGNALS------------------------------------
    --PC signals
    signal PC_Enable : std_logic;
    signal Ipc_out   : std_logic_vector(31 downto 0);
    --PC signals end

    --Instruction Cache signals
    signal instruction_Out_Cache    : std_logic_vector(15 downto 0);
    signal InsCache_immediate_out   : std_logic_vector(15 downto 0);
    signal InsCache_IsImmediate_out : std_logic;
    signal InsCache_correctedPc_out : std_logic_vector(31 downto 0);
    --Instruction Cache signals end

    --FD Buffer signals
    signal FD_OpCode : std_logic_vector(2 downto 0);
    signal FD_Rsrc1  : std_logic_vector(2 downto 0);
    signal FD_Rsrc2  : std_logic_vector(2 downto 0);
    signal FD_Rdst1  : std_logic_vector(2 downto 0);
    signal FD_Rdst2  : std_logic_vector(2 downto 0);
    signal FD_Func   : std_logic_vector(3 downto 0);

    signal FD_Imm_out   : std_logic_vector(15 downto 0);
    signal FD_isImm_out : std_logic;
    --FD Buffer signals end

    --Register File signals
    signal Rsrc1_data_Out : std_logic_vector(31 downto 0);
    signal Rsrc2_data_Out : std_logic_vector(31 downto 0);
    --Register File signals end

    --DE Buffer signals
    signal DE_ALUopd1 : std_logic_vector(31 downto 0);
    signal DE_ALUopd2 : std_logic_vector(31 downto 0);

    signal DE_we1_reg_out  : std_logic;
    signal DE_we2_reg_out  : std_logic;
    signal DE_ALUorMem_out : std_logic;
    signal DE_flags_en_out : std_logic_vector (0 to 3);
    signal DE_Rdst1_out    : std_logic_vector(2 downto 0);
    signal DE_Rdst2_out    : std_logic_vector(2 downto 0);
    signal DE_ALUsel_out   : std_logic_vector(3 downto 0);
    --DE Buffer signals end

    --ALU signals
    signal ALU_Result1 : std_logic_vector(31 downto 0);
    signal ALU_Result2 : std_logic_vector(31 downto 0);
    signal ALU_flags   : std_logic_vector(0 to 3);
    --ALU signals end

    --EM Buffer signals 
    signal EM_ALUorMem_out   : std_logic;
    signal EM_we1_reg_out    : std_logic;
    signal EM_we2_reg_out    : std_logic;
    signal EM_Rdst1_out      : std_logic_vector(2 downto 0);
    signal EM_Rdst2_out      : std_logic_vector(2 downto 0);
    signal EM_ALUResult1_out : std_logic_vector(31 downto 0);
    signal EM_ALUResult2_out : std_logic_vector(31 downto 0);
    --EM Buffer signals end

    --MW Buffer signals
    signal MW_value1 : std_logic_vector(31 downto 0);
    signal MW_value2 : std_logic_vector(31 downto 0);

    signal MW_we1_reg_out : std_logic;
    signal MW_we2_reg_out : std_logic;
    signal MW_Rdst1_out   : std_logic_vector(2 downto 0);
    signal MW_Rdst2_out   : std_logic_vector(2 downto 0);
    --MW Buffer signals end

    -- CCR signals
    signal CCR_flags : std_logic_vector(3 downto 0);
    --CCR signals end

    -- Controller Signals (most of the are not connected)
    signal ctr_hasImm   : std_logic;
    signal ctr_ALUsel   : std_logic_vector(3 downto 0);
    signal ctr_flags_en : std_logic_vector(0 to 3);
    signal ctr_we1_reg  : std_logic;
    signal ctr_we2_reg  : std_logic;
    signal ctr_we_mem   : std_logic;
    signal ctr_ALUorMem : std_logic;
    --Controller signals end

    ------------------------------------SIGNALS END-----------------------------------

begin

    ------------------------------------PORTS------------------------------------

    -- map PC
    pc1 : PC port map(
        clk => clk,
        --from control signals 
        RES    => reset,
        branch => '0',
        enable => PC_Enable,
        pcBranch => (others => '0'),
        pc     => Ipc_out,

        --from instruction cache
        isImmFromInstr => InsCache_IsImmediate_out,
        correctedPc    => InsCache_correctedPc_out

    );
    -- map PC end

    -- map instruction cache with pc
    instrCache1 : InstrCache port map(
        clk           => clk,
        rst           => reset,
        pc            => Ipc_out,
        data          => instruction_Out_Cache,
        immediate_out => InsCache_immediate_out,
        IsImmediate   => InsCache_IsImmediate_out,
        correctedPc   => InsCache_correctedPc_out

    );
    -- map instruction cache with pc end

    -- map FD buffer with instruction cache
    fdBuffer1 : FD_Buffer port map(
        clk     => clk,
        RES     => reset,
        WE      => we,
        FD_Inst => instruction_Out_Cache,

        FD_OpCode => FD_OpCode,
        FD_Rsrc1  => FD_Rsrc1,
        FD_Rsrc2  => FD_Rsrc2,
        FD_Rdst1  => FD_Rdst1,
        FD_Rdst2  => FD_Rdst2,
        FD_Func   => FD_Func,

        -- Passing through
        FD_isImm_in => InsCache_IsImmediate_out,
        FD_Imm_in   => InsCache_immediate_out,

        FD_isImm_out => FD_isImm_out,
        FD_Imm_out   => FD_Imm_out
    );
    -- map FD buffer with instruction cache end

    -- map RegistersFiles with FD buffer
    registerFile1 : RegisterFile port map(
        clk           => clk,
        rst           => reset,
        Rsrc1_address => FD_Rsrc1,
        Rsrc2_address => FD_Rsrc2,
        Rdest         => MW_Rdst1_out,
        Rdest_2       => MW_Rdst2_out,
        WBdata        => MW_value1,
        WBdata_2      => MW_value2,
        writeEnable   => MW_we1_reg_out,
        writeEnable_2 => MW_we2_reg_out,
        Rsrc1_data    => Rsrc1_data_Out,
        Rsrc2_data    => Rsrc2_data_Out
    );
    -- map RegistersFiles with FD buffer end

    -- map DE buffer with RegistersFiles & Controller
    deBuffer1 : DE_Buffer port map(
        clk          => clk,
        RES          => reset,
        WE           => we,
        DE_Rsrc1_Val => Rsrc1_data_Out,
        DE_Rsrc2_Val => Rsrc2_data_Out,
        DE_Imm       => FD_Imm_out,
        DE_isImm     => FD_isImm_out,

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
    -- map DE buffer with RegistersFiles & Controller end

    -- map ALU with DE buffer
    alu1 : ALU port map(
        A   => DE_ALUopd1,
        B   => DE_ALUopd2,
        sel => DE_ALUsel_out,

        Result1 => ALU_Result1,
        Result2 => ALU_Result2,
        flags   => ALU_flags
    );
    -- map ALU with DE buffer end

    -- map EM buffer with ALU
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
    -- map EM buffer with ALU end

    -- map MW buffer with DataMemory
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
    -- map MW buffer with DataMemory end

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
        clk      => clk,
        RES      => reset,
        flags_in => ALU_flags,
        flags_en => DE_flags_en_out,

        flags_out => CCR_flags
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
