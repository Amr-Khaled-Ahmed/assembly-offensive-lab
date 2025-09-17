section .data
    msg_stack db "Stack value: ", 0
    msg_stack_len equ $ - msg_stack
    msg_heap db "Heap value: ", 0
    msg_heap_len equ $ - msg_heap
    newline db 0xA



section .bss
    heap_ptr resq 1           ; pointer to heap memory

section .text
    global _start


_start:
    ; ----------------------
    ; STACK variable
    ; ----------------------
    sub rsp, 8               ; allocate 8 bytes on stack
    mov qword [rsp], 42      ; store value stack variable

    ; Print stack value
    mov rax, 1               ; sys_write
    mov rdi, 1               ; file descriptor 1 is stdout
    mov rsi, msg_stack       ; pointer to message
    mov rdx, msg_stack_len   ; message length
    syscall



    mov rax, [rsp]            ; load stack variable
    call print_number64


    add rsp, 8                ; deallocate stack space


    ; ----------------------
    ; HEAP variable
    ; ----------------------

    ; allocate 8 bytes using brk syscall
    mov rax, 12              ; sys_brk
    xor rdi, rdi             ; NULL to get current brk
    syscall


    mov rbx, rax            ; save current brk in rbx
    add rbx, 8            ; request 8 more bytes
    mov rax, 12           ; sys_brk
    mov rdi, rbx          ; new brk value
    syscall

    mov [heap_ptr], rax   ; store heap pointer
    mov qword [rax], 99   ; store value in heap

    ; Print heap value
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_heap
    mov rdx, msg_heap_len
    syscall

    mov rax, [heap_ptr]   ; load heap pointer
    mov rax, [rax]        ; load heap variable
    call print_number64


    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall


    ; ----------------------
    ; Exit program
    ; ----------------------
    mov rax, 60            ; sys_exit
    xor rdi, rdi
    syscall


; -------------------------
; Function: print_number64
; Prints a 64-bit number in rax as decimal (simple, 0-255)
; -------------------------
print_number64:
    push rbp
    mov rbp, rsp

    ; For simplicity, print only least significant byte as ASCII
    mov bl, al
    add bl, '0'
    mov [rsp-1], bl
    mov rax, 1
    mov rdi, 1
    lea rsi, [rsp-1]
    mov rdx, 1
    syscall

    pop rbp
    ret
