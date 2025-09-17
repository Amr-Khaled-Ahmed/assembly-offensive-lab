

section .data
    static_msg db "static data", 0
    static_val db 42 ;initialized static variable
    static_len equ $ - static_msg


section .bss
    bss_val resb 1 ;uninitialized static variable

section .text
    global _start

_start:
    ; ----------------------
    ; Access and modify static data
    ; ----------------------
    mov al, [static_val] ;load static_val into AL
    add al, 1            ;increment AL
    mov [static_val], al ;store AL back to static_val

    ; ----------------------
    ; initialize BSS data
    ; ----------------------
    mov byte [bss_val], 7 ;initialize bss_val to 7
    ; ----------------------
    ; print static message
    ; ----------------------
    mov rax, 1          ;sys_write
    mov rdi, 1          ;file descriptor 1 is stdout
    mov rsi, static_msg ;pointer to message
    mov rdx, static_len ;message length
    syscall

    mov al, [static_val] ;load static_val into AL
    add al, '0';
    mov [rsp - 1], al
    mov rax, 1          ;sys_write
    mov rdi, 1          ;file descriptor 1 is stdout
    lea rsi, [rsp - 1]  ;pointer to message
    mov rdx, 1          ;message length
    syscall

    ; ----------------------
    ; Print BSS value
    ; ----------------------
    mov al, [bss_val]
    add al, '0'           ; convert to ASCII
    mov [rsp-1], al
    mov rax, 1
    mov rdi, 1
    lea rsi, [rsp-1]
    mov rdx, 1
    syscall

    ; ----------------------
    ; Exit program
    ; ----------------------
    mov rax, 60           ; sys_exit
    xor rdi, rdi
    syscall
