library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity processor is
    port (
        clk : in std_logic;
        reset : in std_logic;
        INT_In : in std_logic;  -- interrupt signal
        exception : out std_logic;  -- exception signal
        IN_PORT : in std_logic_vector(7 downto 0);
        OUT_PORT : out std_logic_vector(7 downto 0)
    );

    


end entity processor;

architecture processorArch of processor is
    signal instruction : std_logic_vector(15 downto 0);
    signal opCode : std_logic_vector(6 downto 0);
    signal Rsrc1 : std_logic_vector(2 downto 0);
    signal Rsrc2 : std_logic_vector(2 downto 0);
    signal Rdest : std_logic_vector(2 downto 0);
    signal hasImm : std_logic;
    signal isBranch : std_logic;
    signal Rsrc1_data : std_logic_vector(31 downto 0);
    signal Rsrc2_data : std_logic_vector(31 downto 0);
    signal ALUResult : std_logic_vector(31 downto 0);
    signal Zero : std_logic;
    signal WBdata : std_logic_vector(31 downto 0);
    signal writeEnable : std_logic;
    signal cin : std_logic;
    signal ovf : std_logic;
    signal flags : std_logic_vector(3 downto 0);
    signal pointer : std_logic_vector(11 downto 0);
    signal push : std_logic;
    signal pop : std_logic;
    signal pc_c : std_logic_vector(31 downto 0);
    signal pcBranch : std_logic_vector(31 downto 0);
    signal branch : std_logic;
    signal enable : std_logic;
    signal ALUControl : std_logic_vector(2 downto 0);



    component ALU is
        port(
            A, B: in std_logic_vector(31 downto 0);
            ALUControl: in std_logic_vector(2 downto 0);
            Result: out std_logic_vector(31 downto 0);
            Zero: out std_logic
        );
    end component;

    component RegisterFile is
        GENERIC (
            w : INTEGER := 3;
            n : INTEGER := 32
        );
        PORT (
            clk, rst : IN STD_LOGIC;
            Rsrc1_address, Rsrc2_address : IN STD_LOGIC_VECTOR(w-1 DOWNTO 0);
            Rdest : IN STD_LOGIC_VECTOR(w-1 DOWNTO 0);
            WBdata : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
            writeEnable : IN STD_LOGIC;
            Rsrc1_data, Rsrc2_data : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
        );
    end component;

    component DataMemory is
        generic(
        DATA_WIDTH : integer := 32;
        ADDR_WIDTH : integer := 12
        );
    
        port(
        rst : in std_logic;
        clk : in std_logic;
        memWrite : in std_logic;
        memRead : in std_logic;
        writeAddress : in unsigned(ADDR_WIDTH - 1 downto 0);
        readAddress : in unsigned(ADDR_WIDTH - 1 downto 0);
        writeData : in unsigned(DATA_WIDTH - 1 downto 0);
        readData : out unsigned(DATA_WIDTH - 1 downto 0)
        );
    end component;

    component InstrCache IS
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
    END component;

    component controller is 
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
    end component;

    component conditionCodeRegister is
        port (
            rst : in std_logic;
            cin : in std_logic;
            ovf : in std_logic;
            opResult : in std_logic_vector(31 downto 0);
            flags : out std_logic_vector(3 downto 0)
        );
    end component;

    component MUX_2x1 is
        generic(
            N : integer := 8
        );
        port(
            I0, I1 : in std_logic_vector(N-1 downto 0);
            S : in std_logic;
            O : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component MUX_4x1 is
        generic(
            N : integer := 8
        );
        port(
            I0, I1, I2, I3 : in std_logic_vector(N - 1  downto 0);
            S : in std_logic_vector(1 downto 0);
            O : out std_logic_vector(N - 1  downto 0)
        );
    end component;

    component PC is 
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
    END component;

    component SP is 
    generic(
        WIDTH: integer := 12
    );
    port(
    reset: in std_logic;
    push: in std_logic;
    pop: in std_logic;
    pointer: out std_logic_vector(WIDTH - 1 downto 0)
    );
    end component;

    component nBuffer is 
    generic (
        N : positive := 16 --instruction width
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        din : in std_logic_vector(N-1 downto 0);
        dout : out std_logic_vector(N-1 downto 0)
    );
    end component;

    begin
        -- map instruction cache
        instrCache1: InstrCache port map(
            clk => clk,
            rst => reset,
            pc => pc_c,
            data => instruction
        );

        -- map controller
        controller1: controller port map(
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
        registerFile1: RegisterFile port map(
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
        alu1: ALU port map(
            A => Rsrc1_data,
            B => Rsrc2_data,
            ALUControl => ALUControl,
            Result => ALUResult,
            Zero => Zero
        );

        -- map condition code register
        conditionCodeRegister1: conditionCodeRegister port map(
            rst => reset,
            cin => cin,
            ovf => ovf,
            opResult => ALUResult,
            flags => flags
        );

        -- map SP
        sp1: SP port map(
            reset => reset,
            push => push,
            pop => pop,
            pointer => pointer
        );

        -- map PC
        pc1:PC port map(
            clk => clk,
            reset => reset,
            branch => branch,
            enable => enable,
            pcBranch => pcBranch,
            pc => pc_c
        );

        -- map data memory



    end architecture processorArch;        