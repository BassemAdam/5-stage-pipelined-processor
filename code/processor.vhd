library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity processor is
    port (
        clk       : in std_logic;
        reset, we : in std_logic;
        INT_In    : in std_logic; -- interrupt signal
        IN_PORT   : in std_logic_vector(7 downto 0);

        exception : out std_logic; -- exception signal
        OUT_PORT  : out std_logic_vector(7 downto 0)
    );
end entity processor;

architecture processorArch of processor is
    ------------------------------------COMPONENTS------------------------------------
    component PC is
        generic (
            N : integer := 32
        );
        port (
            clk      : in std_logic;
            reset    : in std_logic;
            branch   : in std_logic;
            enable   : in std_logic;
            pcBranch : in std_logic_vector(N - 1 downto 0);

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

            data : out std_logic_vector(n - 1 downto 0)
        );
    end component;

    component FD_Buffer is
        port (
            clk   : in std_logic;
            reset : in std_logic;
            WE    : in std_logic;
            --16 bits from instruction memory
            Intruction : in std_logic_vector(15 downto 0);

            OpCode : out std_logic_vector(2 downto 0);
            Src1   : out std_logic_vector(2 downto 0);
            Src2   : out std_logic_vector(2 downto 0);
            dst    : out std_logic_vector(2 downto 0);
            FnNum  : out std_logic_vector(3 downto 0)
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
            WBdata                       : in std_logic_vector(n - 1 downto 0);
            writeEnable                  : in std_logic;

            Rsrc1_data, Rsrc2_data : out std_logic_vector(n - 1 downto 0)
        );
    end component;

    -- component controller is
    --     generic (
    --         INST_WIDTH : integer := 16
    --     );
    --     port (
    --         clk         : in std_logic;
    --         rst         : in std_logic;
    --         instruction : in std_logic_vector(INST_WIDTH - 1 downto 0);

    --         opCode   : out std_logic_vector(6 downto 0);
    --         Rsrc1    : out std_logic_vector(2 downto 0);
    --         Rsrc2    : out std_logic_vector(2 downto 0);
    --         Rdest    : out std_logic_vector(2 downto 0);
    --         hasImm   : out std_logic;
    --         isBranch : out std_logic

    --     );
    -- end component;

    component DE_Buffer is
        port (
            clk, reset, WE  : in std_logic;
            Rsrc1_Val_in    : in std_logic_vector(31 downto 0);
            Rsrc2_Val_in    : in std_logic_vector(31 downto 0);
            Dst_in          : in std_logic_vector(2 downto 0); -- Adjusted length to 3
            aluSelectors_in : in std_logic_vector(3 downto 0);
            DE_we_reg_in    : in std_logic;
            DE_AluOrMem_in  : in std_logic;

            DE_we_reg_out    : out std_logic;
            DE_AluOrMem_out  : out std_logic;
            Rsrc1_Val_out    : out std_logic_vector(31 downto 0);
            Rsrc2_Val_out    : out std_logic_vector(31 downto 0);
            Dst_out          : out std_logic_vector(2 downto 0);
            aluSelectors_out : out std_logic_vector(3 downto 0)
        );
    end component;

    component ALU is
        port (
            A, B       : in std_logic_vector(31 downto 0);
            ALUControl : in std_logic_vector(3 downto 0); -- Changed to 4 bits

            Result    : out std_logic_vector(31 downto 0);
            ALU_flags : out std_logic_vector(0 to 3)
        );
    end component;

    component EM_Buffer is
        port (
            clk, reset, WE  : in std_logic;
            Dst_in          : in std_logic_vector(2 downto 0);
            ALU_OutValue_in : in std_logic_vector(31 downto 0);
            EM_we_reg_in    : in std_logic;
            EM_AluOrMem_in  : in std_logic;

            EM_AluOrMem_out  : out std_logic;
            EM_we_reg_out    : out std_logic;
            ALU_OutValue_out : out std_logic_vector(31 downto 0);
            Dst_out          : out std_logic_vector(2 downto 0)
        );
    end component;

    component DataMemory is
        generic (
            DATA_WIDTH : integer := 32;
            ADDR_WIDTH : integer := 12
        );

        port (
            rst          : in std_logic;
            clk          : in std_logic;
            memWrite     : in std_logic;
            memRead      : in std_logic;
            writeAddress : in unsigned(ADDR_WIDTH - 1 downto 0);
            readAddress  : in unsigned(ADDR_WIDTH - 1 downto 0);
            writeData    : in unsigned(DATA_WIDTH - 1 downto 0);

            readData : out unsigned(DATA_WIDTH - 1 downto 0)
        );
    end component;

    component WB_Buffer is
        port (
            clk, reset, WE : in std_logic;
            --ALU_COUT : in std_logic;
            Dst_in          : in std_logic_vector(2 downto 0);
            ALU_OutValue_in : in std_logic_vector(31 downto 0);
            MemOutValue_in  : in std_logic_vector(31 downto 0);
            WB_we_reg_in    : in std_logic;
            WB_AluOrMem_in  : in std_logic;

            WB_we_reg_out : out std_logic;
            --ALU_COUT_OUT : out std_logic;
            WB_value_out : out std_logic_vector(31 downto 0);
            Dst_out      : out std_logic_vector(2 downto 0)
        );
    end component WB_Buffer;

    -- component conditionCodeRegister is
    -- port (
    -- rst      : in std_logic;
    -- cin      : in std_logic;
    -- ovf      : in std_logic;
    -- opResult : in std_logic_vector(31 downto 0);

    -- flags : out std_logic_vector(3 downto 0)
    -- );
    -- end component;

    component MUX_2x1 is
        generic (
            N : integer := 8
        );
        port (
            I0, I1 : in std_logic_vector(N - 1 downto 0);
            S      : in std_logic;

            O : out std_logic_vector(N - 1 downto 0)
        );
    end component;

    component MUX_4x1 is
        generic (
            N : integer := 8
        );
        port (
            I0, I1, I2, I3 : in std_logic_vector(N - 1 downto 0);
            S              : in std_logic_vector(1 downto 0);

            O : out std_logic_vector(N - 1 downto 0)
        );
    end component;

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

    component nBuffer is
        generic (
            N : positive := 16 --instruction width
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            din : in std_logic_vector(N - 1 downto 0);

            dout : out std_logic_vector(N - 1 downto 0)
        );
    end component;

    component controller is
        generic (
            INST_WIDTH : integer := 16
        );
        port (
            clk           : in std_logic;
            rst           : in std_logic;
            ctr_opCode_in : in std_logic_vector(2 downto 0);
            ctr_Rdest_in  : in std_logic_vector(2 downto 0);
            ctr_Rsrc1_in  : in std_logic_vector(2 downto 0);
            ctr_Rsrc2_in  : in std_logic_vector(2 downto 0);
            ctr_fnNum_in  : in std_logic_vector(3 downto 0);

            ctr_opCode_out  : out std_logic_vector(2 downto 0);
            ctr_fnNum_out   : out std_logic_vector(3 downto 0);
            ctr_Rsrc1_out   : out std_logic_vector(2 downto 0);
            ctr_Rsrc2_out   : out std_logic_vector(2 downto 0);
            ctr_Rdest_out   : out std_logic_vector(2 downto 0);
            hasImm          : out std_logic;
            writeEnable_reg : out std_logic;
            writeEnable_mem : out std_logic;
            ALUorMem        : out std_logic;
            --predictor: OUT STD_LOGIC;
            --protect: OUT STD_LOGIC;
            --free: OUT STD_LOGIC;
            --isJZ : OUT STD_LOGIC;
            --isJMP : OUT STD_LOGIC;
            --flushIF_ID : OUT STD_LOGIC;
            --flushID_EX : OUT STD_LOGIC;
            --flushEX_MEM : OUT STD_LOGIC;
            --flushMEM_WB : OUT STD_LOGIC;
            stall        : out std_logic;
            int          : out std_logic;
            isSwap       : out std_logic;
            ctr_flags_en : out std_logic_vector(0 to 3);
            ctr_ALU_sel  : out std_logic_vector(3 downto 0);
            PCIncType    : out std_logic_vector(1 downto 0)
            --CallorInt : OUT STD_LOGIC;

            --push : OUT STD_LOGIC;
            --pop : OUT STD_LOGIC;

        );
    end component controller;

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
    signal Ipc_out : std_logic_vector(31 downto 0);

    --Instruction Cache signals
    signal instruction_Out_Cache : std_logic_vector(15 downto 0);

    --FD Buffer signals
    signal opCode_Out : std_logic_vector(2 downto 0);
    signal Rsrc1_Out  : std_logic_vector(2 downto 0);
    signal Rsrc2_Out  : std_logic_vector(2 downto 0);
    signal Rdest_Out  : std_logic_vector(2 downto 0);
    signal FnNum_Out  : std_logic_vector(3 downto 0);

    --Register File signals
    signal Rsrc1_data_Out : std_logic_vector(31 downto 0);
    signal Rsrc2_data_Out : std_logic_vector(31 downto 0);

    --Controller signals
    signal Cont_instruction_In : std_logic_vector(15 downto 0);
    signal Rsrc1               : std_logic_vector(2 downto 0);
    signal Rsrc2               : std_logic_vector(2 downto 0);
    signal Rdest               : std_logic_vector(2 downto 0);
    -- signal ALU_Selectors       : std_logic_vector(6 downto 0);
    signal PC_Enable : std_logic;
    signal isBranch  : std_logic;

    --DE Buffer signals
    signal DE_we_reg_out       : std_logic;
    signal DE_Rsrc1_data_out   : std_logic_vector(31 downto 0);
    signal DE_Rsrc2_data_out   : std_logic_vector(31 downto 0);
    signal DE_dest_out         : std_logic_vector(2 downto 0);
    signal DE_AluSelectors_out : std_logic_vector(3 downto 0);

    --     --ALU signals
    signal ALUResult : std_logic_vector(31 downto 0);
    signal ALU_flags : std_logic_vector(0 to 3);
    --     --EM Buffer signals 
    signal EM_we_reg_out : std_logic;
    signal EM_ALUResult  : std_logic_vector(31 downto 0);
    signal EM_dest_out   : std_logic_vector(2 downto 0);

    --     --Data Memory signals
    --     SIGNAL writeAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --     SIGNAL readAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);

    --WB Buffer signals
    signal WB_we_reg_out    : std_logic;
    signal WB_Rdest_Out     : std_logic_vector(2 downto 0);
    signal WB_ALUResult_Out : std_logic_vector(31 downto 0);

    --     --Condition Code Register signals
    --     SIGNAL cin : STD_LOGIC;
    --     SIGNAL ovf : STD_LOGIC;
    signal CCR_flags : std_logic_vector(3 downto 0);
    --     --SP signals
    --     SIGNAL pointer : STD_LOGIC_VECTOR(11 DOWNTO 0);
    --     SIGNAL push : STD_LOGIC;
    --     SIGNAL pop : STD_LOGIC;

    --     --Versatile signals that still not well implemented just added it here to avoid errors from component until we figure out the whole design
    -- SIGNAL branchEnable : STD_LOGIC;

    signal pcBranchIn  : std_logic_vector(31 downto 0);
    signal IWBdata_Out : std_logic_vector(31 downto 0);
    --     SIGNAL writeEnable : STD_LOGIC;
    --     SIGNAL hasImm : STD_LOGIC;

    -- Controller Signals (most of the are not connected)
    signal ctr_opCode_out      : std_logic_vector(2 downto 0);
    signal ctr_fnNum_out       : std_logic_vector(3 downto 0);
    signal ctr_Rsrc1_out       : std_logic_vector(2 downto 0);
    signal ctr_Rsrc2_out       : std_logic_vector(2 downto 0);
    signal ctr_Rdest_out       : std_logic_vector(2 downto 0);
    signal ctr_hasImm          : std_logic;
    signal ctr_writeEnable_reg : std_logic;
    signal ctr_writeEnable_mem : std_logic;

    signal ctr_ALUorMem    : std_logic;
    signal DE_AluOrMem_out : std_logic;
    signal EM_AluOrMem_out : std_logic;

    signal ctr_stall     : std_logic;
    signal ctr_int       : std_logic;
    signal ctr_isSwap    : std_logic;
    signal ctr_flags_en  : std_logic_vector(0 to 3);
    signal ctr_ALU_sel   : std_logic_vector(3 downto 0);
    signal ctr_PCIncType : std_logic_vector(1 downto 0);

    ------------------------------------SIGNALS END-----------------------------------

begin
    ------------------------------------PORTS------------------------------------
    -- map PC
    pc1 : PC port map(
        clk => clk,
        --from control signals 
        reset    => reset,
        branch   => isBranch,
        enable   => PC_Enable,
        pcBranch => pcBranchIn,
        pc       => Ipc_out
    );

    -- map SP
    --  sp1 : SP PORT MAP(
    --     reset => reset,
    --     push => push,
    --     pop => pop,
    --     pointer => pointer
    -- );

    -- map instruction cache with pc
    instrCache1 : InstrCache port map(
        clk  => clk,
        rst  => reset,
        pc   => Ipc_out,
        data => instruction_Out_Cache
    );

    -- map FD buffer with instruction cache
    fdBuffer1 : FD_Buffer port map(
        clk        => clk,
        reset      => reset,
        WE         => we,
        Intruction => instruction_Out_Cache,
        OpCode     => opCode_Out,
        Src1       => Rsrc1_Out,
        Src2       => Rsrc2_Out,
        dst        => Rdest_Out,
        FnNum      => FnNum_Out
    );

    --map RegistersFiles with FD buffer
    registerFile1 : RegisterFile port map(
        clk           => clk,
        rst           => reset,
        Rsrc1_address => Rsrc1_Out,
        Rsrc2_address => Rsrc2_Out,
        Rdest         => WB_Rdest_Out,
        WBdata        => WB_ALUResult_Out,
        writeEnable   => WB_we_reg_out,
        Rsrc1_data    => Rsrc1_data_Out,
        Rsrc2_data    => Rsrc2_data_Out
    );
    --    -- map controller
    --    controller1 : controller PORT MAP(
    --     clk => clk,
    --     rst => reset,
    --    -- instruction => opCode_Out & Rsrc1_Out & Rsrc2_Out & Rdest_Out & FnNum_Out,
    --     instruction => Cont_instruction_In,
    --     opCode => ALU_Selectors,
    --     Rsrc1 => Rsrc1,
    --     Rsrc2 => Rsrc2,
    --     Rdest => Rdest,
    --     hasImm => hasImm,
    --     isBranch => isBranch
    -- );

    -- --map DE buffer with RegistersFiles & Controller
    deBuffer1 : DE_Buffer port map(
        clk              => clk,
        reset            => reset,
        WE               => we,
        Rsrc1_Val_in     => Rsrc1_data_Out,
        Rsrc2_Val_in     => Rsrc2_data_Out,
        Dst_in           => Rdest_Out,
        aluSelectors_in  => ctr_ALU_sel, --we should make this logic in the controller
        DE_we_reg_in     => ctr_writeEnable_reg,
        DE_AluOrMem_in   => ctr_ALUorMem,
        DE_AluOrMem_out  => DE_AluOrMem_out,
        DE_we_reg_out    => DE_we_reg_out,
        Rsrc1_Val_out    => DE_Rsrc1_data_out,
        Rsrc2_Val_out    => DE_Rsrc2_data_out,
        Dst_out          => DE_dest_out,
        aluSelectors_out => DE_AluSelectors_out
    );

    -- -- map ALU with DE buffer
    alu1 : ALU port map(
        A          => DE_Rsrc1_data_out,
        B          => DE_Rsrc2_data_out,
        ALUControl => DE_AluSelectors_out,

        Result    => ALUResult,
        ALU_flags => ALU_flags
    );
    -- map EM buffer with ALU
    emBuffer1 : EM_Buffer port map(
        clk             => clk,
        reset           => reset,
        WE              => we,
        Dst_in          => DE_dest_out,
        ALU_OutValue_in => ALUResult,
        EM_we_reg_in    => DE_we_reg_out,
        EM_AluOrMem_in  => DE_AluOrMem_out,

        EM_AluOrMem_out  => EM_AluOrMem_out,
        EM_we_reg_out    => EM_we_reg_out,
        ALU_OutValue_out => EM_ALUResult,
        Dst_out          => EM_dest_out
    );
    --shitttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt
    -- -- map DataMemory with EM buffer
    -- dataMemory1 : DataMemory PORT MAP(
    --     rst => reset,
    --     clk => clk,
    --     memWrite => we,
    --     memRead => we,
    --     writeAddress => Rsrc1_data,
    --     readAddress => Rsrc2_data,
    --     writeData => ALUResult,
    --     readData => WBdata
    -- );

    -- map WB buffer with DataMemory
    wbBuffer1 : WB_Buffer port map(
        clk             => clk,
        reset           => reset,
        WE              => we,
        Dst_in          => EM_dest_out,
        ALU_OutValue_in => EM_ALUResult,
        MemOutValue_in => (others => '0'),
        WB_we_reg_in    => EM_we_reg_out,
        WB_AluOrMem_in  => EM_AluOrMem_out,

        WB_we_reg_out => WB_we_reg_out,
        WB_value_out  => WB_ALUResult_Out,
        Dst_out       => WB_Rdest_Out
    );

    -- -- map condition code register
    -- conditionCodeRegister1 : conditionCodeRegister PORT MAP(
    --     rst => reset,
    --     cin => cin,
    --     ovf => ovf,
    --     opResult => ALUResult,
    --     flags => flags
    -- );

    Ctrl : controller generic map(16)
    port map(
        clk           => clk,
        rst           => reset,
        ctr_opCode_in => opCode_Out,
        ctr_Rdest_in  => Rdest_Out,
        ctr_Rsrc1_in  => Rsrc1_Out,
        ctr_Rsrc2_in  => Rsrc2_Out,
        ctr_fnNum_in  => FnNum_Out,

        ctr_opCode_out  => ctr_opCode_out,
        ctr_fnNum_out   => ctr_fnNum_out,
        ctr_Rsrc1_out   => ctr_Rsrc1_out,
        ctr_Rsrc2_out   => ctr_Rsrc2_out,
        ctr_Rdest_out   => ctr_Rdest_out,
        hasImm          => ctr_hasImm,
        writeEnable_reg => ctr_writeEnable_reg,
        writeEnable_mem => ctr_writeEnable_mem,
        ALUorMem        => ctr_ALUorMem,
        --predictor: OUT STD_LOGIC;
        --protect: OUT STD_LOGIC;
        --free: OUT STD_LOGIC;
        --isJZ : OUT STD_LOGIC;
        --isJMP : OUT STD_LOGIC;
        --flushIF_ID : OUT STD_LOGIC;
        --flushID_EX : OUT STD_LOGIC;
        --flushEX_MEM : OUT STD_LOGIC;
        --flushMEM_WB : OUT STD_LOGIC;
        stall        => ctr_stall,
        int          => ctr_int,
        isSwap       => ctr_isSwap,
        ctr_flags_en => ctr_flags_en,
        ctr_ALU_sel  => ctr_ALU_sel,
        PCIncType    => ctr_PCIncType
        --CallorInt : OUT STD_LOGIC;

        --push : OUT STD_LOGIC;
        --pop : OUT STD_LOGIC;

    );

    CCR1 : CCR port map(
        clk      => clk,
        RES      => reset,
        flags_in => ALU_flags,
        flags_en => ctr_flags_en,

        flags_out => CCR_flags
    );

    ------------------------------------PORTS END----------------------------------

    ------------------------------------PROCESS------------------------------------
    -- Perform the concatenation in a process
    -- process(clk)
    -- begin
    --     if rising_edge(clk) then
    --         Cont_instruction_In <= opCode_Out & Rsrc1_Out & Rsrc2_Out & Rdest_Out & FnNum_Out;
    --     end if;
    -- end process;

    -- process(clk, reset)
    -- begin

    --     if (we = '1') then
    --         Instruction_Address <= pc_out;
    --         Intruction <= data;
    --     end if;

    -- end process;
    ----------------------------------END PROCESS----------------------------------

    -- map data memory

end architecture processorArch;
