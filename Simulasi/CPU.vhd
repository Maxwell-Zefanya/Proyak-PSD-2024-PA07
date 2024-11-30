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
    -- CPU dibagi menjadi 4 state, Idle, Fetch, Decode, Execute
    type StateType is (IDLE, FETCH, DECODE, EXECUTE);
    signal State : StateType := IDLE;

    -- Simple register, 16 bit, signed!
    signal REGISTER_A : std_logic_vector(15 downto 0) := (others => '0');
    signal REGISTER_B : std_logic_vector(15 downto 0) := (others => '0');
    signal REGISTER_C : std_logic_vector(15 downto 0) := (others => '0');
    
    -- Program Counter, 6 bit, unsigned!
    signal PROG_CTR : std_logic_vector(5 downto 0) := "000001";

    -- Instruction Buffer, didapatkan saat cycle fetch
    -- 4-bit opcode, 8-bit operand
    signal INSTR_BUFF : std_logic_vector(11 downto 0) := (others => '0');
    signal OPCODE : std_logic_vector(3 downto 0) := (others => '0');
    signal OPERAND : std_logic_vector(7 downto 0) := (others => '0');

    -- Flags
    signal equals : std_logic := '0';   -- Hasil dari CMP sama
    signal active : std_logic := '0';   -- CPU sedang active (non-idle)

    -- Fetcher, Decode, ALU enable
    signal FETCH_ENA : std_logic := '0';
    signal DECODE_ENA : std_logic := '0';
    signal ALU_ENA : std_logic := '0';
begin
    process(clk) is
    begin
        if rising_edge(clk) then
            case State is
            when IDLE =>
                -- Disable ALU pada saat IDLE
                ALU_ENA <= '0';
                -- Hanya bisa 1 tombol yang aktif
                -- Bisa reset doang
                if(reset = '1' AND enable = '0') then
                    REGISTER_A <= (others => '0');
                    REGISTER_B <= (others => '0');
                    REGISTER_C <= (others => '0');
                    PROG_CTR <= "000001";
                    equals <= '0';
                    active <= '0';
                    FETCH_ENA <= '0';
                    DECODE_ENA <= '0';
                    ALU_ENA <= '0';
                end if;
                -- atau enable doang
                if(enable = '1' AND reset = '0') then
                    active <= '1';
                    State <= FETCH;
                end if;

            -- Di-handle oleh Fetcher
            when FETCH =>
                if(active = '1') then
                    ALU_ENA <= '0';
                    FETCH_ENA <= '1';
                end if;
                State <= DECODE;

            -- Di-handle oleh Decoder
            when DECODE =>
                if(active = '1') then
                    FETCH_ENA <= '0';
                    DECODE_ENA <= '1';
                end if;
                State <= EXECUTE;

            -- Di-handle oleh ALU
            when EXECUTE =>
                if(active = '1') then
                    DECODE_ENA <= '0';
                    ALU_ENA <= '1';
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