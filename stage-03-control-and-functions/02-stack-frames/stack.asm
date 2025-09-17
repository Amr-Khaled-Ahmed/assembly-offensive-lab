
section .data
msg db "Result: ", 0
msg_len equ $ - msg
num resb 1
newline db 0xA

section .text
global _start

_start:
    ; Call function to get two numbers
    call get_inputs          ; returns numbers in rdi and rsi

    ; Call add_numbers with rdi and rsi
    call add_numbers         ; result in rax

    ; Store result in num
    mov [num], al

    ; Call print_result to display
    call print_result

    ; Exit program
    mov rax, 60              ; sys_exit
    xor rdi, rdi
    syscall

; -------------------------
; Function: get_inputs
; Returns two numbers in rdi and rsi
; -------------------------
get_inputs:
    push rbp
    mov rbp, rsp

    ; Hardcoded input example (could be replaced with syscall read)
    mov rdi, 10     ; first number
    mov rsi, 20     ; second number

    mov rsp, rbp
    pop rbp
    ret

; -------------------------
; Function: add_numbers
; Adds two numbers in rdi, rsi
; Returns result in rax
; -------------------------
add_numbers:
    push rbp
    mov rbp, rsp

    mov al, dil
    add al, sil
    movzx rax, al   ; zero-extend result to rax

    pop rbp
    ret

; -------------------------
; Function: print_result
; Prints msg + num + newline
; -------------------------
print_result:
    push rbp
    mov rbp, rsp

    ; print "Result: "
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, msg
    mov rdx, msg_len
    syscall

    ; print number as ASCII
    mov al, [num]
    add al, '0'         ; convert to ASCII
    mov [num], al

    mov rax, 1
    mov rdi, 1
    lea rsi, [num]
    mov rdx, 1
    syscall

    ; print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    pop rbp
    ret
