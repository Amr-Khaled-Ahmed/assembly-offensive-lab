; read_stdin.asm - read user input from stdin (Linux syscalls)
section .bss
    buffer resb 64        ; reserve 64 bytes

section .text
    global _start

_start:
    ; sys_read (fd=0 stdin)
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 64
    syscall

    ; sys_exit
    mov rax, 60
    xor rdi, rdi
    syscall

