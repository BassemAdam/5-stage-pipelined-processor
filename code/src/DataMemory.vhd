LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY DataMemory IS
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
END ENTITY DataMemory;

ARCHITECTURE DataMemory_arch OF dataMemory IS

    TYPE memory IS ARRAY(0 TO 4095) OF STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL mem : memory := (OTHERS => (OTHERS => '0'));
    SIGNAL sp : INTEGER RANGE 0 TO 2 ** ADDR_WIDTH - 1 := 4095;
BEGIN
    PROCESS (clk, RES)
    BEGIN

        IF RES = '1' THEN
            mem <= (OTHERS => (OTHERS => '0'));

        ELSIF rising_edge(clk) THEN

            IF DM_MemW = '1' THEN
                IF mem(to_integer(unsigned(DM_WAddr)))(16) = '1' THEN
                    DM_Exception <= '1';
                ELSE
                    mem(to_integer(unsigned(DM_WAddr)))(15 DOWNTO 0) <= DM_WData(15 DOWNTO 0);
                    mem(to_integer(unsigned(DM_WAddr)) + 1)(15 DOWNTO 0) <= DM_WData(31 DOWNTO 16);
                END IF;
            ELSIF DM_MemR = '1' THEN
                --DM_RData <= mem(to_integer(unsigned(DM_RAddr)));
                DM_RData(15 DOWNTO 0) <= mem(to_integer(unsigned(DM_RAddr)))(15 DOWNTO 0);
                DM_RData(31 DOWNTO 16) <= (OTHERS => '0');
                -- DM_RData(31 DOWNTO 16) <= mem(to_integer(unsigned(DM_RAddr)) + 1)(15 DOWNTO 0) ;
            ELSIF DM_Push = '1' THEN
                IF sp = 0 OR mem(sp)(16) = '1' OR mem(sp - 1)(16) = '1' THEN
                    DM_Exception <= '1';
                ELSE
                    sp <= sp - 2;
                    mem(sp - 1)(15 DOWNTO 0) <= DM_WData(15 DOWNTO 0);
                    mem(sp)(15 DOWNTO 0) <= DM_WData(31 DOWNTO 16);
                END IF;
            ELSIF DM_Pop = '1' THEN
                IF sp = 4095 OR mem(sp + 1)(16) = '1' OR mem(sp + 2)(16) = '1' THEN
                    DM_Exception <= '1';
                ELSE
                    DM_RData(15 DOWNTO 0) <= mem(sp + 1)(15 DOWNTO 0);
                    DM_RData(31 DOWNTO 16) <= mem(sp + 2)(15 DOWNTO 0);
                    mem(sp + 1) <= (OTHERS => '0');
                    mem(sp + 2) <= (OTHERS => '0');
                    sp <= sp + 2;
                END IF;
            ELSIF DM_Protect = '1' THEN
                mem(to_integer(unsigned(DM_WAddr)))(16) <= '1';
            ELSIF DM_Free = '1' THEN
                mem(to_integer(unsigned(DM_WAddr)))(16) <= '0';
            END IF;
        END IF;
    END PROCESS;
    DM_SP <= sp;
END ARCHITECTURE DataMemory_arch;