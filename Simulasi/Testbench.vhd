library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Testbench is
end entity Testbench;

architecture tb of Testbench is
    signal enable : std_logic;
    signal reset : std_logic;
    signal clk : std_logic;
    type StateType is (IDLE, FETCH, DECODE, EXECUTE, STORE);
    signal State : StateType := IDLE;

    signal REGISTER_A : std_logic_vector(15 downto 0) := (others => 'Z');
    signal REGISTER_B : std_logic_vector(15 downto 0) := (others => 'Z');
    signal REGISTER_C : std_logic_vector(15 downto 0) := (others => 'Z');

    signal PROG_CTR : std_logic_vector(5 downto 0) := "000001";

    signal INSTR_BUFF : std_logic_vector(11 downto 0) := (others => '0');
    signal OPCODE : std_logic_vector(3 downto 0) := (others => '0');
    signal OPERAND : std_logic_vector(7 downto 0) := (others => '0');

    signal equals : std_logic := 'Z';   -- Flag diatur oleh NOEQ dan ISEQ
    signal active : std_logic := '0';   -- CPU sedang active (non-idle)

    signal FETCH_ENA : std_logic := '0';
    signal DECODE_ENA : std_logic := '0';
    signal ALU_ENA : std_logic := '0';
    signal STORE_ENA : std_logic := '0';

    SIGNAL REG_DEST : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL REG_FROM : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL REG_IMM : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL EQ_FLAG : STD_LOGIC;
    SIGNAL skip : STD_LOGIC := '0';

    component CPU is
        port (
            enable : in std_logic;
            reset : in std_logic;
            clk : in std_logic
        );
    end component;
    component ALU is
        port (
            clk : in std_logic;
            ena : in std_logic;
            store : in std_logic;
            OPCODE : in std_logic_vector(3 downto 0);
            OPERAND : in std_logic_vector(7 downto 0);
            PROG_CTR : in std_logic_vector(5 downto 0);
            REGISTER_A : inout std_logic_vector(15 downto 0);
            REGISTER_B : inout std_logic_vector(15 downto 0);
            REGISTER_C : inout std_logic_vector(15 downto 0);
            equals : inout std_logic
        );
    end component;
    component Decoder is
        port (
            clk : in std_logic;
            ena : in std_logic;
            INSTR_BUFF : in std_logic_vector(11 downto 0);
            OPERAND : out std_logic_vector(7 downto 0);
            OPCODE : out std_logic_vector(3 downto 0)
        );
    end component;
    component Fetcher is
        port (
            clk : in std_logic;
            ena : in std_logic;
            active : out std_logic;
            INSTR_BUFF : out std_logic_vector(11 downto 0)
        );
    end component;

begin
    UUT_CPU : CPU port map(enable, reset, clk);
    UUT_ALU : ALU port map(clk, ALU_ENA, STORE_ENA, OPCODE, OPERAND, PROG_CTR, REGISTER_A, REGISTER_B, REGISTER_C, equals);
    UUT_DECODER : Decoder port map(clk, DECODE_ENA, INSTR_BUFF, OPERAND, OPCODE);
    UUT_FETCHER : Fetcher port map(clk, FETCH_ENA, active, INSTR_BUFF);

    process is
        variable prog_ctr : integer := 1;
    begin
        enable <= '1';
        reset <= '0';
        while prog_ctr < 64*5 loop
            clk <= '1';
            wait for 50 ps;
            clk <= '0';
            wait for 50 ps;
            prog_ctr := prog_ctr + 1;
        end loop;
        wait;
    end process;
end architecture tb;