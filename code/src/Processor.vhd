LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Processor IS
    PORT (
        clk : IN STD_LOGIC;
        reset, we : IN STD_LOGIC;
        INT_In : IN STD_LOGIC := '0'; -- interrupt signal
        IN_PORT : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        exception : OUT STD_LOGIC; -- exception signal
        OUT_PORT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY Processor;

ARCHITECTURE ProcessorArch OF Processor IS

    ------------------------------------COMPONENTS------------------------------------
    COMPONENT PC IS
        GENERIC (
            N : INTEGER := 32
        );
        PORT (
            clk, RES : IN STD_LOGIC;
            PC_en : IN STD_LOGIC;
            PC_FWD : IN STD_LOGIC;
            PC_stall_PopUse : IN STD_LOGIC;
            PC_Interrupt : IN STD_LOGIC;
            PC_branch : IN STD_LOGIC;
            PC_corrected : IN STD_LOGIC;
            PC_POP_PC : IN STD_LOGIC;
            PC_JMP_EXE_PC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            PC_JMP_DEC_PC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            PC_FWD_PC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            PC_InterruptPC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            PC_ResetPC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            PC_RET_PC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

            PC_PC : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT InstrCache IS
        GENERIC (
            n : INTEGER := 16; -- number of bits per instruction
            m : INTEGER := 12; -- height of the cache
            k : INTEGER := 32 -- pc size
        );
        PORT (
            clk, RES : IN STD_LOGIC;
            IC_PC : IN STD_LOGIC_VECTOR(k - 1 DOWNTO 0);

            IC_data : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0); --so that i can read and write to
            PC_Reset : OUT STD_LOGIC_VECTOR(k - 1 DOWNTO 0); --to reset the PC
            PC_Interrupt : OUT STD_LOGIC_VECTOR(k - 1 DOWNTO 0) --to interrupt the PC
        );
    END COMPONENT;

    COMPONENT FD_Buffer IS
        PORT (
            clk : IN STD_LOGIC;
            RES : IN STD_LOGIC;
            WE : IN STD_LOGIC;
            FLUSH : IN STD_LOGIC;
            FD_stall_PopUse : IN STD_LOGIC;
            FD_INT : IN STD_LOGIC;
            FD_Flush_FD : IN STD_LOGIC;
            FD_Inst : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16 bits from instruction memory
            FD_IN_PORT : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            FD_current_PC_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            FD_OpCode : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            FD_Rsrc1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            FD_Rsrc2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            FD_Rdst1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            FD_Rdst2 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            FD_Func : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            FD_InputPort : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            FD_current_PC_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

            -- Passing through
            FD_isImm_in : IN STD_LOGIC
        );
    END COMPONENT FD_Buffer;

    COMPONENT RegisterFile IS
        GENERIC (
            w : INTEGER := 3;
            n : INTEGER := 32
        );
        PORT (
            clk, RES : IN STD_LOGIC;

            RE_we1 : IN STD_LOGIC;
            RF_we2 : IN STD_LOGIC;
            RF_Rdst1 : IN STD_LOGIC_VECTOR(w - 1 DOWNTO 0);
            RF_Rdst2 : IN STD_LOGIC_VECTOR(w - 1 DOWNTO 0);
            RF_Wdata1 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            RF_Wdata2 : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);

            RF_Rsrc1 : IN STD_LOGIC_VECTOR(w - 1 DOWNTO 0);
            RF_Rsrc2 : IN STD_LOGIC_VECTOR(w - 1 DOWNTO 0);

            RF_Rdata1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            RF_Rdata2 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT controller IS
        GENERIC (
            INST_WIDTH : INTEGER := 16
        );
        PORT (
            clk : IN STD_LOGIC;
            RES : IN STD_LOGIC;
            ctr_opCode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            ctr_Func : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            ctr_Correction : IN STD_LOGIC;
            ctr_POP_PC_in : IN STD_LOGIC;
            ctr_Push_PC_in : IN STD_LOGIC;
            ctr_Push_CCR_in : IN STD_LOGIC;
            ctr_PC_FWD : IN STD_LOGIC;

            ctr_POP_PC_out : OUT STD_LOGIC;
            ctr_hasImm : OUT STD_LOGIC;
            ctr_ALUsel : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            ctr_flags_en : OUT STD_LOGIC_VECTOR(0 TO 3);
            ctr_we1_reg : OUT STD_LOGIC;
            ctr_we2_reg : OUT STD_LOGIC;
            ctr_MemW : OUT STD_LOGIC;
            ctr_MemR : OUT STD_LOGIC;
            ctr_Push : OUT STD_LOGIC;
            ctr_Pop : OUT STD_LOGIC;
            ctr_Free : OUT STD_LOGIC;
            ctr_Protect : OUT STD_LOGIC;
            ctr_ALUorMem : OUT STD_LOGIC;
            ctr_isInput : OUT STD_LOGIC;
            ctr_src1_use : OUT STD_LOGIC;
            ctr_src2_use : OUT STD_LOGIC;
            ctr_JMP_DEC : OUT STD_LOGIC;
            ctr_JMP_EXE : OUT STD_LOGIC;
            ctr_Flush_FD : OUT STD_LOGIC;
            ctr_Flush_DE : OUT STD_LOGIC;
            ctr_Predictor : OUT STD_LOGIC;
            ctr_STD_use : OUT STD_LOGIC;
            ctr_Push_PC_out : OUT STD_LOGIC;
            ctr_Push_CCR_out : OUT STD_LOGIC;
            ctr_POP_CCR : OUT STD_LOGIC;
            ctr_zReset : OUT STD_LOGIC;

            ctr_OUTport_en : OUT STD_LOGIC;
            ctr_INT : OUT STD_LOGIC

            -- Passing through should be none its not a buffer
        );
    END COMPONENT controller;

    COMPONENT DE_Buffer IS
        PORT (
            clk, RES, WE, DE_flush_PopUse, FLUSH : IN STD_LOGIC;
            DE_Flush_DE : IN STD_LOGIC;
            DE_Rsrc1_Val : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            DE_Rsrc2_Val : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            DE_Imm : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            DE_isImm : IN STD_LOGIC;

            DE_Zflag : IN STD_LOGIC;
            DE_OpCode_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            DE_OpCode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            DE_Predictor : IN STD_LOGIC;
            DE_PC_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            DE_current_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            DE_ALUopd1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            DE_ALUopd2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

            DE_PC_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            DE_Correction : OUT STD_LOGIC;
            DE_PC_FWD : OUT STD_LOGIC;
            -- Passing through
            DE_InPort_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            DE_InPort_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            DE_zReset_in : IN STD_LOGIC;
            DE_zReset_out : OUT STD_LOGIC;

            DE_POP_PC_in : IN STD_LOGIC;
            DE_POP_PC_out : OUT STD_LOGIC;
            DE_POP_CCR_in : IN STD_LOGIC;
            DE_POP_CCR_out : OUT STD_LOGIC;
            DE_Push_CCR_in : IN STD_LOGIC;
            DE_Push_CCR_out : OUT STD_LOGIC;
            DE_Push_PC_in : IN STD_LOGIC;
            DE_Push_PC_out : OUT STD_LOGIC;
            -- Control signals
            DE_OUTport_en_in : IN STD_LOGIC;
            DE_OUTport_en_out : OUT STD_LOGIC;
            DE_isInput_in : IN STD_LOGIC;
            DE_isInput_out : OUT STD_LOGIC;
            DE_we1_reg_in : IN STD_LOGIC;
            DE_we1_reg_out : OUT STD_LOGIC;
            DE_we2_reg_in : IN STD_LOGIC;
            DE_we2_reg_out : OUT STD_LOGIC;
            DE_ALUorMem_in : IN STD_LOGIC;
            DE_ALUorMem_out : OUT STD_LOGIC;
            DE_flags_en_in : IN STD_LOGIC_VECTOR (0 TO 3);
            DE_flags_en_out : OUT STD_LOGIC_VECTOR (0 TO 3);
            DE_Rdst1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            DE_Rdst2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            DE_Rdst1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            DE_Rdst2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            DE_ALUsel_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            --MEMORY OPERATIONS SIGNALS
            DE_MemW_in : IN STD_LOGIC;
            DE_MemW_out : OUT STD_LOGIC;
            DE_MemR_in : IN STD_LOGIC;
            DE_MemR_out : OUT STD_LOGIC;
            DE_Push_in : IN STD_LOGIC;
            DE_Push_out : OUT STD_LOGIC;
            DE_Pop_in : IN STD_LOGIC;
            DE_Pop_out : OUT STD_LOGIC;
            DE_Protect_in : IN STD_LOGIC;
            DE_Protect_out : OUT STD_LOGIC;
            DE_Free_in : IN STD_LOGIC;
            DE_Free_out : OUT STD_LOGIC; -- for std 
            --END MEMORY OPERATIONS SIGNALS
            DE_ALUsel_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            --SRCS PROPAGATION
            DE_STD_VALUE : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

            DE_Rsrc1_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            DE_Rsrc2_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            DE_STD_address : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            DE_ALUopd1_address : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            DE_ALUopd2_address : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

            DE_src1_use_in : IN STD_LOGIC;
            DE_src1_use_out : OUT STD_LOGIC;
            DE_src2_use_in : IN STD_LOGIC;
            DE_src2_use_out : OUT STD_LOGIC;
            DE_STD_use_in : IN STD_LOGIC;
            DE_STD_use_out : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT ALU IS
        PORT (
            A, B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALU_sel : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Changed to 4 bits

            ALU_Result1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALU_Result2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Added for SWAP
            ALU_flags : OUT STD_LOGIC_VECTOR(0 TO 3)
        );
    END COMPONENT;

    COMPONENT EM_Buffer IS
        PORT (
            clk, RES, WE, FLUSH : IN STD_LOGIC;
            EM_Push_CCR : IN STD_LOGIC;
            EM_Push_PC : IN STD_LOGIC;
            EM_CCR : IN STD_LOGIC_VECTOR(0 TO 3);

            -- Passing through
            EM_OUTport_en_out : OUT STD_LOGIC;
            EM_OUTport_en_in : IN STD_LOGIC;
            EM_ALUorMem_in : IN STD_LOGIC;
            EM_ALUorMem_out : OUT STD_LOGIC;
            EM_we1_reg_in : IN STD_LOGIC;
            EM_we1_reg_out : OUT STD_LOGIC;
            EM_we2_reg_in : IN STD_LOGIC;
            EM_we2_reg_out : OUT STD_LOGIC;
            EM_Rdst1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            EM_Rdst1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            EM_Rdst2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            EM_Rdst2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            EM_ALUResult1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            EM_ALUResult1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            EM_ALUResult2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            EM_ALUResult2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            EM_POP_PC_in : IN STD_LOGIC;
            EM_POP_PC_out : OUT STD_LOGIC;
            EM_POP_CCR_in : IN STD_LOGIC;
            EM_POP_CCR_out : OUT STD_LOGIC;
            --MEMORY OPERATIONS SIGNALS
            EM_STD_VALUE_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            EM_STD_VALUE_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
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
            --srcs

        );
    END COMPONENT;

    COMPONENT DataMemory IS
        GENERIC (
            DATA_WIDTH : INTEGER := 17;
            ADDR_WIDTH : INTEGER := 12
        );

        PORT (
            clk, RES : IN STD_LOGIC;
            DM_MemR : IN STD_LOGIC;
            DM_MemW : IN STD_LOGIC;
            DM_Push : IN STD_LOGIC;
            DM_Pop : IN STD_LOGIC;
            DM_RAddr : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
            DM_WAddr : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
            DM_WData : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            DM_Free : IN STD_LOGIC;
            DM_Protect : IN STD_LOGIC;
            DM_Exception : OUT STD_LOGIC;
            DM_RData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            DM_SP : OUT INTEGER RANGE 0 TO 2 ** ADDR_WIDTH - 1
        );
    END COMPONENT;

    COMPONENT MW_Buffer IS
        PORT (
            clk, RES, WE, FLUSH : IN STD_LOGIC;
            MW_ALUorMem : IN STD_LOGIC;
            MW_ALUResult1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            MW_ALUResult2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            MW_MemResult : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            MW_value1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            MW_value2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

            -- Passing through

            MW_OUTport_en_out : OUT STD_LOGIC;
            MW_OUTport_en_in : IN STD_LOGIC;
            MW_we1_reg_in : IN STD_LOGIC;
            MW_we1_reg_out : OUT STD_LOGIC;
            MW_we2_reg_in : IN STD_LOGIC;
            MW_we2_reg_out : OUT STD_LOGIC;
            MW_Rdst1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            MW_Rdst1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            MW_Rdst2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            MW_Rdst2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            MW_POP_PC_in : IN STD_LOGIC;
            MW_POP_PC_out : OUT STD_LOGIC;
            MW_POP_CCR_in : IN STD_LOGIC;
            MW_POP_CCR_out : OUT STD_LOGIC;
            MW_flags : OUT STD_LOGIC_VECTOR(0 TO 3)

        );
    END COMPONENT MW_Buffer;

    COMPONENT SP IS
        GENERIC (
            WIDTH : INTEGER := 12
        );
        PORT (
            RES : IN STD_LOGIC;
            SP_Push : IN STD_LOGIC;
            SP_Pop : IN STD_LOGIC;

            SP_SP : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT CCR IS
        PORT (
            clk, RES : IN STD_LOGIC;
            CCR_POP_CCR : IN STD_LOGIC;
            CCR_zReset : IN STD_LOGIC;
            CCR_flags_in : IN STD_LOGIC_VECTOR (0 TO 3);
            CCR_flags_en : IN STD_LOGIC_VECTOR (0 TO 3);
            CCR_MEM_flags : IN STD_LOGIC_VECTOR (0 TO 3);

            CCR_flags_out : OUT STD_LOGIC_VECTOR (0 TO 3)
        );
    END COMPONENT CCR;

    COMPONENT FWDUnit IS
    PORT (
        RES, WE : IN STD_LOGIC;

        FWD_src1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        FWD_src2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        FWD_src1_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        FWD_src2_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        FWD_PC_OUT_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        FWD_dst1Exec : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        FWD_wb1Exec : IN STD_LOGIC;
        op_code : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        FWD_Data1Exec : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        FWD_Data2Exec : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        FWD_dst2Exec : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        FWD_wb2Exec : IN STD_LOGIC;

        FWD_Data1Mem : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        FWD_Data2Mem : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        FWD_dst1Mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        FWD_wb1Mem : IN STD_LOGIC;
        FWD_dst2Mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        FWD_wb2Mem : IN STD_LOGIC;

        ctr_src1_use : IN STD_LOGIC;
        ctr_src2_use : IN STD_LOGIC;

        ctr_STD_use : IN STD_LOGIC;
        FWD_STD_val : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        --for std 
        FWD_STD_src : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        FWD_PC_FWD : OUT STD_LOGIC;
        FWD_ALU_OPD_1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        FWD_ALU_OPD_2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        FWD_PC_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        FWD_STD_Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)

    );
    END COMPONENT FWDUnit;

    COMPONENT MemoryUse IS --for load and pop
        PORT (
            RES : IN STD_LOGIC;
            DE_Ctrl_Pop_Flag : IN STD_LOGIC;
            FD_src1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            FD_src2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            DE_dst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            FD_SRC1_USE : IN STD_LOGIC;
            FD_SRC2_USE : IN STD_LOGIC;
            DE_WE : IN STD_LOGIC;

            stall_PopUse : OUT STD_LOGIC;
            flush_DM : OUT STD_LOGIC
        );
    END COMPONENT MemoryUse;
    ------------------------------------COMPONENTS END-----------------------------------

    ------------------------------------SIGNALS------------------------------------
    -- PC signals
    SIGNAL PC_en : STD_LOGIC;
    SIGNAL PC_PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- PC signals end

    -- Instruction Cache signals
    SIGNAL IC_Inst : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL IC_InterruptPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL IC_ResetPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- Instruction Cache signals end

    -- FD Buffer signals
    SIGNAL FD_OpCode : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL FD_Rsrc1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL FD_Rsrc2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL FD_Rdst1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL FD_Rdst2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL FD_Func : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL FD_InputPort : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL FD_current_PC_out : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- FD Buffer signals end

    -- Register File signals
    SIGNAL RF_Rdata1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL RF_Rdata2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- Register File signals end

    -- DE Buffer signals
    SIGNAL DE_ALUopd1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DE_ALUopd2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DE_InPort_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DE_we1_reg_out : STD_LOGIC;
    SIGNAL DE_we2_reg_out : STD_LOGIC;
    SIGNAL DE_ALUorMem_out : STD_LOGIC;
    SIGNAL DE_OUTport_en_out : STD_LOGIC;
    SIGNAL DE_flags_en_out : STD_LOGIC_VECTOR (0 TO 3);
    SIGNAL DE_Rdst1_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL DE_Rdst2_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL DE_ALUsel_out : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL DE_MemW_out : STD_LOGIC;
    SIGNAL DE_MemR_out : STD_LOGIC;
    SIGNAL DE_Push_out : STD_LOGIC;
    SIGNAL DE_Pop_out : STD_LOGIC;
    SIGNAL DE_Protect_out : STD_LOGIC;
    SIGNAL DE_Free_out : STD_LOGIC;
    SIGNAL DE_STD_VALUE : STD_LOGIC_VECTOR(31 DOWNTO 0); -- for std
    SIGNAL DE_Correction : STD_LOGIC;
    SIGNAL DE_PC_FWD : STD_LOGIC;
    SIGNAL DE_POP_PC_out : STD_LOGIC;
    SIGNAL DE_PC_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DE_Push_CCR_out : STD_LOGIC;
    SIGNAL DE_Push_PC_out : STD_LOGIC;
    SIGNAL DE_POP_CCR_out : STD_LOGIC;
    SIGNAL DE_zReset_out : STD_LOGIC;
    SIGNAL DE_OpCode_out : STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- SRCS PROPAGATION

    SIGNAL DE_STD_address_signal : STD_LOGIC_VECTOR(2 DOWNTO 0);

    SIGNAL DE_ALUopd1_address_signal : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL DE_ALUopd2_address_signal : STD_LOGIC_VECTOR(2 DOWNTO 0);

    SIGNAL DE_src1_use_in_signal : STD_LOGIC;
    SIGNAL DE_src1_use_out_signal : STD_LOGIC;
    SIGNAL DE_src2_use_in_signal : STD_LOGIC;
    SIGNAL DE_src2_use_out_signal : STD_LOGIC;
    SIGNAL DE_STD_use_in_signal : STD_LOGIC;
    SIGNAL DE_STD_use_out_signal : STD_LOGIC;
    -- DE Buffer signals end

    -- ALU signals
    SIGNAL ALU_Result1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ALU_Result2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ALU_flags : STD_LOGIC_VECTOR(0 TO 3);
    -- ALU signals end

    -- EM Buffer signals 
    SIGNAL EM_POP_PC_out : STD_LOGIC;
    SIGNAL EM_ALUorMem_out : STD_LOGIC;
    SIGNAL EM_we1_reg_out : STD_LOGIC;
    SIGNAL EM_we2_reg_out : STD_LOGIC;
    SIGNAL EM_OUTport_en_out : STD_LOGIC;
    SIGNAL EM_Rdst1_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL EM_Rdst2_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL EM_ALUResult1_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL EM_ALUResult2_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL EM_POP_CCR_out : STD_LOGIC;
    -- MEMORY OPERATIONS SIGNALS
    SIGNAL EM_MemW_out : STD_LOGIC;
    SIGNAL EM_MemR_out : STD_LOGIC;
    SIGNAL EM_Push_out : STD_LOGIC;
    SIGNAL EM_Pop_out : STD_LOGIC;
    SIGNAL EM_Protect_out : STD_LOGIC;
    SIGNAL EM_Free_out : STD_LOGIC;
    SIGNAL EM_STD_VALUE : STD_LOGIC_VECTOR(31 DOWNTO 0); -- for std
    SIGNAL MW_POP_CCR_out : STD_LOGIC;
    -- EM Buffer signals end

    -- Data Memory signals
    SIGNAL DM_RData : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DM_SP_signal : INTEGER RANGE 0 TO 2 ** 12 - 1 := 0;
    -- Data Memory signals end

    -- MW Buffer signals
    SIGNAL MW_value1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MW_value2 : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL MW_POP_PC_out : STD_LOGIC;
    SIGNAL MW_we1_reg_out : STD_LOGIC;
    SIGNAL MW_we2_reg_out : STD_LOGIC;
    SIGNAL MW_OUTport_en_out : STD_LOGIC;
    SIGNAL MW_Rdst1_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL MW_Rdst2_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL MW_flags : STD_LOGIC_VECTOR(0 TO 3);
    -- MW Buffer signals end

    -- CCR signals
    SIGNAL CCR_flags : STD_LOGIC_VECTOR(0 TO 3);
    -- CCR signals end

    -- Controller Signals (most of the are not connected)
    SIGNAL ctr_hasImm : STD_LOGIC;
    SIGNAL ctr_ALUsel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL ctr_flags_en : STD_LOGIC_VECTOR(0 TO 3);
    SIGNAL ctr_we1_reg : STD_LOGIC;
    SIGNAL ctr_we2_reg : STD_LOGIC;
    SIGNAL ctr_ALUorMem : STD_LOGIC;
    SIGNAL ctr_isInput : STD_LOGIC;
    SIGNAL ctr_OUTport_en : STD_LOGIC;
    SIGNAL ctr_Predictor : STD_LOGIC;
    SIGNAL ctr_POP_PC_out : STD_LOGIC;
    -- Controller for memoryData
    SIGNAL ctr_MemW : STD_LOGIC;
    SIGNAL ctr_MemR : STD_LOGIC;
    SIGNAL ctr_Push : STD_LOGIC;
    SIGNAL ctr_Pop : STD_LOGIC;
    SIGNAL ctr_Free : STD_LOGIC;
    SIGNAL ctr_JMP_DEC : STD_LOGIC;
    SIGNAL ctr_JMP_EXE : STD_LOGIC;
    SIGNAL ctr_Flush_FD : STD_LOGIC;
    SIGNAL ctr_Flush_DE : STD_LOGIC;
    SIGNAL ctr_Protect : STD_LOGIC;
    SIGNAL ctr_Push_PC_out : STD_LOGIC;
    SIGNAL ctr_Push_CCR_out : STD_LOGIC;
    SIGNAL ctr_POP_CCR : STD_LOGIC;
    SIGNAL ctr_INT : STD_LOGIC;
    SIGNAL ctr_zReset : STD_LOGIC;
    -- Controller signals end
    SIGNAL NumberOfCycle : INTEGER := 0;

    --FWD signals

    --   SIGNAL ctr_src1_use_signal : std_logic;
    -- SIGNAL ctr_src2_use_signal : std_logic;
    -- SIGNAL ctr_STD_use_signal : std_logic;
    --   SIGNAL FWD_STD_src_signal : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL FWD_ALU_OPD_1_signal : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL FWD_ALU_OPD_2_signal : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL FWD_PC_OUT_signal : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DE_STD_Data_Final : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL FWD_PC_FWD : STD_LOGIC;
    -- SIGNAL FWD_STD_Data_signal : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --FWD signals end

    --MemoryUse signals
    SIGNAL stall_PopUse : STD_LOGIC;
    SIGNAL flush_DM : STD_LOGIC;
    --MemoryUse signals end
    ------------------------------------SIGNALS END-----------------------------------

BEGIN

    ------------------------------------PORTS------------------------------------

    -- map PC
    pc1 : PC PORT MAP(
        clk => clk,
        --from control signals 
        RES => reset,
        PC_branch => ctr_JMP_DEC,
        PC_corrected => ctr_JMP_EXE,
        PC_POP_PC => MW_POP_PC_out,
        PC_en => PC_en,
        PC_FWD => DE_PC_FWD,
        PC_Interrupt => ctr_INT, -- PROBABLY NEED TO CHANGE THIS AND TAKE IT AS AN INPUT TO THE PROCESSOR
        PC_stall_PopUse => stall_PopUse,
        PC_JMP_EXE_PC => DE_PC_out,
        PC_JMP_DEC_PC => RF_Rdata1,
        PC_InterruptPC => IC_InterruptPC,
        PC_ResetPC => IC_ResetPC,
        PC_RET_PC => MW_value1,
        PC_FWD_PC => FWD_PC_OUT_signal,
        PC_PC => PC_PC
    );
    -- map PC end

    -- map instruction cache
    instrCache1 : InstrCache PORT MAP(
        clk => clk,
        RES => reset,
        IC_PC => PC_PC,

        IC_data => IC_Inst,
        PC_Reset => IC_ResetPC,
        PC_Interrupt => IC_InterruptPC
    );
    -- map instruction cacheend

    -- map FD buffer
    fdBuffer1 : FD_Buffer PORT MAP(
        clk => clk,
        RES => reset,
        WE => we,
        FD_INT => INT_In,
        FD_Flush_FD => ctr_Flush_FD,
        FD_Inst => IC_Inst,
        FD_OpCode => FD_OpCode,
        FD_Rsrc1 => FD_Rsrc1,
        FD_Rsrc2 => FD_Rsrc2,
        FD_Rdst1 => FD_Rdst1,
        FD_Rdst2 => FD_Rdst2,
        FD_Func => FD_Func,
        FD_IN_PORT => IN_PORT,
        FD_stall_PopUse => stall_PopUse,
        -- Passing through
        FD_isImm_in => ctr_hasImm,
        FD_InputPort => FD_InputPort,
        FLUSH => '0',
        FD_current_PC_in => PC_PC,
        FD_current_PC_out => FD_current_PC_out

    );
    -- map FD buffer end

    -- map RegistersFiles
    Regfile : RegisterFile PORT MAP(
        clk => clk,
        RES => reset,

        RE_we1 => MW_we1_reg_out,
        RF_we2 => MW_we2_reg_out,
        RF_Rdst1 => MW_Rdst1_out,
        RF_Rdst2 => MW_Rdst2_out,
        RF_Wdata1 => MW_value1,
        RF_Wdata2 => MW_value2,

        RF_Rsrc1 => FD_Rsrc1,
        RF_Rsrc2 => FD_Rsrc2,

        RF_Rdata1 => RF_Rdata1,
        RF_Rdata2 => RF_Rdata2
    );
    -- map RegistersFiles end

    -- map DE buffer
    deBuffer1 : DE_Buffer PORT MAP(
        clk => clk,
        RES => reset,
        WE => we,
        DE_Flush_DE => ctr_Flush_DE,
        DE_Rsrc1_Val => RF_Rdata1,
        DE_Rsrc2_Val => RF_Rdata2,
        DE_Imm => IC_Inst,
        DE_isImm => ctr_hasImm,
        DE_Zflag => CCR_flags(0),
        DE_OpCode => FD_OpCode,
        DE_Predictor => ctr_Predictor,
        DE_PC_in => PC_PC,
        DE_current_PC => FD_current_PC_out,

        DE_ALUopd1 => DE_ALUopd1,
        DE_ALUopd2 => DE_ALUopd2,
        DE_PC_out => DE_PC_out,
        DE_Correction => DE_Correction,
        DE_PC_FWD => DE_PC_FWD,
        DE_OpCode_out => DE_OpCode_out,

        -- Passing through
        DE_InPort_in => FD_InputPort,
        DE_InPort_out => DE_InPort_out,
        DE_isInput_in => ctr_isInput,
        DE_we1_reg_in => ctr_we1_reg,
        DE_we2_reg_in => ctr_we2_reg,
        DE_ALUorMem_in => ctr_ALUorMem,
        DE_flags_en_in => ctr_flags_en,
        DE_Rdst1_in => FD_Rdst1,
        DE_Rdst2_in => FD_Rdst2,
        DE_ALUsel_in => ctr_ALUsel,
        DE_OUTport_en_in => ctr_OUTport_en,
        DE_POP_PC_in => ctr_POP_PC_out,
        DE_Push_PC_in => ctr_Push_PC_out,
        DE_Push_PC_out => DE_Push_PC_out,
        DE_Push_CCR_in => ctr_Push_CCR_out,
        DE_Push_CCR_out => DE_Push_CCR_out,

        DE_we1_reg_out => DE_we1_reg_out,
        DE_we2_reg_out => DE_we2_reg_out,
        DE_ALUorMem_out => DE_ALUorMem_out,
        DE_flags_en_out => DE_flags_en_out,
        DE_Rdst1_out => DE_Rdst1_out,
        DE_Rdst2_out => DE_Rdst2_out,
        DE_ALUsel_out => DE_ALUsel_out,
        DE_OUTport_en_out => DE_OUTport_en_out,
        DE_POP_PC_out => DE_POP_PC_out,
        --Data Memory Signals
        DE_MemW_in => ctr_MemW,
        DE_MemW_out => DE_MemW_out,
        DE_MemR_in => ctr_MemR,
        DE_MemR_out => DE_MemR_out,
        DE_Push_in => ctr_Push,
        DE_Push_out => DE_Push_out,
        DE_Pop_in => ctr_Pop,
        DE_Pop_out => DE_Pop_out,
        DE_Protect_in => ctr_Protect,
        DE_Protect_out => DE_Protect_out,
        DE_Free_in => ctr_Free,
        DE_Free_out => DE_Free_out,
        DE_STD_VALUE => DE_STD_VALUE,

        -- SRCS PROPAGATION

        DE_Rsrc1_address => FD_Rsrc1,
        DE_Rsrc2_address => FD_Rsrc2,

        DE_STD_address => DE_STD_address_signal,
        DE_ALUopd1_address => DE_ALUopd1_address_signal,
        DE_ALUopd2_address => DE_ALUopd2_address_signal,

        DE_src1_use_in => DE_src1_use_in_signal,
        DE_src1_use_out => DE_src1_use_out_signal,
        DE_src2_use_in => DE_src2_use_in_signal,
        DE_src2_use_out => DE_src2_use_out_signal,
        DE_STD_use_in => DE_STD_use_in_signal,
        DE_STD_use_out => DE_STD_use_out_signal,
        FLUSH => '0',
        --mem use 
        DE_flush_PopUse => flush_DM,
        DE_POP_CCR_in => ctr_POP_CCR,
        DE_POP_CCR_out => DE_POP_CCR_out,
        DE_zReset_in => ctr_zReset,
        DE_zReset_out => DE_zReset_out
    );
    -- map DE buffer end

    -- map ALU
    alu1 : ALU PORT MAP(
        A => FWD_ALU_OPD_1_signal,
        B => FWD_ALU_OPD_2_signal,
        ALU_sel => DE_ALUsel_out,

        ALU_Result1 => ALU_Result1,
        ALU_Result2 => ALU_Result2,
        ALU_flags => ALU_flags
    );
    -- map ALU end

    -- map EM buffer
    emBuffer1 : EM_Buffer PORT MAP(
        clk => clk,
        RES => reset,
        WE => we,
        --EM_flush_PopUse => flush_DM,
        EM_Push_CCR => DE_Push_CCR_out,
        EM_Push_PC => DE_Push_PC_out,
        EM_CCR => CCR_flags,

        -- Passing through
        EM_ALUorMem_in => DE_ALUorMem_out,
        EM_we1_reg_in => DE_we1_reg_out,
        EM_we2_reg_in => DE_we2_reg_out,
        EM_Rdst1_in => DE_Rdst1_out,
        EM_Rdst2_in => DE_Rdst2_out,
        EM_ALUResult1_in => ALU_Result1,
        EM_ALUResult2_in => ALU_Result2,
        EM_OUTport_en_in => DE_OUTport_en_out,
        EM_POP_PC_in => DE_POP_PC_out,

        EM_ALUorMem_out => EM_ALUorMem_out,
        EM_we1_reg_out => EM_we1_reg_out,
        EM_we2_reg_out => EM_we2_reg_out,
        EM_Rdst1_out => EM_Rdst1_out,
        EM_Rdst2_out => EM_Rdst2_out,
        EM_ALUResult1_out => EM_ALUResult1_out,
        EM_ALUResult2_out => EM_ALUResult2_out,
        EM_OUTport_en_out => EM_OUTport_en_out,
        EM_POP_PC_out => EM_POP_PC_out,
        --MEMORY OPERATIONS SIGNALS
        EM_MemW_in => DE_MemW_out,
        EM_MemW_out => EM_MemW_out,
        EM_MemR_in => DE_MemR_out,
        EM_MemR_out => EM_MemR_out,
        EM_Push_in => DE_Push_out,
        EM_Push_out => EM_Push_out,
        EM_Pop_in => DE_Pop_out,
        EM_Pop_out => EM_Pop_out,
        EM_Protect_in => DE_Protect_out,
        EM_Protect_out => EM_Protect_out,
        EM_Free_in => DE_Free_out,
        EM_Free_out => EM_Free_out,
        EM_STD_VALUE_in => DE_STD_Data_Final,
        EM_STD_VALUE_out => EM_STD_VALUE,
        FLUSH => '0',
        EM_POP_CCR_in => DE_POP_CCR_out,
        EM_POP_CCR_out => EM_POP_CCR_out
    );
    -- map EM buffer end

    -- map DataMemory
    DataMemory1 : DataMemory PORT MAP(
        clk => clk,
        RES => reset,
        DM_MemR => EM_MemR_out,
        DM_MemW => EM_MemW_out,
        DM_Push => EM_Push_out,
        DM_Pop => EM_Pop_out,

        DM_RAddr => EM_ALUResult1_out(11 DOWNTO 0),
        DM_WAddr => EM_ALUResult1_out(11 DOWNTO 0),
        DM_WData => EM_STD_VALUE, --EM_ALUResult1_out, -- need to modify for push and std 

        DM_Free => EM_Free_out,
        DM_Protect => EM_Protect_out,
        DM_Exception => exception,
        DM_RData => DM_RData,
        DM_SP => DM_SP_signal
    );
    -- map DataMemory end

    -- map MW buffer
    MW_Buffer1 : MW_Buffer PORT MAP(
        clk => clk,
        RES => reset,
        WE => we,
        MW_ALUorMem => EM_ALUorMem_out,
        MW_ALUResult1 => EM_ALUResult1_out,
        MW_ALUResult2 => EM_ALUResult2_out,
        MW_MemResult => DM_RData,

        MW_value1 => MW_value1,
        MW_value2 => MW_value2,

        -- Passing through
        MW_we1_reg_in => EM_we1_reg_out,
        MW_we2_reg_in => EM_we2_reg_out,
        MW_Rdst1_in => EM_Rdst1_out,
        MW_Rdst2_in => EM_Rdst2_out,
        MW_OUTport_en_in => EM_OUTport_en_out,
        MW_POP_PC_in => EM_POP_PC_out,

        MW_we1_reg_out => MW_we1_reg_out,
        MW_we2_reg_out => MW_we2_reg_out,
        MW_Rdst1_out => MW_Rdst1_out,
        MW_Rdst2_out => MW_Rdst2_out,
        MW_OUTport_en_out => MW_OUTport_en_out,
        MW_POP_PC_out => MW_POP_PC_out,
        FLUSH => '0',
        MW_POP_CCR_in => EM_POP_CCR_out,
        MW_POP_CCR_out => MW_POP_CCR_out,
        MW_flags => MW_flags
    );
    -- map MW buffer end

    -- map controller 
    Ctrl : controller GENERIC MAP(16)
    PORT MAP(
        clk => clk,
        RES => reset,
        ctr_opCode => FD_OpCode,
        ctr_Func => FD_Func,
        ctr_Correction => DE_Correction,
        ctr_POP_PC_in => MW_POP_PC_out,
        ctr_Push_PC_in => DE_Push_PC_out,
        ctr_Push_CCR_in => DE_Push_CCR_out,
        ctr_PC_FWD => FWD_PC_FWD,

        ctr_hasImm => ctr_hasImm,
        ctr_ALUsel => ctr_ALUsel,
        ctr_flags_en => ctr_flags_en,
        ctr_we1_reg => ctr_we1_reg,
        ctr_we2_reg => ctr_we2_reg,
        ctr_ALUorMem => ctr_ALUorMem,
        ctr_isInput => ctr_isInput,
        ctr_OUTport_en => ctr_OUTport_en,
        ctr_MemW => ctr_MemW,
        ctr_MemR => ctr_MemR,
        ctr_Push => ctr_Push,
        ctr_Pop => ctr_Pop,
        ctr_Free => ctr_Free,
        ctr_Protect => ctr_Protect,
        ctr_JMP_DEC => ctr_JMP_DEC,
        ctr_JMP_EXE => ctr_JMP_EXE,
        ctr_Flush_FD => ctr_Flush_FD,
        ctr_Flush_DE => ctr_Flush_DE,
        ctr_Predictor => ctr_Predictor,
        ctr_POP_PC_out => ctr_POP_PC_out,
        ctr_Push_PC_out => ctr_Push_PC_out,
        ctr_Push_CCR_out => ctr_Push_CCR_out,
        ctr_POP_CCR => ctr_POP_CCR,
        ctr_INT => ctr_INT,
        -- Passing through
        ctr_src1_use => DE_src1_use_in_signal,
        ctr_src2_use => DE_src2_use_in_signal,
        ctr_STD_use => DE_STD_use_in_signal,
        ctr_zReset => ctr_zReset

    );
    -- map controller end

    -- map CCR
    CCR1 : CCR PORT MAP(
        clk => clk,
        RES => reset,
        CCR_flags_in => ALU_flags,
        CCR_flags_en => DE_flags_en_out,
        CCR_POP_CCR => MW_POP_CCR_out,
        CCR_zReset => DE_zReset_out,
        CCR_MEM_flags => MW_flags,
        CCR_flags_out => CCR_flags
    );
    -- map CCR end

    -- map FWD
    FWD1 : FWDUnit PORT MAP(
        RES => reset,
        WE => we,

        FWD_src1 => DE_ALUopd1_address_signal, --
        FWD_src2 => DE_ALUopd2_address_signal,

        FWD_src1_Data => DE_ALUopd1,
        FWD_src2_Data => DE_ALUopd2,
        FWD_PC_OUT_Data => DE_PC_out,
        FWD_dst1Exec => EM_Rdst1_out,
        FWD_wb1Exec => EM_we1_reg_out,

        FWD_Data1Exec => EM_ALUResult1_out,
        FWD_Data2Exec => EM_ALUResult2_out,

        FWD_dst2Exec => EM_Rdst2_out,
        FWD_wb2Exec => EM_we2_reg_out,

        FWD_Data1Mem => MW_value1,
        FWD_Data2Mem => MW_value2,

        FWD_dst1Mem => MW_Rdst1_out,
        FWD_wb1Mem => MW_we1_reg_out,
        FWD_dst2Mem => MW_Rdst2_out,
        FWD_wb2Mem => MW_we2_reg_out,

        ctr_src1_use => DE_src1_use_out_signal,
        ctr_src2_use => DE_src2_use_out_signal,

        ctr_STD_use => DE_STD_use_out_signal,
        FWD_STD_val => DE_STD_VALUE,

        op_code => DE_OpCode_out,
        FWD_PC_FWD => FWD_PC_FWD,

        FWD_STD_src => DE_STD_address_signal,
        FWD_ALU_OPD_1 => FWD_ALU_OPD_1_signal,
        FWD_ALU_OPD_2 => FWD_ALU_OPD_2_signal,
        FWD_PC_OUT => FWD_PC_OUT_signal,
        FWD_STD_Data => DE_STD_Data_Final
    );
    -- map FWD end

    -- map MemoryUse
    MemoryUse1 : MemoryUse PORT MAP(
        RES => reset,
        DE_Ctrl_Pop_Flag => DE_Pop_out,
        FD_src1 => FD_Rsrc1,
        FD_src2 => FD_Rsrc2,
        DE_dst => DE_Rdst1_out, -- prolly will need to change for swap 
        stall_PopUse => stall_PopUse,
        flush_DM => flush_DM,
        FD_SRC1_USE => DE_src1_use_in_signal,
        FD_SRC2_USE => DE_src2_use_in_signal,
        DE_WE => DE_we1_reg_out
    );
    ------------------------------------PORTS END----------------------------------
    -----------------------------------PROCESS----------------------------------

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            NumberOfCycle <= NumberOfCycle + 1;
        END IF;
        IF MW_OUTport_en_out = '1' THEN
            OUT_PORT <= MW_value1;
            ELSE
            OUT_PORT <= (OTHERS => '0');
        END IF;
    END PROCESS;

    --process for the PC-Reset port 
    -- process (clk,IC_InterruptPC)
    -- begin  
    --          PC_ResetPC <= IC_ResetPC;
    -- end process;
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
    --process for the PC-Reset port 
    -- process (clk,IC_InterruptPC)
    -- begin  
    --          PC_ResetPC <= IC_ResetPC;
    -- end process;
    --i added those because we will need them later and for test cases
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
    --------------------------------END PROCESS----------------------------------

END ARCHITECTURE ProcessorArch;
