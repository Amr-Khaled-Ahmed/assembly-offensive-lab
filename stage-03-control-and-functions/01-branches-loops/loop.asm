section .bss
    msg db "loop finished", oxA; message with newline
    len equ $ - msg; length of the message

section .bss
    counter resb 1; reserve a byte for counter


section .text
    global _start


_start:
    ; Initialize counter
    mov byte [counter], 0

loop_start:
    ; Load counter
    mov al, [counter]
    cmp al, 5           ; Compare counter with 5
    jge loop_end        ; Jump to end if counter >= 5

    ; Increment counter
    inc byte [counter]

    ; Branch example
    mov al, [counter]
    cmp al, 3
    je special_message   ; Jump if counter == 3

    jmp loop_start       ; Otherwise, continue loop

special_message:
    ; Print a special message for 3 (optional)
    ; For simplicity, we skip printing
    jmp loop_start

loop_end:
    ; Print "Loop finished!" using syscall
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, msg
    mov rdx, msg_len
    syscall

    ; Exit program
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall
