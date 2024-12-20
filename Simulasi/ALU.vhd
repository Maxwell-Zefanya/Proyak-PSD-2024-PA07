LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.textio.ALL;

ENTITY ALU IS
    PORT (
        clk : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        store : IN STD_LOGIC;
        OPCODE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        OPERAND : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        PROG_CTR : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        REGISTER_A : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => 'Z');
        REGISTER_B : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => 'Z');
        REGISTER_C : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => 'Z');
        equals : INOUT STD_LOGIC
    );
END ENTITY ALU;

ARCHITECTURE rtl OF ALU IS
    SIGNAL REG_DEST : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL REG_FROM : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL REG_IMM : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL EQ_FLAG : STD_LOGIC;
    SIGNAL skip : STD_LOGIC := '0';
BEGIN
    PROCESS (clk) IS
        FILE output : text OPEN write_mode IS "Outputs.txt";
        VARIABLE output_line : line;
        VARIABLE output_integer : INTEGER;
        VARIABLE reg_dest_1 : STD_LOGIC_VECTOR(1 DOWNTO 0);
        VARIABLE reg_from_1 : STD_LOGIC_VECTOR(1 DOWNTO 0);
        VARIABLE reg_temp : STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN
        IF falling_edge(clk) AND ena = '1' THEN
            -- Ensure REG_IMM is assigned correctly
            REG_IMM <= "0000000000" & OPERAND(5 DOWNTO 0);
            -- Assign REG_DEST based on conditions
            IF store = '0' THEN
                CASE OPERAND(7 DOWNTO 6) IS
                    WHEN "00" => REG_DEST <= REGISTER_A;
                    WHEN "01" => REG_DEST <= REGISTER_B;
                    WHEN "10" => REG_DEST <= REGISTER_C;
                    WHEN OTHERS => NULL;
                END CASE;
                -- Assign REG_FROM based on conditions
                CASE OPERAND(5 DOWNTO 4) IS
                    WHEN "00" => REG_FROM <= REGISTER_A;
                    WHEN "01" => REG_FROM <= REGISTER_B;
                    WHEN "10" => REG_FROM <= REGISTER_C;
                    WHEN OTHERS => NULL;
                END CASE;
            END IF;
        END IF;

        IF rising_edge(clk) AND ena = '1' THEN
            IF store = '1' THEN
                REPORT "REG_DEST: " & INTEGER'image(to_integer(signed(REG_DEST)));
                -- Handle store cycle
                CASE OPERAND(7 DOWNTO 6) IS
                    WHEN "00" => REGISTER_A <= REG_DEST;
                    WHEN "01" => REGISTER_B <= REG_DEST;
                    WHEN "10" => REGISTER_C <= REG_DEST;
                    WHEN OTHERS => NULL;
                END CASE;
                equals <= EQ_FLAG;
            ELSE
                REPORT "REG_IMM: " & INTEGER'image(to_integer(signed(REG_IMM)));
                -- Relevan dengan opcode NOEQ & ISEQ
                IF skip = '0' THEN
                    -- Register yang dipakai dalam operasi
                    -- Bisa dipakai bisa juga nggak
                    reg_dest_1 := operand(7 DOWNTO 6); -- Register tujuan
                    reg_from_1 := operand(5 DOWNTO 4); -- Register asal
                    reg_temp := (OTHERS => '0'); -- Temporary register, untuk perhitungan

                    CASE OPCODE IS
                            -- CMP-I
                            -- Bandingkan apabila isi register dengan immediate (zero-fill) sama, hanya mengefek flag "equals"
                        WHEN "0000" =>
                            IF REG_DEST = REG_IMM THEN
                                EQ_FLAG <= '1';
                                IF store = '1' THEN
                                    EQ_FLAG <= '1';
                                ELSE
                                    EQ_FLAG <= 'Z';
                                END IF;
                            ELSE
                                EQ_FLAG <= '0';
                                IF store = '1' THEN
                                    EQ_FLAG <= '0';
                                ELSE
                                    EQ_FLAG <= 'Z';
                                END IF;
                            END IF;
                            REPORT "CMP-I";

                            -- CMP-R
                            -- Bandingkan apabila isi dua register sama, hanya mengefek flag "equals"
                        WHEN "0001" =>
                            IF ((reg_dest_1 = reg_from_1) AND (NOT (reg_dest_1 = "11")) AND (NOT (reg_from_1 = "11"))) THEN
                                EQ_FLAG <= '1';
                            ELSE
                                EQ_FLAG <= '0';
                            END IF;
                            IF REG_DEST = REG_FROM THEN
                                EQ_FLAG <= '1';
                            ELSE
                                EQ_FLAG <= '0';
                            END IF;
                            REPORT "CMP-R";

                            -- ADD-I
                            -- Register A = Register A + Immediate
                        WHEN "0010" =>
                            reg_temp := STD_LOGIC_VECTOR(to_signed((to_integer(signed(REG_IMM)) + to_integer(signed(REG_DEST))), 16));
                            REG_DEST <= reg_temp;
                            REPORT "ADD-I REG_DEST: " & INTEGER'image(to_integer(signed(REG_DEST)));

                            -- ADD-R
                            -- Register A = Register A + Register B
                        WHEN "0011" =>
                            reg_temp := STD_LOGIC_VECTOR(to_signed((to_integer(signed(REG_DEST)) + to_integer(signed(REG_FROM))), 16));
                            REG_DEST <= reg_temp;
                            REPORT "ADD-R REG_DEST: " & INTEGER'image(to_integer(signed(REG_DEST)));

                            -- SUB-I
                            -- Register A = Register A - Immediate
                        WHEN "0100" =>
                            reg_temp := STD_LOGIC_VECTOR(to_signed((to_integer(signed(REG_DEST)) - to_integer(signed(REG_IMM))), 16));
                            REG_DEST <= reg_temp;
                            REPORT "SUB-R REG_DEST: " & INTEGER'image(to_integer(signed(REG_DEST)));

                            -- SUB-R
                            -- Register A = Register A - Register B
                        WHEN "0101" =>
                            reg_temp := STD_LOGIC_VECTOR(to_signed((to_integer(signed(REG_DEST)) + to_integer(signed(REG_FROM))), 16));
                            REG_DEST <= reg_temp;
                            REPORT "SUB-I REG_DEST: " & INTEGER'image(to_integer(signed(REG_DEST)));

                            -- SAL
                            -- Logical bit-shift (bukan arithmetic)
                            -- Register A << Immediate (Unsigned)
                        WHEN "0110" =>
                            reg_temp := REG_DEST;
                            REG_DEST <= STD_LOGIC_VECTOR(shift_left(unsigned(reg_temp), to_integer(unsigned(REG_IMM))));

                            -- SAR
                            -- Logical bit-shift (bukan arithmetic)
                            -- Register A >> Immediate (Unsigned)
                        WHEN "0111" =>
                            reg_temp := REG_DEST;
                            REG_DEST <= STD_LOGIC_VECTOR(shift_right(unsigned(reg_temp), to_integer(unsigned(REG_IMM))));

                            -- ISEQ
                            -- Akan mengeksekusi instruksi berikutnya apabila flag "equals" = 1
                            -- Bila tidak, akan melompati eksekusi satu instruksi
                        WHEN "1000" =>
                            IF equals = '1' THEN
                                skip <= '0';
                            ELSE
                                skip <= '1';
                            END IF;

                            -- NOEQ
                            -- Akan mengeksekusi instruksi berikutnya apabila flag "equals" = 0
                            -- Bila tidak, akan melompati eksekusi satu instruksi
                        WHEN "1001" =>
                            IF equals = '0' THEN
                                skip <= '0';
                            ELSE
                                skip <= '1';
                            END IF;

                            -- LOD-I
                            -- Register A = Immediate
                        WHEN "1010" =>
                            REG_DEST <= REG_IMM;
                            report "REG_DEST <= REG_IMM: "&std_logic'image(REG_IMM(7))&std_logic'image(REG_IMM(6))&std_logic'image(REG_IMM(5))&std_logic'image(REG_IMM(4))&std_logic'image(REG_IMM(3))&std_logic'image(REG_IMM(2))&std_logic'image(REG_IMM(1))&std_logic'image(REG_IMM(0));

                            -- STO-R
                            -- Menulis isi register kedalam file "Outputs.txt" dalam format integer (signed)
                        WHEN "1011" =>
                            output_integer := to_integer(signed(REG_DEST));
                            write(output_line, output_integer);
                            writeline(output, output_line);
                            REPORT "STO-R REG_DEST: " & INTEGER'image(to_integer(signed(REG_DEST)));

                            -- AND
                            -- Operasi AND bitwise
                            -- Register A = Register A && Register B
                        WHEN "1100" =>
                            reg_temp := REG_DEST AND REG_FROM;
                            REG_DEST <= reg_temp;

                            -- OR
                            -- Operasi OR bitwise
                            -- Register A = Register A || Register B
                        WHEN "1101" =>
                            reg_temp := REG_DEST OR REG_FROM;
                            REG_DEST <= reg_temp;

                            -- NOT
                            -- Operasi NOT bitwise
                            -- Register A = !(Register A)
                        WHEN "1110" =>
                            reg_temp := NOT REG_DEST;

                            -- CLF
                            -- Equals = 0
                        WHEN "1111" =>
                            EQ_FLAG <= '0';
                        WHEN OTHERS =>
                    END CASE;
                    -- Relevan dengan command NOEQ atau ISEQ
                ELSE
                    skip <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;
