; 02-custom-loader.asm
; x86_64 NASM assembly (Linux). Fun small "custom loader".
; - Writes a payload script to /tmp/02_payload.sh
; - Makes it executable, forks, execve's the payload, parent waits
; - If UID==0 (root), also writes a fun /etc/motd message
;
; Build:
;   nasm -felf64 02-custom-loader.asm -o 02-custom-loader.o
;   ld 02-custom-loader.o -o 02-custom-loader
;
; Run:
;   ./02-custom-loader
; To test root-only behavior (careful):
;   sudo ./02-custom-loader
;
; This program purposely keeps syscalls explicit and commented
; so it's easy to read and modify. Designed for WSL / Linux x86_64.

BITS 64
GLOBAL _start

SECTION .data
; Paths
tmp_path:       db  "/tmp/02_payload.sh", 0
tmp_path_len    equ $ - tmp_path

motd_path:      db  "/etc/motd", 0
motd_path_len   equ $ - motd_path

; Payload script contents (a small shell script with animation)
payload:        db  "#!/bin/sh",10
                db  "echo",32,"\"(•_•) Loading custom payload...\"",10
                db  "for i in 1 2 3 4; do",10
                db  "  printf \".\"; sleep 0.4; done",10
                db  "echo",10
                db  "printf \"\\nSurprise! I'm the payload — executed by 02-custom-loader.\\n\"",10
                db  "sleep 0.6",10
                db  "printf \"Here's a tiny fortune: \\\"Keep hacking (ethically) and learning!\\\"\\n\"",10
                db  "echo",10
                db  "exit 0",10
payload_len     equ $ - payload

; motd message to write if root
motd_msg:       db  "Welcome! This system was greeted by 02-custom-loader.",10
motd_msg_len    equ $ - motd_msg

; argv arrays for execve: char *argv[] = { "/tmp/02_payload.sh", NULL }
section .data
argv_tmp:       dq tmp_path
                dq 0

; environment NULL
envp:           dq 0

SECTION .text

; ---------- helper: sys_write(fd, buf, len) ----------
; args: rdi = fd, rsi = buf, rdx = len
; clobbers rax
sys_write:
    mov rax, 1          ; sys_write
    syscall
    ret

; ---------- helper: sys_open(path, flags, mode) ----------
; args: rdi = path, rsi = flags, rdx = mode
; returns rax = fd or negative errno
sys_open:
    mov rax, 2          ; sys_open
    syscall
    ret

; ---------- helper: sys_close(fd) ----------
sys_close:
    mov rax, 3
    syscall
    ret

; ---------- helper: sys_chmod(path, mode) ----------
; args: rdi = path, rsi = mode
sys_chmod:
    mov rax, 90         ; sys_chmod
    syscall
    ret

; ---------- helper: sys_fork() ----------
sys_fork:
    mov rax, 57         ; fork
    syscall
    ret

; ---------- helper: sys_execve(path, argv, envp) ----------
; rdi=path, rsi=argv, rdx=envp
sys_execve:
    mov rax, 59         ; execve
    syscall
    ret

; ---------- helper: sys_wait4(pid, status, options, rusage) ----------
; rdi=pid, rsi=status_ptr, rdx=options, r10=rusage_ptr
sys_wait4:
    mov rax, 61
    syscall
    ret

; ---------- helper: getuid ----------
get_uid:
    mov rax, 102        ; getuid (x86_64)
    syscall
    ret

; ---------- _start ----------
_start:
    ; 1) Check UID; if root (0) we'll later write /etc/motd
    call get_uid
    cmp rax, 0
    jne .not_root
    mov r12, 1          ; flag: root
    jmp .uid_checked
.not_root:
    mov r12, 0
.uid_checked:

    ; 2) Create /tmp/02_payload.sh with mode 0755
    lea rdi, [rel tmp_path]      ; path
    mov rsi, 577                 ; O_CREAT | O_WRONLY | O_TRUNC  (1 | 64 | 512) = 577
    mov rdx, 493                 ; mode 0755 decimal = 0o755 = 493
    call sys_open
    cmp rax, 0
    js .open_failed
    mov r13, rax                 ; keep fd in r13

    ; 3) write payload
    mov rdi, r13                 ; fd
    lea rsi, [rel payload]
    mov rdx, payload_len
    call sys_write

    ; 4) close fd
    mov rdi, r13
    call sys_close

    ; 5) chmod the file to be sure (0755)
    lea rdi, [rel tmp_path]
    mov rsi, 493
    call sys_chmod

    ; 6) If root, write /etc/motd (careful — requires root)
    cmp r12, 0
    je .no_motd
    ; open /etc/motd for writing (truncate/create)
    lea rdi, [rel motd_path]
    mov rsi, 577
    mov rdx, 420                ; mode 0644 = 420 dec
    call sys_open
    cmp rax, 0
    js .skip_motd_write
    mov r14, rax                ; motd fd
    mov rdi, r14
    lea rsi, [rel motd_msg]
    mov rdx, motd_msg_len
    call sys_write
    mov rdi, r14
    call sys_close
.skip_motd_write:
.no_motd:

    ; 7) Fork and exec the payload, parent waits
    call sys_fork
    cmp rax, 0
    je .child_exec
    ; parent
    mov rdi, rax                ; pid
    lea rsi, [rel rsp]          ; status pointer on stack (we don't need value)
    mov rdx, 0
    mov r10, 0
    call sys_wait4
    ; after child exit, print a small message and exit
    lea rdi, [rel done_msg]
    mov rsi, rdi                ; use write helper with fd=1 later
    ; prepare actual write: fd=1, buf=done_msg, len
    mov rdi, 1
    lea rsi, [rel done_msg]
    mov rdx, done_msg_len
    call sys_write
    jmp .exit_ok

.child_exec:
    ; child: execve("/tmp/02_payload.sh", argv_tmp, envp)
    lea rdi, [rel tmp_path]
    lea rsi, [rel argv_tmp]
    lea rdx, [rel envp]
    call sys_execve
    ; if execve fails, exit with code 1
    mov rdi, 1
    mov rax, 60
    syscall

.open_failed:
    ; Write an error to stderr (fd=2) and exit 1
    mov rdi, 2
    lea rsi, [rel err_open]
    mov rdx, err_open_len
    call sys_write
    mov rdi, 1
    mov rax, 60
    syscall

.exit_ok:
    ; normal exit(0)
    mov rdi, 0
    mov rax, 60
    syscall

SECTION .rodata
done_msg:       db  "[loader] payload finished. Have a nice day! (./02-custom-loader)\n",0
done_msg_len    equ $ - done_msg

err_open:       db  "[loader] failed to create payload in /tmp. Exiting.\n",0
err_open_len    equ $ - err_open
