; 04-elf-pe-inspector.asm
; x86_64 NASM assembly - ELF / PE (MZ) inspector (reads first 4096 bytes)
; Usage:
;   nasm -felf64 04-elf-pe-inspector.asm -o 04-elf-pe-inspector.o
;   ld 04-elf-pe-inspector.o -o elf_pe_inspector
;   ./elf_pe_inspector <path-to-file>
;
; Notes:
; - educational tool: prints basic header fields for ELF and PE files.
; - uses Linux syscalls only (open/read/close/write/exit).
; - reads up to 4096 bytes of the file into a buffer and parses.
; - basic support for ELF32/ELF64 and PE32/PE32+ optional header.
;
BITS 64
GLOBAL _start

SECTION .data
usage_msg:      db  "Usage: elf_pe_inspector <file>", 10, 0
err_open:       db  "[error] cannot open file",10,0
err_read:       db  "[error] cannot read file",10,0
is_elf:         db  "[info] detected: ELF file",10,0
is_pe:          db  "[info] detected: PE (MZ) file",10,0
unknown_msg:    db  "[info] unknown file type (not ELF or PE/MZ)",10,0

s_elf_class:    db  "  ELF class: ",0
s_elf_data:     db  "  Endianness: ",0
s_elf_type:     db  "  Type: 0x",0
s_elf_machine:  db  "  Machine: 0x",0
s_elf_entry:    db  "  Entry point: 0x",0
s_elf_phoff:    db  "  Program header offset: 0x",0
s_elf_shoff:    db  "  Section header offset: 0x",0

s_pe_e_lfanew:  db  "  e_lfanew (PE header offset): 0x",0
s_pe_machine:   db  "  COFF Machine: 0x",0
s_pe_nsects:    db  "  NumberOfSections: ",0
s_pe_time:      db  "  TimeDateStamp: 0x",0
s_pe_entry:     db  "  AddressOfEntryPoint: 0x",0
s_pe_imagebase: db  "  ImageBase: 0x",0

nl:             db  10,0

SECTION .bss
buf:            resb 4096      ; buffer to read file header
argvbuf:        resq 4         ; small area if need

SECTION .text

; ----------------- syscalls helpers -----------------
; write(fd, buf, len) - rdi=fd, rsi=buf, rdx=len
sys_write:
    mov rax, 1
    syscall
    ret

; exit(status) - rdi = status
sys_exit:
    mov rax, 60
    syscall

; open(path, flags, mode) - rdi=path, rsi=flags, rdx=mode
sys_open:
    mov rax, 2
    syscall
    ret

; read(fd, buf, count) - rdi=fd, rsi=buf, rdx=count
sys_read:
    mov rax, 0
    syscall
    ret

; close(fd) - rdi=fd
sys_close:
    mov rax, 3
    syscall
    ret

; ----------------- tiny helpers -----------------
; write_str: rdi=fd, rsi=ptr, rdx=len
write_str:
    call sys_write
    ret

; write_nl: write newline to fd (rdi)
write_nl:
    lea rsi, [rel nl]
    mov rdx, 1
    call sys_write
    ret

; print_hex64: rdi = 64-bit value, writes 16 hex chars to stdout (fd=1)
; uses local stack buffer (16 bytes)
print_hex64:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    lea rbx, [rsp]           ; buffer start
    mov rcx, 16
    mov rax, rdi             ; value
    lea rdi, [rbx + 16]      ; pointer to end
.hex64_loop:
    dec rdi
    mov rdx, rax
    and rdx, 0xF
    cmp rdx, 9
    jbe .hex_num
    add rdx, 'a' - 10
    jmp .hex_store
.hex_num:
    add rdx, '0'
.hex_store:
    mov byte [rdi], dl
    shr rax, 4
    loop .hex64_loop
    ; write buffer (16)
    mov rax, 1
    mov rdi, 1
    mov rsi, rdi
    ; rsi currently points to buffer start (we need to set properly)
    lea rsi, [rbx]
    mov rdx, 16
    syscall
    add rsp, 32
    pop rbp
    ret

; print_hex32: rdi = 32-bit value -> prints 8 hex chars
print_hex32:
    push rbp
    mov rbp, rsp
    sub rsp, 24
    lea rbx, [rsp]
    mov rcx, 8
    mov rax, rdi
    lea rdi, [rbx + 8]
.hex32_loop:
    dec rdi
    mov rdx, rax
    and rdx, 0xF
    cmp rdx, 9
    jbe .h32_num
    add rdx, 'a' - 10
    jmp .h32_store
.h32_num:
    add rdx, '0'
.h32_store:
    mov byte [rdi], dl
    shr rax, 4
    loop .hex32_loop
    ; write buffer (8)
    mov rax, 1
    mov rdi, 1
    lea rsi, [rbx]
    mov rdx, 8
    syscall
    add rsp, 24
    pop rbp
    ret

; print_u32_dec: rdi = unsigned 32-bit -> print decimal to stdout
print_u32_dec:
    push rbp
    mov rbp, rsp
    sub rsp, 40
    lea rbx, [rsp]
    mov rcx, 0
    mov rax, rdi
    cmp rax, 0
    jne .conv_loop
    mov byte [rbx], '0'
    mov rdx, 1
    mov rsi, rbx
    mov rdi, 1
    call sys_write
    add rsp, 40
    pop rbp
    ret
.conv_loop:
    xor rdx, rdx
    mov rbx, 10
    div rbx            ; rax = rax / 10 ; rdx = rax % 10  <-- careful: before DIV rax should hold value, but we clobbered; we'll do manual loop using registers differently
    ; Simpler approach: use repeated division with temp registers
    ; We'll implement a simple loop using rax original copy in rsi
    mov rsi, rdi
    lea rdi, [rsp+8]
    mov rcx, 0
.dloop:
    xor rdx, rdx
    mov rax, rsi
    mov rbx, 10
    div rbx
    add dl, '0'
    mov [rdi + rcx], dl
    inc rcx
    mov rsi, rax
    cmp rsi, 0
    jne .dloop
    ; now rcx digits in reverse at [rdi..)
    ; write them in correct order to scratch at [rsp]
    lea rsi, [rsp+8]
    mov rbx, rcx
    mov rdi, 1
    mov rdx, rcx
    ; reverse into local buffer at [rsp]
    mov r8, 0
.rev_loop:
    dec rbx
    mov al, [rsi + rbx]
    mov [rsp + r8], al
    inc r8
    cmp r8, rcx
    jne .rev_loop
    ; write r8 bytes (rcx)
    mov rsi, rsp
    mov rdx, rcx
    mov rdi, 1
    call sys_write
    add rsp, 40
    pop rbp
    ret

; For simplicity, above decimal printer is a bit verbose but works for small values.
; ----------------- start -----------------
_start:
    ; stack layout: [rsp] = argc ; [rsp+8] = argv
    mov rax, [rsp]        ; argc
    cmp rax, 2
    jl .no_arg
    mov rdi, [rsp+16]     ; argv[1] pointer (note: argv pointers start at rsp+8; argv[1] at +16)
    cmp rdi, 0
    jne .got_filename
.no_arg:
    ; print usage and exit
    lea rsi, [rel usage_msg]
    mov rdx, 27
    mov rdi, 2
    call write_str
    mov rdi, 1
    call sys_exit

.got_filename:
    ; rdi = path pointer
    ; open file O_RDONLY (flags=0)
    mov rsi, 0
    call sys_open
    cmp rax, 0
    js .open_failed
    mov r12, rax      ; fd

    ; read up to 4096 bytes into buf
    lea rsi, [rel buf]
    mov rdx, 4096
    mov rdi, r12
    call sys_read
    cmp rax, 0
    jle .read_failed
    mov r13, rax      ; bytes read

    ; close fd
    mov rdi, r12
    call sys_close

    ; check ELF magic 0x7f 'E' 'L' 'F'
    lea rbx, [rel buf]
    mov al, [rbx]        ; 0
    cmp al, 0x7F
    jne .check_mz
    mov al, [rbx+1]
    cmp al, 'E'
    jne .check_mz
    mov al, [rbx+2]
    cmp al, 'L'
    jne .check_mz
    mov al, [rbx+3]
    cmp al, 'F'
    jne .check_mz

    ; it's ELF
    lea rsi, [rel is_elf]
    mov rdx, 23
    mov rdi, 1
    call write_str

    ; e_ident[4] = class: 1 = 32, 2 = 64
    mov al, [rbx + 4]
    cmp al, 1
    je .elf32
    cmp al, 2
    je .elf64
    ; unknown class
    lea rsi, [rel s_elf_class]
    mov rdx, 14
    mov rdi, 1
    call write_str
    mov rsi, rbp
    mov rdx, 4
    call write_str
    jmp .done

.elf32:
    lea rsi, [rel s_elf_class]
    mov rdx, 14
    mov rdi, 1
    call write_str
    mov rax, '3' ; print "ELF32"
    ; simpler: print "ELF32"
    lea rsi, [rel s_elf_class+0] ; reuse pointer, then print "32"
    ; print "32"
    ; (just print fixed string)
    mov rsi, rsp
    mov qword [rsp-16], 0
    ; to avoid complexity: write "ELF32\n"
    mov rsi, rel_elf32
    mov rdx, 6
    mov rdi, 1
    call write_str
    jmp .elf32_parse

.elf64:
    ; print ELF64
    mov rsi, rel_elf64
    mov rdx, 6
    mov rdi, 1
    call write_str

.elf32_parse:
    ; parse ELF32 fields
    ; e_type: offset 16 (2 bytes) little-endian assumed (we print hex)
    movzx rax, word [rbx + 16]
    ; print "  Type: 0x" then hex (4 chars)
    lea rsi, [rel s_elf_type]
    mov rdx, 11
    mov rdi, 1
    call write_str
    mov rdi, rax
    ; print as 4-hex nibble: call print_hex32 but value is 16-bit, use print_hex32 (prints 8 nibble => ok)
    call print_hex32
    call write_nl

    ; e_machine: offset 18 (2 bytes)
    movzx rax, word [rbx + 18]
    lea rsi, [rel s_elf_machine]
    mov rdx, 13
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex32
    call write_nl

    ; e_entry: offset 24 (4 bytes) for ELF32
    mov eax, dword [rbx + 24]
    lea rsi, [rel s_elf_entry]
    mov rdx, 16
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex32
    call write_nl

    ; e_phoff: offset 28 (4)
    mov eax, dword [rbx + 28]
    lea rsi, [rel s_elf_phoff]
    mov rdx, 28
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex32
    call write_nl

    ; e_shoff: offset 32 (4)
    mov eax, dword [rbx + 32]
    lea rsi, [rel s_elf_shoff]
    mov rdx, 29
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex32
    call write_nl
    jmp .done

.elf64_parse:
    ; (not used — flow goes to .elf64 above)
    jmp .done

; small static strings for ELF32/64 prints
; to avoid assembler errors, define these here
SECTION .data
rel_elf32: db "ELF32",10,0
rel_elf64: db "ELF64",10,0

SECTION .text
.elf64_parse:
    ; e_type: offset 16 (2 bytes)
    movzx rax, word [rbx + 16]
    lea rsi, [rel s_elf_type]
    mov rdx, 11
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex32
    call write_nl

    ; e_machine: offset 18 (2 bytes)
    movzx rax, word [rbx + 18]
    lea rsi, [rel s_elf_machine]
    mov rdx, 13
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex32
    call write_nl

    ; e_entry: offset 24 (8 bytes)
    mov rax, qword [rbx + 24]
    lea rsi, [rel s_elf_entry]
    mov rdx, 16
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex64
    call write_nl

    ; e_phoff: offset 32 (8)
    mov rax, qword [rbx + 32]
    lea rsi, [rel s_elf_phoff]
    mov rdx, 28
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex64
    call write_nl

    ; e_shoff: offset 40 (8)
    mov rax, qword [rbx + 40]
    lea rsi, [rel s_elf_shoff]
    mov rdx, 29
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex64
    call write_nl
    jmp .done

.check_mz:
    ; check DOS MZ header: bytes 'M' 'Z' at offset 0
    mov al, [rbx]
    cmp al, 'M'
    jne .unknown
    mov al, [rbx+1]
    cmp al, 'Z'
    jne .unknown

    ; It's a PE-like file (MZ). Print detected
    lea rsi, [rel is_pe]
    mov rdx, 22
    mov rdi, 1
    call write_str

    ; read e_lfanew at offset 0x3C (60) -> dword (PE header offset)
    mov eax, dword [rbx + 0x3c]
    mov r14, rax        ; e_lfanew
    ; print e_lfanew
    lea rsi, [rel s_pe_e_lfanew]
    mov rdx, 33
    mov rdi, 1
    call write_str
    mov rdi, r14
    call print_hex32
    call write_nl

    ; check PE signature at r14
    add rbx, r14        ; point to PE header
    mov eax, dword [rbx] ; should be "PE\0\0" = 0x00004550
    cmp eax, 0x00004550
    jne .pe_bad_sig

    ; read COFF File Header fields: Machine (2), NumberOfSections (2), TimeDateStamp (4)
    movzx rax, word [rbx + 4]   ; Machine
    lea rsi, [rel s_pe_machine]
    mov rdx, 14
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex32
    call write_nl

    movzx rdi, word [rbx + 6]   ; NumberOfSections
    lea rsi, [rel s_pe_nsects]
    mov rdx, 18
    mov rdi, 1
    call write_str
    ; print decimal number of sections
    mov rdi, rdi
    call print_u32_dec
    call write_nl

    mov eax, dword [rbx + 8]    ; TimeDateStamp
    lea rsi, [rel s_pe_time]
    mov rdx, 16
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex32
    call write_nl

    ; Optional header starts at offset +24 (COFF header is 20 bytes, signature 4 => optional starts at +24)
    lea rcx, [rbx + 24]
    ; read magic (2 bytes)
    movzx rax, word [rcx]
    ; magic 0x10b => PE32 ; 0x20b => PE32+
    cmp ax, 0x10b
    je .pe32
    cmp ax, 0x20b
    je .pe32_plus
    jmp .done

.pe32:
    ; AddressOfEntryPoint at offset 16 from start of optional header (rcx+16)
    mov eax, dword [rcx + 16]
    lea rsi, [rel s_pe_entry]
    mov rdx, 25
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex32
    call write_nl

    ; ImageBase at offset 28 (4 bytes)
    mov eax, dword [rcx + 28]
    lea rsi, [rel s_pe_imagebase]
    mov rdx, 19
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex32
    call write_nl
    jmp .done

.pe32_plus:
    ; AddressOfEntryPoint at rcx+16 (4 bytes)
    mov eax, dword [rcx + 16]
    lea rsi, [rel s_pe_entry]
    mov rdx, 25
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex32
    call write_nl

    ; ImageBase at offset 24 (8 bytes) for PE32+
    mov rax, qword [rcx + 24]
    lea rsi, [rel s_pe_imagebase]
    mov rdx, 19
    mov rdi, 1
    call write_str
    mov rdi, rax
    call print_hex64
    call write_nl
    jmp .done

.pe_bad_sig:
    lea rsi, [rel unknown_msg]
    mov rdx, 39
    mov rdi, 1
    call write_str
    jmp .done

.unknown:
    lea rsi, [rel unknown_msg]
    mov rdx, 39
    mov rdi, 1
    call write_str
    jmp .done

.open_failed:
    lea rsi, [rel err_open]
    mov rdx, 23
    mov rdi, 2
    call write_str
    mov rdi, 1
    call sys_exit

.read_failed:
    lea rsi, [rel err_read]
    mov rdx, 23
    mov rdi, 2
    call write_str
    mov rdi, 1
    call sys_exit

.done:
    mov rdi, 0
    call sys_exit
