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
    signal PROG_CTR : std_logic_vector(5 downto 0) := (others => '0');

    -- Flags
    signal equals : std_logic := '0';   -- Hasil dari CMP sama
    signal active : std_logic := '0';   -- CPU sedang active (non-idle)
begin
    process(clk) is
    begin
        case State is
        when IDLE =>
            if(reset = '1') then
                REGISTER_A <= (others => '0');
                REGISTER_B <= (others => '0');
                REGISTER_C <= (others => '0');
            end if;
            if(enable = '1') then
            end if;
        when FETCH =>
        when DECODE =>
        when EXECUTE =>
        when others =>
        end case;
    end process;
end architecture rtl;