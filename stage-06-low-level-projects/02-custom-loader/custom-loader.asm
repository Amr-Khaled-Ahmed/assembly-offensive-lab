; Minimal single-file custom loader (NASM)
; Loads sector 2 into memory and prints a 128-byte hex+ASCII dump.
; Assemble: nasm -f bin custom-loader.asm -o custom-loader.img
; Run: qemu-system-i386 -fda custom-loader.img -boot a

org 0x7C00
bits 16

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; save boot drive (DL)
    mov [boot_drive], dl

    ; message
    mov si, msg_loading
    call print_string

    ; destination ES:BX = 0x1000:0x0000
    mov ax, 0x1000
    mov es, ax
    xor bx, bx

    ; Read 1 sector (sector 2) CHS style
    mov ah, 0x02       ; BIOS read sectors
    mov al, 1          ; number sectors
    mov ch, 0          ; cylinder 0
    mov cl, 2          ; sector 2 (first after boot)
    mov dh, 0          ; head 0
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    ; set DS to 0x1000 so we can access loaded data at DS:offset
    mov ax, 0x1000
    mov ds, ax
    xor si, si         ; SI = offset 0 (start of loaded sector)

    mov cx, 128        ; number of bytes to dump
    mov bx, 0          ; column counter (0..15)

dump_loop:
    mov al, [si]       ; byte to print
    push cx
    push si
    call print_hex_byte ; prints two hex chars for AL
    call print_char_sp  ; prints ' ' (space)
    ; print ASCII (printable 32..126 else '.')
    mov al, [si]
    cmp al, 32
    jb .putdot
    cmp al, 126
    ja .putdot
    call print_char     ; printable, prints AL
    jmp .cont
.putdot:
    mov al, '.'
    call print_char
.cont:
    pop si
    pop cx
    inc si
    inc bx
    cmp bx, 16
    jne .no_nl
    ; newline after 16 bytes
    mov si, msg_nl
    call print_string
    xor bx, bx
.no_nl:
    loop dump_loop

    ; done
    mov si, msg_done
    call print_string
    jmp $

; --------------------------
; print_hex_byte: input AL = byte
; prints two hex chars (high nibble then low nibble) using INT 10h teletype
print_hex_byte:
    push ax
    push bx
    push cx
    push dx

    mov bl, al
    ; high nibble
    mov ah, bl
    and ah, 0xF0
    shr ah, 4
    call print_nibble  ; prints AH as hex char (uses AL for output)
    ; low nibble
    mov ah, bl
    and ah, 0x0F
    mov al, ah
    call print_nibble

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; print_nibble: input AL = nibble (0..15) ; outputs one ASCII hex char via INT10
; note: this routine expects nibble in AL
print_nibble:
    push ax
    cmp al, 10
    jb .digit
    add al, 55    ; 'A' = 65; 10 -> 'A' (10 + 55 = 65)
    jmp .out
.digit:
    add al, '0'
.out:
    ; teletype print AL
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    pop ax
    ret

; print_char_sp: prints a single space character
print_char_sp:
    mov al, ' '
    call print_char
    ret

; print_char: inputs AL -> print via BIOS teletype (INT 10h)
print_char:
    push ax
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    pop ax
    ret

; print_string: SI -> zero-terminated string
print_string:
    pusha
.ps_loop:
    lodsb
    cmp al, 0
    je .ps_done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    jmp .ps_loop
.ps_done:
    popa
    ret

disk_error:
    mov si, msg_err
    call print_string
    jmp $

; --------------------------
boot_drive: db 0

msg_loading: db 'Loading sector 2 -> memory (0x1000:0x0000)...',0x0D,0x0A,0
msg_err:     db 'Disk read error! Halting.',0x0D,0x0A,0
msg_nl:      db 0x0D,0x0A,0
msg_done:    db 0x0D,0x0A, 'Dump complete. Halting.',0x0D,0x0A,0

; pad to 510 bytes and signature
times 510 - ($ - $$) db 0
dw 0xAA55
