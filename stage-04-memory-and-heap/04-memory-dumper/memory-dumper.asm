
section .data
    static_data db 10, 20, 30, 40   ; initialized static data
    static_len equ $ - static_data   ; length of static data
    msg_dump db "Memory dump: ", 0  ; header message
    msg_dump_len equ $ - msg_dump
    newline db 0xA                   ; newline character

section .bss
    bss_data resb 4                  ; uninitialized memory (BSS section)

section .text
    global _start

_start:
    ; ----------------------------
    ; Initialize BSS values manually
    ; ----------------------------
    mov byte [bss_data], 1
    mov byte [bss_data+1], 2
    mov byte [bss_data+2], 3
    mov byte [bss_data+3], 4

    ; ----------------------------
    ; Print header message
    ; ----------------------------
    mov rax, 1              ; sys_write syscall
    mov rdi, 1              ; file descriptor (stdout)
    mov rsi, msg_dump       ; address of message
    mov rdx, msg_dump_len   ; message length
    syscall

    ; ----------------------------
    ; Dump static_data bytes
    ; ----------------------------
    lea rsi, [static_data]  ; load address of static_data into rsi
    mov rcx, static_len     ; number of bytes to dump
    call dump_bytes

    ; ----------------------------
    ; Dump BSS memory bytes
    ; ----------------------------
    lea rsi, [bss_data]     ; load address of BSS memory
    mov rcx, 4              ; number of bytes to dump
    call dump_bytes

    ; ----------------------------
    ; Print newline after dumping
    ; ----------------------------
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; ----------------------------
    ; Exit program
    ; ----------------------------
    mov rax, 60             ; sys_exit syscall
    xor rdi, rdi            ; exit code 0
    syscall

; ----------------------------
; Function: dump_bytes
; Dumps memory byte by byte as ASCII numbers
; Inputs:
;   rsi = start address of memory to dump
;   rcx = number of bytes to dump
; ----------------------------
dump_bytes:
    push rbp
    mov rbp, rsp

dump_loop:
    cmp rcx, 0              ; check if finished
    je dump_done            ; if zero, exit loop

    mov al, [rsi]           ; load current byte into al
    add al, '0'             ; convert small number 0-9 to ASCII
    mov [rsp-1], al         ; temporarily store on stack

    mov rax, 1              ; sys_write syscall
    mov rdi, 1              ; stdout
    lea rsi, [rsp-1]        ; address of temporary byte
    mov rdx, 1              ; write 1 byte
    syscall

    inc rsi                  ; move to next byte
    dec rcx                  ; decrement counter
    jmp dump_loop

dump_done:
    pop rbp
    ret
