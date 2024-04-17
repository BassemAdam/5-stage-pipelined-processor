LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY processor IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
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

    COMPONENT DE_Buffer IS
        PORT (
            clk, reset, WE : IN STD_LOGIC;
            Rsrc1_Val_in, Rsrc2_Val_in, Dst_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            aluSelectors_in : IN STD_LOGIC_VECTOR(10 DOWNTO 0); -- 11 instruction alu
            Rsrc1_Val_out, Rsrc2_Val_out, Dst_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            aluSelectors_out : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ALU IS
        PORT (
            A, B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALUControl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            Zero : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT EM_Buffer is
        port (   
            clk, reset, WE : in  std_logic;
            ALU_COUT : in std_logic;
            Dst_in : in  std_logic_vector(31 downto 0);
            ALU_OutValue_in : in  std_logic_vector(31 downto 0);
            ALU_COUT_OUT : out std_logic;
            ALU_OutValue_out, Dst_out : out std_logic_vector(31 downto 0)
        );
    end COMPONENT EM_Buffer;

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
            ALU_COUT : in std_logic;
            Dst_in : in  std_logic_vector(31 downto 0);
            ALU_OutValue_in : in  std_logic_vector(31 downto 0);
            ALU_COUT_OUT : out std_logic;
            ALU_OutValue_out, Dst_out : out std_logic_vector(31 downto 0)
        );
    end COMPONENT WB_Buffer;

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
        SIGNAL instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);
        SIGNAL opCode : STD_LOGIC_VECTOR(6 DOWNTO 0);
        SIGNAL Rsrc1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL Rsrc2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL Rdest : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL hasImm : STD_LOGIC;
        SIGNAL isBranch : STD_LOGIC;
        SIGNAL Rsrc1_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL Rsrc2_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL ALUResult : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL Zero : STD_LOGIC;
        SIGNAL WBdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL writeEnable : STD_LOGIC;
        SIGNAL cin : STD_LOGIC;
        SIGNAL ovf : STD_LOGIC;
        SIGNAL flags : STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL pointer : STD_LOGIC_VECTOR(11 DOWNTO 0);
        SIGNAL push : STD_LOGIC;
        SIGNAL pop : STD_LOGIC;
        SIGNAL pc_c : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL pcBranch : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL branch : STD_LOGIC;
        SIGNAL enable : STD_LOGIC;
        SIGNAL ALUControl : STD_LOGIC_VECTOR(2 DOWNTO 0);
    ------------------------------------SIGNALS END-----------------------------------

BEGIN
    ------------------------------------PORTS------------------------------------
    -- map instruction cache
    instrCache1 : InstrCache PORT MAP(
        clk => clk,
        rst => reset,
        pc => pc_c,
        data => instruction
    );

    -- map controller
    controller1 : controller PORT MAP(
        clk => clk,
        rst => reset,
        instruction => instruction,
        opCode => opCode,
        Rsrc1 => Rsrc1,
        Rsrc2 => Rsrc2,
        Rdest => Rdest,
        hasImm => hasImm,
        isBranch => isBranch
    );

    -- map register file
    registerFile1 : RegisterFile PORT MAP(
        clk => clk,
        rst => reset,
        Rsrc1_address => Rsrc1,
        Rsrc2_address => Rsrc2,
        Rdest => Rdest,
        WBdata => WBdata,
        writeEnable => writeEnable,
        Rsrc1_data => Rsrc1_data,
        Rsrc2_data => Rsrc2_data
    );

    -- map ALU
    alu1 : ALU PORT MAP(
        A => Rsrc1_data,
        B => Rsrc2_data,
        ALUControl => ALUControl,
        Result => ALUResult,
        Zero => Zero
    );

    -- map condition code register
    conditionCodeRegister1 : conditionCodeRegister PORT MAP(
        rst => reset,
        cin => cin,
        ovf => ovf,
        opResult => ALUResult,
        flags => flags
    );

    -- map SP
    sp1 : SP PORT MAP(
        reset => reset,
        push => push,
        pop => pop,
        pointer => pointer
    );

    -- map PC
    pc1 : PC PORT MAP(
        clk => clk,
        reset => reset,
        branch => branch,
        enable => enable,
        pcBranch => pcBranch,
        pc => pc_c
    );
    ------------------------------------PORTS END----------------------------------

    ------------------------------------PROCESS------------------------------------

    ----------------------------------END PROCESS----------------------------------

    -- map data memory

END ARCHITECTURE processorArch;