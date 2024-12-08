library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

-- Decode akan mempreparasikan fields-fields yang diperlukan
entity Decoder is
    port (
        clk : in std_logic;
        ena : in std_logic;
        INSTR_BUFF : in std_logic_vector(11 downto 0);
        OPERAND : out std_logic_vector(7 downto 0);
        OPCODE : out std_logic_vector(3 downto 0)
    );
end entity Decoder;

architecture rtl of Decoder is
begin
    process(clk) is
    begin
        -- Decoder diaktifkan saat pada cycle decode
        if falling_edge(clk) AND ena = '1' then
            OPCODE <= INSTR_BUFF(11 downto 8);
            OPERAND <= INSTR_BUFF(7 downto 0);
        end if;
    end process;
end architecture rtl;