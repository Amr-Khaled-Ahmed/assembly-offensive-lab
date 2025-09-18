
section .data
msg db "Syscalls demo!", 0xA, 0
msg_len equ $ - msg
filename db "test.txt", 0
buffer resb 64
newline db 0xA

section .text
global _start

_start:
    ; 1. write(stdout, msg)
    mov rax, 1      ; sys_write
    mov rdi, 1      ; stdout
    mov rsi, msg
    mov rdx, msg_len
    syscall

    ; 2. read(stdin, buffer)
    mov rax, 0      ; sys_read
    mov rdi, 0      ; stdin
    mov rsi, buffer
    mov rdx, 1      ; read 1 byte
    syscall

    ; 3. open(filename, O_RDONLY)
    mov rax, 2      ; sys_open
    lea rdi, [filename]
    xor rsi, rsi    ; O_RDONLY
    syscall
    mov rbx, rax    ; store fd

    ; 4. read from file
    mov rax, 0      ; sys_read
    mov rdi, rbx
    mov rsi, buffer
    mov rdx, 10
    syscall

    ; 5. close file
    mov rax, 3      ; sys_close
    mov rdi, rbx
    syscall

    ; 6. getpid
    mov rax, 39
    syscall

    ; 7. brk (adjust heap)
    mov rax, 12
    xor rdi, rdi
    syscall

    ; 8. mmap (allocate memory)
    mov rax, 9
    xor rdi, rdi         ; addr = 0
    mov rsi, 4096        ; length
    mov rdx, 3           ; PROT_READ|PROT_WRITE
    mov r10, 0x22        ; MAP_ANONYMOUS|MAP_PRIVATE
    xor r8, r8           ; fd = 0
    xor r9, r9           ; offset
    syscall
    mov rbx, rax         ; store mmap addr

    ; 9. munmap
    mov rax, 11
    mov rdi, rbx
    mov rsi, 4096
    syscall

    ; 10. dup (duplicate stdout)
    mov rax, 32
    mov rdi, 1
    syscall

    ; 11. lseek
    mov rax, 8
    mov rdi, 0       ; fd stdin (just demonstration)
    xor rsi, rsi
    xor rdx, rdx
    syscall

    ; 12. stat (dummy)
    mov rax, 4
    lea rdi, [filename]
    lea rsi, [buffer]
    syscall

    ; 13. fork (demo, returns 0 to child, pid to parent)
    mov rax, 57
    syscall

    ; 14. execve (demo, will not actually run)
    xor rax, rax
    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx
    ; syscall would go here: mov rax, 59; syscall

    ; 15. socket (AF_INET, SOCK_STREAM, 0)
    mov rax, 41
    xor rdi, rdi
    mov rsi, 1
    xor rdx, rdx
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
