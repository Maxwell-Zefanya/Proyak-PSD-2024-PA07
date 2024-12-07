# Programmable Basic CPU dalam VHDL
## Dibuat Oleh
### KELOMPOK PA-07
- Maxwell Zefanya Ginting / 2306221200
- Muhamad Dzaky Maulana / 2306264401
- Reichan Adhiguno / 2106703273
- Rivi Yasha Hafizhan / 2306250535
## Latar Belakang & Tujuan
Selama masa praktikum PSD, telah diajarkan mengenai banyak intrikasi dalam pendesainan dan pembuatan rangkaian melalui VHDL. Proyek akhir ini bertujuan untuk mengimplementasikan berbagai aspek dari bahasa VHDL secara bersamaan kedalam sebuah rangkaian.  

## Penjelasan Proyek
Rangkaian yang dibuat adalah sebuah CPU programmable sederhana. CPU sendiri hanya memiliki tombol enable dan reset. Seperti CPU umumnya, segala operasi akan disinkronisasi melalui clock. Di-dalamnya, terdapat 4 komponen yang hanya bisa diakses melalui opcode saja. Komponen tersebut adalah 3 buah register dengan ukuran 16-bit, dan flag equals.  

Cara penggunaan CPU sendiri adalah dengan interface file yang berisikan machine code yang ditulis dalam bentuk integer. CPU akan menjalankan kode yang berada di-dalam file secara sekuensial, dan bila perlu akan mengeluarkan output dalam bentuk signed integer kedalam file yang berebda.  

## Implementasi
### Cara kerja CPU
CPU akan diimplementasikan dengan pertama membagikannya menjadi 4 bagian berbeda, yaitu main CPU, Fetcher, Decoder, dan ALU. Main CPU akan mengendalikan proses pengerjaan kode, dimana proses tersebut akan dibagikan menjadi 5 bagian, IDLE, FETCH, DECODE, EXECUTE, dan STORE. CPU akan berada didalam state bila proses belum mulai atau sudah selesai. Bila kode sedang dieksekusi, maka CPU akan berada diantara 4 state lainnya.  

Bagian Fetcher akan mengambil instruksi raw dari file instructions yang ada, dan mengatur jalan eksekusi CPU berdasarkan apakah filenya sudah berakhir atau belum. Bagian Decoder akan mengambil instruksi raw yang di-fetch sebelumnya, dan memisahkannya menjadi opcode dan operand yang akan di-pass kedalam ALU.  

Terakhir, ALU akan bekerja menggunakan opcode dan operand tersebut pada 2 state, yaitu EXECUTE dan STORE. Pada state EXECUTE, ALU akan mengambil opcode dan operand, berbagai register dan flag pada CPU, serta clock dan enable dari CPU untuk menentukan operasi apa yang akan dijalankan. Pada state STORE, ALU akan mengembalikan hasil dari operasi kembali kedalam CPU-nya sendiri, baik itu berbagai value register ataupun value dari flag.  

### Metode Implementasi CPU dalam VHDL
Pengimplementasian dari CPU kedalam rangkaian yang fungsional menggunakan beberapa aspek dari bahasa VHDL sendiri. Selain konsep dasar pada VHDL (seperti behavioural), rangkaian juga menggunakan beberapa fitur VHDL lainnya. Pertama, supaya penulisan kode lebih jelas, digunakan konsep port-mapping, dimana keempat bagian dari CPU dipisahkan menjadi beberapa bagian, dengan CPU sendiri menjadi entity top-level nya, dengan Decoder, Fetcher, dan ALU menjadi entity lower-level. Selain itu, interfacing antara kode dengan rangkaian dilakukan menggunakan library `STD.TEXTIO`, dimana instruksi dibaca pada file `Instructions.txt` dan output dituliskan pada file `Outputs.txt`.

### Tabel Instruksi CPU
Tabel instruksi CPU dengan opcode dalam biner  
Register A = Register destinasi (XX)  
Register B = Register asal (YY)  
Immediate  = Value immediate (YYYYYY)  

**NOTE: Instruksi.txt dan Outputs.txt dituliskan sebagai signed integer**  
| INSTRUKSI | OPCODE | PENJELASAN                                                                                                           | FORMAT       |
|-----------|--------|----------------------------------------------------------------------------------------------------------------------|--------------|
| CMP-I     | 0000   | Bandingkan apabila isi register dengan immediate (zero-fill) sama, hanya mengefek flag "equals"                      | 0000XXYYYYYY |
| CMP-R     | 0001   | Bandingkan apabila isi dua register sama, hanya mengefek flag "equals"                                               | 0001XXYY0000 |
| ADD-I     | 0010   | Register A = Register A + Immediate                                                                                  | 0010XXYYYYYY |
| ADD-R     | 0011   | Register A = Register A + Register B                                                                                 | 0011XXYY0000 |
| SUB-I     | 0100   | Register A = Register A - Immediate                                                                                  | 0100XXYYYYYY |
| SUB-R     | 0101   | Register A = Register A - Register B                                                                                 | 0101XXYY0000 |
| SAL       | 0110   | Logical bit-shift (bukan arithmetic). Register A << Immediate (Unsigned)                                             | 0110XXYYYYYY |
| SAR       | 0111   | Logical bit-shift (bukan arithmetic). Register A >> Immediate (Unsigned)                                             | 0111XXYYYYYY |
| ISEQ      | 1000   | Akan mengeksekusi instruksi berikutnya apabila flag "equals" = 1. Bila tidak, akan melompati eksekusi satu instruksi | 100000000000 |
| NOEQ      | 1001   | Akan mengeksekusi instruksi berikutnya apabila flag "equals" = 0. Bila tidak, akan melompati eksekusi satu instruksi | 100100000000 |
| LOD-I     | 1010   | Register A = Immediate                                                                                               | 1010XXYYYYYY |
| STO-R     | 1011   | Menulis isi register kedalam file "Outputs.txt" dalam format integer (signed)                                        | 1011XX000000 |
| AND       | 1100   | Register A = Register A && Register B                                                                                | 1100XXYY0000 |
| OR        | 1101   | Register A = Register A \|\| Register B                                                                              | 1101XXYY0000 |
| NOT       | 1110   | Register A = !(Register A)                                                                                           | 1110XX000000 |
| CLF       | 1111   | Clear flag yang ada. Equals = 0                                                                                      | 111100000000 |


## Hasil Implementasi
Hasil simulasi:  
Hasil sintesis:  
## Kesimpulan (?)
Test
