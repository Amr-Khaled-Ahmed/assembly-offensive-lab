section .data
    msg_alloc db "Allocated value: ", 0
    msg_alloc_len equ $ - msg_alloc
    newline db 0xA

; Define a simple static heap (64 bytes)
heap_space times 64 db 0
heap_next dq 0        ; pointer to next free byte

section .text
    global _start


_start:
    ; Initialize heap_next to point to start of heap_space
    lea rbx, [heap_space]
    mov [heap_next], rbx

    ; ------------------------
    ; Allocate 1 byte
    ; ------------------------
    mov rdi, 1          ; size = 1 byte
    call my_alloc       ; returns pointer in rax

    ; Store value 42 at allocated address
    mov byte [rax], 42

    ; Print message
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_alloc
    mov rdx, msg_alloc_len
    syscall

    ; Print allocated value
    mov al, [rax]
    add al, '0'         ; convert to ASCII
    mov [rsp-1], al
    mov rax, 1
    mov rdi, 1
    lea rsi, [rsp-1]
    mov rdx, 1
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

; ------------------------
; Function: my_alloc
; Simple bump allocator
; Input: rdi = size (bytes)
; Output: rax = pointer to allocated memory
; ------------------------
my_alloc:
    push rbp
    mov rbp, rsp

    mov rax, [heap_next]   ; get current heap pointer
    add [heap_next], rdi   ; increment next free pointer by size

    pop rbp
    ret
✅ What this demonstrates:

