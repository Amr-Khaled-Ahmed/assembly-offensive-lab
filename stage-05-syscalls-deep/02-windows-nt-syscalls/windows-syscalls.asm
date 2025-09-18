section .data
filename db "test.txt",0
buffer db "Hello World",0
bufsize dq 11
handle dq 0
newline db 0xA

section .text
global main

main:
    ; ----------------------------
    ; 1. NtCreateFile (placeholder)
    ; ----------------------------
    mov rax, 0x55        ; NtCreateFile (example)
    mov rcx, 0            ; OUT handle
    mov rdx, 0            ; OBJECT_ATTRIBUTES
    mov r8, 0             ; DesiredAccess
    mov r9, 0             ; FileAttributes
    mov r10, 0            ; CreateDisposition
    syscall

    ; ----------------------------
    ; 2. NtReadFile
    ; ----------------------------
    mov rax, 0x3F         ; NtReadFile (example)
    mov rcx, [handle]
    mov rdx, buffer
    mov r8, bufsize
    syscall

    ; ----------------------------
    ; 3. NtWriteFile
    ; ----------------------------
    mov rax, 0x40         ; NtWriteFile (example)
    mov rcx, [handle]
    mov rdx, buffer
    mov r8, bufsize
    syscall

    ; ----------------------------
    ; 4. NtClose
    ; ----------------------------
    mov rax, 0x19         ; NtClose
    mov rcx, [handle]
    syscall

    ; ----------------------------
    ; 5. NtQueryInformationProcess
    ; ----------------------------
    mov rax, 0x24         ; NtQueryInformationProcess
    mov rcx, -1           ; Current process handle
    mov rdx, 0            ; ProcessInformationClass pointer
    mov r8, 0             ; ProcessInformation pointer
    mov r9, 0             ; ProcessInformationLength
    syscall

    ; ----------------------------
    ; 6. NtAllocateVirtualMemory
    ; ----------------------------
    mov rax, 0x18         ; NtAllocateVirtualMemory (example)
    mov rcx, -1           ; ProcessHandle = current process
    mov rdx, 0            ; BaseAddress pointer
    mov r8, 0             ; ZeroBits
    mov r9, 4096          ; RegionSize pointer
    mov r10, 0x3000       ; AllocationType
    mov r11, 0x04         ; Protect = PAGE_READWRITE
    syscall

    ; ----------------------------
    ; 7. NtFreeVirtualMemory
    ; ----------------------------
    mov rax, 0x19         ; NtFreeVirtualMemory (example)
    mov rcx, -1           ; ProcessHandle
    mov rdx, 0            ; BaseAddress pointer
    mov r8, 4096          ; RegionSize pointer
    mov r9, 0x8000        ; FreeType
    syscall

    ; ----------------------------
    ; 8. NtProtectVirtualMemory
    ; ----------------------------
    mov rax, 0x50         ; NtProtectVirtualMemory (example)
    mov rcx, -1
    mov rdx, 0
    mov r8, 4096
    mov r9, 0x20          ; NewProtect = PAGE_EXECUTE_READ
    syscall

    ; ----------------------------
    ; 9. NtCreateThreadEx
    ; ----------------------------
    mov rax, 0xCE         ; NtCreateThreadEx (example)
    xor rcx, rcx
    xor rdx, rdx
    xor r8, r8
    xor r9, r9
    syscall

    ; ----------------------------
    ; 10. NtTerminateProcess
    ; ----------------------------
    mov rax, 0x29         ; NtTerminateProcess (example)
    mov rcx, -1           ; Current process
    xor rdx, rdx          ; ExitStatus
    syscall

    ret
