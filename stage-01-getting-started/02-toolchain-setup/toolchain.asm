; toolchain.asm - Toolchain setup helper (NASM, Linux x86_64)
section .data
msg db "Toolchain Setup Helper",0x0A
    db "---------------------",0x0A
    db "Linux (WSL/Native) - install & check:",0x0A
    db "  sudo apt update && sudo apt install nasm build-essential -y",0x0A
    db "  nasm -v",0x0A
    db "  ld --version",0x0A
    db 0x0A
    db "Example build (Linux):",0x0A
    db "  nasm -f elf64 regs.asm -o regs.o",0x0A
    db "  ld regs.o -o regs",0x0A
    db "  ./regs",0x0A
    db 0x0A
    db "Windows (MinGW) - quick notes:",0x0A
    db "  - Download NASM: https://www.nasm.us",0x0A
    db "  - Install MinGW-w64 and add its bin/ to PATH",0x0A
    db "  - Example (COFF/Win64):",0x0A
    db "      nasm -f win64 hello.asm -o hello.obj",0x0A
    db "      gcc hello.obj -o hello.exe",0x0A
    db 0x0A
    db "Notes:",0x0A
    db "  - Linux syscalls require Linux ABI (use WSL/VM).",0x0A
    db "  - For native Windows binaries, write WinAPI code (WriteConsole/MessageBox).",0x0A
    db 0x0A
len equ $-msg

section .text
global _start

_start:
    mov rax, 1          ; sys_write
    mov rdi, 1
    mov rsi, msg
    mov rdx, len
    syscall

    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall

