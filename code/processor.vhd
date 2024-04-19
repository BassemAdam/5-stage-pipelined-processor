LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY processor IS
    PORT (
        clk : IN STD_LOGIC;
        reset,we : IN STD_LOGIC;
        INT_In : IN STD_LOGIC; -- interrupt signal
        exception : OUT STD_LOGIC; -- exception signal
        IN_PORT : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        OUT_PORT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY processor;

ARCHITECTURE processorArch OF processor IS
------------------------------------COMPONENTS------------------------------------
    COMPONENT PC IS
        GENERIC (
            N : INTEGER := 32
        );
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            branch : IN STD_LOGIC;
            enable : IN STD_LOGIC;
            pcBranch : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            pc : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT InstrCache IS
        GENERIC (
            n : INTEGER := 16; -- number of bits per instruction
            m : INTEGER := 12; -- height of the cache
            k : INTEGER := 32 -- pc size
        );
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            pc : IN STD_LOGIC_VECTOR(k - 1 DOWNTO 0);
            data : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT FD_Buffer IS
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            WE : IN STD_LOGIC;
            --16 bits from instruction memory
            Intruction : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

            OpCode : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Src1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Src2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            dst : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            FnNum : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT FD_Buffer;

    COMPONENT RegisterFile IS
        GENERIC (
            w : INTEGER := 3;
            n : INTEGER := 32
        );
        PORT (
            clk, rst : IN STD_LOGIC;
            Rsrc1_address, Rsrc2_address : IN STD_LOGIC_VECTOR(w - 1 DOWNTO 0);
            Rdest : IN STD_LOGIC_VECTOR(w - 1 DOWNTO 0);
            WBdata : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            writeEnable : IN STD_LOGIC;
            Rsrc1_data, Rsrc2_data : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT controller IS
        GENERIC (
            INST_WIDTH : INTEGER := 16
        );
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            instruction : IN STD_LOGIC_VECTOR(INST_WIDTH - 1 DOWNTO 0);
            opCode : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            Rsrc1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rsrc2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            Rdest : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            hasImm : OUT STD_LOGIC;
            isBranch : OUT STD_LOGIC

        );
    END COMPONENT;

    COMPONENT DE_Buffer IS
        port (   
            clk, reset, WE : in  std_logic;
            Rsrc1_Val_in, Rsrc2_Val_in : in  std_logic_vector(31 downto 0);
            Dst_in : in  std_logic_vector(2 downto 0); -- Adjusted length to 3
            aluSelectors_in : in  std_logic_vector(6 downto 0); 
            Rsrc1_Val_out, Rsrc2_Val_out : out std_logic_vector(31 downto 0);
            Dst_out : out std_logic_vector(2 downto 0);
            aluSelectors_out : out std_logic_vector(6 downto 0)
        );
    END COMPONENT;

    COMPONENT ALU IS
        port(
            A, B: in std_logic_vector(31 downto 0);
            ALUControl: in std_logic_vector(6 downto 0); -- Changed to 4 bits
            Result: out std_logic_vector(31 downto 0);
            Zero: out std_logic;
            Negative: out std_logic;
            Carry: out std_logic;
            Overflow: out std_logic
        );
    END COMPONENT;

    COMPONENT EM_Buffer is
        port (   
            clk, reset, WE : in  std_logic;
            Dst_in : in  std_logic_vector(2 downto 0);
            ALU_OutValue_in : in  std_logic_vector(31 downto 0);
            ALU_OutValue_out : out std_logic_vector(31 downto 0);
            Dst_out : out std_logic_vector(2 downto 0)
        );
    end COMPONENT;

    COMPONENT DataMemory IS
        GENERIC (
            DATA_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 12
        );

        PORT (
            rst : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            memWrite : IN STD_LOGIC;
            memRead : IN STD_LOGIC;
            writeAddress : IN unsigned(ADDR_WIDTH - 1 DOWNTO 0);
            readAddress : IN unsigned(ADDR_WIDTH - 1 DOWNTO 0);
            writeData : IN unsigned(DATA_WIDTH - 1 DOWNTO 0);
            readData : OUT unsigned(DATA_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT WB_Buffer is
        port (   
            clk, reset, WE : in  std_logic;
            Dst_in : in  std_logic_vector(2 downto 0);
            ALU_OutValue_in : in  std_logic_vector(31 downto 0);  
            ALU_OutValue_out : out std_logic_vector(31 downto 0);
            Dst_out : out std_logic_vector(2 downto 0)
        );
    end COMPONENT WB_Buffer;

    COMPONENT conditionCodeRegister IS
        PORT (
            rst : IN STD_LOGIC;
            cin : IN STD_LOGIC;
            ovf : IN STD_LOGIC;
            opResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            flags : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT MUX_2x1 IS
        GENERIC (
            N : INTEGER := 8
        );
        PORT (
            I0, I1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            S : IN STD_LOGIC;
            O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT MUX_4x1 IS
        GENERIC (
            N : INTEGER := 8
        );
        PORT (
            I0, I1, I2, I3 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            S : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT SP IS
        GENERIC (
            WIDTH : INTEGER := 12
        );
        PORT (
            reset : IN STD_LOGIC;
            push : IN STD_LOGIC;
            pop : IN STD_LOGIC;
            pointer : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT nBuffer IS
        GENERIC (
            N : POSITIVE := 16 --instruction width
        );
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            dout : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;

    ------------------------------------COMPONENTS END-----------------------------------

    ------------------------------------SIGNALS------------------------------------
        --PC signals
        SIGNAL Ipc_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
     
        --Instruction Cache signals
        SIGNAL instruction_Out_Cache : STD_LOGIC_VECTOR(15 DOWNTO 0);   

        --FD Buffer signals
        SIGNAL opCode_Out : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL Rsrc1_Out : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL Rsrc2_Out : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL Rdest_Out : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL FnNum_Out : STD_LOGIC_VECTOR(3 DOWNTO 0);

        --Register File signals
        SIGNAL Rsrc1_data_Out : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL Rsrc2_data_Out : STD_LOGIC_VECTOR(31 DOWNTO 0);
       
    --    --Controller signals
    --     signal Cont_instruction_In : std_logic_vector(15 downto 0);
    --     SIGNAL Rsrc1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    --     SIGNAL Rsrc2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    --     SIGNAL Rdest : STD_LOGIC_VECTOR(2 DOWNTO 0);
           SIGNAL ALU_Selectors : STD_LOGIC_VECTOR(6 DOWNTO 0);
           SIGNAL PC_Enable : STD_LOGIC;
           SIGNAL isBranch : STD_LOGIC;

        --DE Buffer signals
        SIGNAL DE_Rsrc1_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL DE_Rsrc2_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL DE_dest_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL DE_AluSelectors_out : STD_LOGIC_VECTOR(6 DOWNTO 0);

    --     --ALU signals
        SIGNAL ALUResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL zeroFlag : STD_LOGIC;
        SIGNAL NegativeFlag : STD_LOGIC;
        SIGNAL CarryFlag : STD_LOGIC;
        SIGNAL OverflowFlag : STD_LOGIC;

    --     --EM Buffer signals 
        SIGNAL EM_ALUResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL EM_dest_out : STD_LOGIC_VECTOR(2 DOWNTO 0);

    --     --Data Memory signals
    --     SIGNAL writeAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --     SIGNAL readAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);

        --WB Buffer signals
        SIGNAL WB_Rdest_Out : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL WB_ALUResult_Out : STD_LOGIC_VECTOR(31 DOWNTO 0);
        
    --     --Condition Code Register signals
    --     SIGNAL cin : STD_LOGIC;
    --     SIGNAL ovf : STD_LOGIC;
    --     SIGNAL flags : STD_LOGIC_VECTOR(3 DOWNTO 0);
    --     --SP signals
    --     SIGNAL pointer : STD_LOGIC_VECTOR(11 DOWNTO 0);
    --     SIGNAL push : STD_LOGIC;
    --     SIGNAL pop : STD_LOGIC;

    --     --Versatile signals that still not well implemented just added it here to avoid errors from component until we figure out the whole design
        -- SIGNAL branchEnable : STD_LOGIC;

           SIGNAL pcBranchIn : STD_LOGIC_VECTOR(31 DOWNTO 0);
           SIGNAL IWBdata_Out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --     SIGNAL writeEnable : STD_LOGIC;
    --     SIGNAL hasImm : STD_LOGIC;

    
------------------------------------SIGNALS END-----------------------------------

BEGIN
------------------------------------PORTS------------------------------------
     -- map PC
     pc1 : PC PORT MAP(
        clk => clk,
        --from control signals 
        reset => reset,
        branch => isBranch,
        enable => PC_Enable,
        pcBranch => pcBranchIn,
        pc => Ipc_out
    );

     -- map SP
    --  sp1 : SP PORT MAP(
    --     reset => reset,
    --     push => push,
    --     pop => pop,
    --     pointer => pointer
    -- );
    
    -- map instruction cache with pc
    instrCache1 : InstrCache PORT MAP(
        clk => clk,
        rst => reset,
        pc => Ipc_out,
        data => instruction_Out_Cache
    );
    
    -- map FD buffer with instruction cache
    fdBuffer1 : FD_Buffer PORT MAP(
        clk => clk,
        reset => reset,
        WE => we,
        Intruction => instruction_Out_Cache,
        OpCode => opCode_Out,
        Src1 => Rsrc1_Out,
        Src2 => Rsrc2_Out,
        dst => Rdest_Out,
        FnNum => FnNum_Out
    );
    
    --map RegistersFiles with FD buffer
    registerFile1 : RegisterFile PORT MAP(
        clk => clk,
        rst => reset,
        Rsrc1_address => Rsrc1_Out,
        Rsrc2_address => Rsrc2_Out,
        Rdest => WB_Rdest_Out,
        WBdata => WB_ALUResult_Out,
        writeEnable => we, --for now we will make it write enable of the whole processor but it should be connected to the controller
        Rsrc1_data => Rsrc1_data_Out,
        Rsrc2_data => Rsrc2_data_Out
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
    deBuffer1 : DE_Buffer PORT MAP(
        clk => clk,
        reset => reset,
        WE => we,
        Rsrc1_Val_in => Rsrc1_data_Out,
        Rsrc2_Val_in => Rsrc2_data_Out,
        Dst_in => Rdest_Out,
        aluSelectors_in => ALU_Selectors, --we should make this logic in the controller
        Rsrc1_Val_out => DE_Rsrc1_data_out,
        Rsrc2_Val_out => DE_Rsrc2_data_out,
        Dst_out => DE_dest_out,
        aluSelectors_out => DE_AluSelectors_out
    );
    
 

    -- -- map ALU with DE buffer
    alu1 : ALU PORT MAP(
        A => DE_Rsrc1_data_out,
        B => DE_Rsrc2_data_out,
        ALUControl => DE_AluSelectors_out,

        Result => ALUResult,
        Zero => zeroFlag,
        Negative => NegativeFlag,
        Carry => CarryFlag,
        Overflow => OverflowFlag
        
    );
    -- map EM buffer with ALU
    emBuffer1 : EM_Buffer PORT MAP(
        clk => clk,
        reset => reset,
        WE => we,
        Dst_in => DE_dest_out,
        ALU_OutValue_in => ALUResult,
        ALU_OutValue_out => EM_ALUResult,
        Dst_out => EM_dest_out
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
    wbBuffer1 : WB_Buffer PORT MAP(
        clk => clk,
        reset => reset,
        WE => we,
        Dst_in => EM_dest_out,
        ALU_OutValue_in => EM_ALUResult,
        ALU_OutValue_out => WB_ALUResult_Out,
        Dst_out => WB_Rdest_Out
    );

    

    -- -- map condition code register
    -- conditionCodeRegister1 : conditionCodeRegister PORT MAP(
    --     rst => reset,
    --     cin => cin,
    --     ovf => ovf,
    --     opResult => ALUResult,
    --     flags => flags
    -- );
   
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

END ARCHITECTURE processorArch;