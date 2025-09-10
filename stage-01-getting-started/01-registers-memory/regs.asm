; regs.asm

section .data
  msg db "Registers demo complete: ", 0xa
  len equ $-msg


section .text
  global _start


_start
  ; move the values into regs
  mov rax, 5
  mov rbx, 10
  add rax, rbx ; rax = rax + rbx
  
  ; write messages using syscall
  mov rax, 1
  mov rdi, 1
  mov rsi, msg
  mov rdx, len
  syscall

  
  ; exit
  mov rax, 60
  xor rdi, rdi
  syscall

