library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CPU is
    port (
        -- Input cuma enable sama clock
        -- Untuk opcode, operand, output dsb ditulis didalam file
        enable : in std_logic;
        reset : in std_logic;
        clk : in std_logic
    );
end entity CPU;

architecture rtl of CPU is
    -- Component Declaration (Ada 3 component)
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

    -- CPU dibagi menjadi 4 state, Idle, Fetch, Decode, Execute
    type StateType is (IDLE, FETCH, DECODE, EXECUTE, STORE);
    signal State : StateType := IDLE;

    -- Simple register, 16 bit, signed!
    signal REGISTER_A : std_logic_vector(15 downto 0) := (others => 'Z');
    signal REGISTER_B : std_logic_vector(15 downto 0) := (others => 'Z');
    signal REGISTER_C : std_logic_vector(15 downto 0) := (others => 'Z');
    
    -- Program Counter, 6 bit, unsigned!
    signal PROG_CTR : std_logic_vector(5 downto 0) := "000001";

    -- Instruction Buffer, didapatkan saat cycle fetch
    -- 4-bit opcode, 8-bit operand
    signal INSTR_BUFF : std_logic_vector(11 downto 0) := (others => 'Z');
    signal OPCODE : std_logic_vector(3 downto 0) := (others => 'Z');
    signal OPERAND : std_logic_vector(7 downto 0) := (others => 'Z');

    -- Flags
    signal equals : std_logic := 'Z';   -- Flag diatur oleh NOEQ dan ISEQ
    signal active : std_logic := '0';   -- CPU sedang active (non-idle)

    -- Fetcher, Decode, ALU enable
    signal FETCH_ENA : std_logic := '0';
    signal DECODE_ENA : std_logic := '0';
    signal ALU_ENA : std_logic := '0';
    signal STORE_ENA : std_logic := '0';
begin
    ALU_COMP : ALU port map(clk, ALU_ENA, STORE_ENA, OPCODE, OPERAND, PROG_CTR, REGISTER_A, REGISTER_B, REGISTER_C, equals);
    DECODER_COMP : Decoder port map(clk, DECODE_ENA, INSTR_BUFF, OPERAND, OPCODE);
    FETCHER_COMP : Fetcher port map(clk, FETCH_ENA, active, INSTR_BUFF);
    process(clk) is
    begin
        if rising_edge(clk) then
            case State is
            when IDLE =>
                -- Hanya bisa 1 tombol yang aktif
                -- Bisa reset doang
                if(reset = '1' AND enable = '0') then
                    REGISTER_A <= (others => 'Z');
                    REGISTER_B <= (others => 'Z');
                    REGISTER_C <= (others => 'Z');
                    PROG_CTR <= "000001";

                    equals <= 'Z';
                    active <= 'Z';

                    FETCH_ENA <= '0';
                    DECODE_ENA <= '0';
                    ALU_ENA <= '0';
                    STORE_ENA <= '0';
                    INSTR_BUFF <= (others => 'Z');
                    OPCODE <= (others => 'Z');
                    OPERAND <= (others => 'Z');
                end if;
                -- atau enable doang
                if(enable = '1' AND reset = '0') then
                    active <= '1';
                    State <= FETCH;
                    ALU_ENA <= '0';
                    FETCH_ENA <= '1';
                end if;

            -- Di-handle oleh Fetcher
            when FETCH =>
                if(active = '1') then
                    FETCH_ENA <= '0';
                    DECODE_ENA <= '1';
                end if;
                State <= DECODE;

            -- Di-handle oleh Decoder
            when DECODE =>
                if(active = '1') then
                    DECODE_ENA <= '0';
                    ALU_ENA <= '1';
                end if;
                State <= EXECUTE;

            -- Di-handle oleh ALU
            when EXECUTE =>
                if(active = '1') then
                    State <= STORE;
                    STORE_ENA <= '1';
                else
                    State <= IDLE;
                end if;

            -- Di-handle oleh ALU juga
            when STORE =>
                if(active ='1') then
                    ALU_ENA <= '0';
                    STORE_ENA <= '0';
                    FETCH_ENA <= '1';
                    State <= FETCH;
                else
                    State <= IDLE;
                end if;
                PROG_CTR <= std_logic_vector(to_unsigned(to_integer(unsigned(PROG_CTR))+1, 6));
            
            when others =>
            end case;
        end if;
    end process;
end architecture rtl;