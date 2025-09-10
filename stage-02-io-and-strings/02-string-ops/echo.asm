; echo.asm - simple echo program
section .bss
    buffer resb 128

section .text
    global _start

_start:
    ; sys_read (stdin → buffer)
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 128
    syscall
    mov rbx, rax          ; save number of bytes read

    ; sys_write (stdout ← buffer)
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, rbx
    syscall

    ; sys_exit
    mov rax, 60
    xor rdi, rdi
    syscall

