
section .data
filename db "test.txt",0            ; file to open
filebuf resb 128                    ; buffer for reading file
msg db "Allocated memory says hi!",0xA
msg_len equ $ - msg                 ; length of message

section .bss
memres resb 4096                    ; 4KB memory allocation for demo

section .text
global _start

_start:
    ; ---------------------------------
    ; 1. Allocate memory using mmap
    ; ---------------------------------
    mov rax, 9          ; syscall number: mmap
    xor rdi, rdi        ; addr = NULL, let OS choose
    mov rsi, 4096       ; length = 4KB
    mov rdx, 3          ; PROT_READ | PROT_WRITE
    mov r10, 0x22       ; MAP_PRIVATE | MAP_ANONYMOUS
    xor r8, r8          ; fd = 0 (ignored for anonymous)
    xor r9, r9          ; offset = 0
    syscall
    mov r12, rax        ; save pointer to mapped memory

    ; Copy message into mmap'ed memory
    lea rsi, [msg]      ; source pointer
    mov rdi, r12        ; destination pointer
    mov rcx, msg_len    ; number of bytes to copy
copy_msg:
    cmp rcx, 0
    je copy_done
    mov al, [rsi]       ; load byte from source
    mov [rdi], al       ; store byte to destination
    inc rsi
    inc rdi
    dec rcx
    jmp copy_msg
copy_done:

    ; ---------------------------------
    ; 2. Adjust program break using brk
    ; ---------------------------------
    mov rax, 12         ; syscall number: brk
    xor rdi, rdi        ; query current break
    syscall
    mov r13, rax        ; save current break address
    add rax, 4096       ; expand heap by 4KB
    mov rdi, rax
    mov rax, 12         ; syscall: brk
    syscall

    ; ---------------------------------
    ; 3. Open file
    ; ---------------------------------
    mov rax, 2          ; syscall: open
    lea rdi, [filename] ; pointer to file name
    xor rsi, rsi        ; O_RDONLY
    syscall
    mov r14, rax        ; save file descriptor

    ; ---------------------------------
    ; 4. Read file
    ; ---------------------------------
    mov rax, 0          ; syscall: read
    mov rdi, r14        ; file descriptor
    lea rsi, [filebuf]  ; buffer
    mov rdx, 128        ; max bytes to read
    syscall

    ; ---------------------------------
    ; 5. Write file content to stdout
    ; ---------------------------------
    mov rax, 1          ; syscall: write
    mov rdi, 1          ; stdout
    lea rsi, [filebuf]  ; buffer
    mov rdx, 128        ; number of bytes
    syscall

    ; ---------------------------------
    ; 6. Exit program
    ; ---------------------------------
    mov rax, 60         ; syscall: exit
    xor rdi, rdi        ; exit code 0
    syscall
