library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

-- Mengambil input dari file "Instructions.txt" dan menyetel register sesuai dengan yang ada
entity Fetcher is
    port (
        clk : in std_logic;
        ena : in std_logic;
        active : out std_logic;
        INSTR_BUFF : out std_logic_vector(11 downto 0)
    );
end entity Fetcher;

architecture rtl of Fetcher is
begin
    process(clk) is
        file instruction : text open read_mode is "Instructions.txt";
        variable instr : line;
        variable opcode : integer;
    begin
        -- Fetcher diaktifkan saat pada cycle Fetch
        if falling_edge(clk) AND ena = '1' then
            if not endfile(instruction) then
                readline(instruction, instr);
                read(instr, opcode);
                INSTR_BUFF <= std_logic_vector(to_unsigned(opcode, 12));
                active <= '1';
            else
                active <= '0';
            end if;
        end if;
    end process;
end architecture rtl;