section .data
    prompt db 'mini-shell> ', 0
    exit_cmd db 'exit', 0
    cmd_not_found db 'Command not found or failed to execute', 10, 0
    slash_bin db '/bin/', 0

section .bss
    input resb 256
    command resb 300
    input_len resq 1

section .text
    global _start

; Function to print a string
; Input: rsi = string address, rdx = length
print_string:
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    syscall
    ret

; Function to get string length
; Input: rdi = string address
; Output: rax = length
string_length:
    xor rax, rax
    .loop:
        cmp byte [rdi + rax], 0
        je .done
        inc rax
        jmp .loop
    .done:
    ret

; Function to copy string
; Input: rsi = source, rdi = destination
copy_string:
    .loop:
        mov al, [rsi]
        mov [rdi], al
        inc rsi
        inc rdi
        test al, al
        jnz .loop
    ret

; Function to compare strings
; Input: rsi = string1, rdi = string2
; Output: ZF set if equal
compare_strings:
    .loop:
        mov al, [rsi]
        mov bl, [rdi]
        cmp al, bl
        jne .not_equal
        test al, al
        jz .equal
        inc rsi
        inc rdi
        jmp .loop
    .equal:
        cmp al, al  ; Set ZF
        ret
    .not_equal:
        test al, al  ; Clear ZF
        ret

_start:
    ; Main shell loop
    shell_loop:
        ; Display prompt
        mov rsi, prompt
        mov rdi, prompt
        call string_length
        mov rdx, rax
        call print_string

        ; Read input
        mov rax, 0          ; sys_read
        mov rdi, 0          ; stdin
        mov rsi, input
        mov rdx, 256
        syscall

        ; Check for read error or EOF (Ctrl+D)
        test rax, rax
        jz exit_shell       ; EOF, exit
        js shell_loop       ; Error, try again

        ; Store input length
        mov [input_len], rax

        ; Remove newline from input
        mov rdi, input
        add rdi, rax
        dec rdi
        cmp byte [rdi], 10  ; Check if last character is newline
        jne .no_newline
        mov byte [rdi], 0   ; Replace newline with null terminator
        .no_newline:

        ; Check if input is empty
        mov rdi, input
        call string_length
        test rax, rax
        jz shell_loop       ; Empty input, show prompt again

        ; Check for exit command
        mov rsi, exit_cmd
        mov rdi, input
        call compare_strings
        je exit_shell

        ; Try to execute command
        call execute_command
        jmp shell_loop

execute_command:
    ; Fork a new process
    mov rax, 57         ; sys_fork
    syscall

    test rax, rax
    jz .child_process   ; In child process

    ; Parent process - wait for child to complete
    push rax            ; Save child PID
    mov rdi, rax        ; PID to wait for
    xor rsi, rsi        ; status
    xor rdx, rdx        ; options
    mov rax, 61         ; sys_wait4
    syscall
    pop rax             ; Restore child PID
    ret

.child_process:
    ; Prepare command path - try /bin/ first
    mov rsi, slash_bin
    mov rdi, command
    call copy_string

    ; Append the command name
    mov rsi, input
    mov rdi, command
    mov rdi, command
    call string_length
    add rdi, rax
    call copy_string

    ; Set up arguments for execve
    ; argv[0] = command, argv[1] = NULL
    xor rax, rax
    push rax            ; NULL terminator
    lea rax, [command]
    push rax            ; Command path

    mov rdi, command    ; filename
    mov rsi, rsp        ; argv

    ; envp = NULL
    xor rdx, rdx

    ; Execute the command
    mov rax, 59         ; sys_execve
    syscall

    ; If we get here, execve failed
    ; Try executing the command directly (in case it's a full path)
    mov rdi, input      ; filename
    mov rsi, rsp        ; argv
    mov rax, 59         ; sys_execve
    syscall

    ; If we still get here, both attempts failed
    ; Print error message and exit child process
    mov rdi, cmd_not_found
    call string_length
    mov rdx, rax
    mov rsi, cmd_not_found
    call print_string

    ; Exit child process
    mov rax, 60         ; sys_exit
    mov rdi, 1          ; error code
    syscall

exit_shell:
    ; Exit the shell
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; exit code
    syscall
