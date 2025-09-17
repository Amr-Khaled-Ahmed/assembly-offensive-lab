section .data
msg_sum db "Sum result: ", 0
msg_sum_len equ $ - msg_sum
msg_arg1 db "Arg1: ", 0
msg_arg1_len equ $ - msg_arg1
msg_arg2 db "Arg2: ", 0
msg_arg2_len equ $ - msg_arg2
newline db 0xA

section .text
global _start

_start:
    mov rdi, 7        ; arg1
    mov rsi, 5        ; arg2

    ; Print arg1
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_arg1
    mov rdx, msg_arg1_len
    syscall
    call print_number  ; prints rdi

    ; Print arg2
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_arg2
    mov rdx, msg_arg2_len
    syscall
    call print_number  ; prints rsi

    ; Add numbers
    call add_numbers  ; result in rax

    ; Print sum result
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_sum
    mov rdx, msg_sum_len
    syscall
    call print_number  ; prints rax

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

; -------------------------
; Function: add_numbers
; Adds two numbers in rdi, rsi
; Returns result in rax
; -------------------------
add_numbers:
    push rbp
    mov rbp, rsp
    mov rax, rdi
    add rax, rsi
    pop rbp
    ret

; -------------------------
; Function: print_number
; Prints number in rax as single ASCII digit (0-9)
; -------------------------
print_number:
    push rbp
    mov rbp, rsp

    ; convert to ASCII
    mov rbx, rax
    add bl, '0'
    mov [rsp-1], bl

    ; write syscall
    mov rax, 1
    mov rdi, 1
    lea rsi, [rsp-1]
    mov rdx, 1
    syscall

    pop rbp
    ret
