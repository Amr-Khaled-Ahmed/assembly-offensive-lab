# x86/x64 Assembly Cheat Sheet

## Table of Contents
1. [Registers](#registers)
2. [Data Types](#data-types)
3. [Instruction Syntax](#instruction-syntax)
4. [Common Instructions](#common-instructions)
5. [Memory Addressing](#memory-addressing)
6. [System Calls](#system-calls)
7. [Function Calls](#function-calls)
8. [Conditional Execution](#conditional-execution)
9. [Stack Operations](#stack-operations)
10. [Building and Linking](#building-and-linking)
11. [Useful Tools](#useful-tools)

---

## Registers

### General Purpose Registers (64-bit/32-bit/16-bit/8-bit)
| 64-bit | 32-bit | 16-bit | High 8-bit | Low 8-bit | Purpose |
|--------|--------|--------|------------|-----------|---------|
| RAX    | EAX    | AX     | AH         | AL        | Accumulator |
| RBX    | EBX    | BX     | BH         | BL        | Base |
| RCX    | ECX    | CX     | CH         | CL        | Counter |
| RDX    | EDX    | DX     | DH         | DL        | Data |
| RSI    | ESI    | SI     | -          | SIL       | Source Index |
| RDI    | EDI    | DI     | -          | DIL       | Destination Index |
| RBP    | EBP    | BP     | -          | BPL       | Base Pointer |
| RSP    | ESP    | SP     | -          | SPL       | Stack Pointer |
| R8     | R8D    | R8W    | -          | R8B       | Extended 8 |
| R9     | R9D    | R9W    | -          | R9B       | Extended 9 |
| R10    | R10D   | R10W   | -          | R10B      | Extended 10 |
| R11    | R11D   | R11W   | -          | R11B      | Extended 11 |
| R12    | R12D   | R12W   | -          | R12B      | Extended 12 |
| R13    | R13D   | R13W   | -          | R13B      | Extended 13 |
| R14    | R14D   | R14W   | -          | R14B      | Extended 14 |
| R15    | R15D   | R15W   | -          | R15B      | Extended 15 |

### Special Registers
| Register | Purpose |
|----------|---------|
| RIP      | Instruction Pointer |
| RFLAGS   | Flags Register |
| CS       | Code Segment |
| DS       | Data Segment |
| SS       | Stack Segment |
| ES       | Extra Segment |
| FS       | Extra Segment |
| GS       | Extra Segment |

### Flags Register (RFLAGS)
| Flag | Bit | Meaning |
|------|-----|---------|
| CF   | 0   | Carry Flag |
| PF   | 2   | Parity Flag |
| AF   | 4   | Auxiliary Flag |
| ZF   | 6   | Zero Flag |
| SF   | 7   | Sign Flag |
| TF   | 8   | Trap Flag |
| IF   | 9   | Interrupt Enable Flag |
| DF   | 10  | Direction Flag |
| OF   | 11  | Overflow Flag |

---

## Data Types

| Directive | Size | Purpose |
|-----------|-------|---------|
| DB        | 1 byte | Define Byte |
| DW        | 2 bytes | Define Word |
| DD        | 4 bytes | Define Doubleword |
| DQ        | 8 bytes | Define Quadword |
| RESB      | 1 byte | Reserve Byte |
| RESW      | 2 bytes | Reserve Word |
| RESD      | 4 bytes | Reserve Doubleword |
| RESQ      | 8 bytes | Reserve Quadword |

Example:
```asm
section .data
    byte_var db 0x41        ; 1 byte with value 65 ('A')
    word_var dw 0x1234      ; 2 bytes
    dword_var dd 0x12345678 ; 4 bytes
    qword_var dq 0x123456789ABCDEF0 ; 8 bytes
    string db "Hello", 0    ; Null-terminated string
    array times 10 db 0     ; Array of 10 bytes

section .bss
    buffer resb 256         ; Reserve 256 bytes
```

---

## Instruction Syntax

### NASM Syntax
```asm
instruction destination, source
```

Examples:
```asm
mov rax, rbx        ; Copy RBX to RAX
add rax, 10         ; Add 10 to RAX
sub rbx, rcx        ; Subtract RCX from RBX
```

### AT&T vs Intel Syntax
| Feature | Intel Syntax | AT&T Syntax |
|---------|--------------|-------------|
| Order   | dest, src    | src, dest   |
| Operand size | byte ptr, word ptr, etc | movb, movw, etc |
| Registers | rax, rbx     | %rax, %rbx  |
| Immediate | 10           | $10         |
| Memory   | [rax]        | (%rax)      |

---

## Common Instructions

### Data Transfer
| Instruction | Example | Description |
|-------------|---------|-------------|
| MOV | `mov rax, rbx` | Move data |
| LEA | `lea rax, [rbx+rcx]` | Load effective address |
| XCHG | `xchg rax, rbx` | Exchange registers |
| MOVZX | `movzx eax, bl` | Move with zero extend |
| MOVSX | `movsx eax, bl` | Move with sign extend |

### Arithmetic
| Instruction | Example | Description |
|-------------|---------|-------------|
| ADD | `add rax, rbx` | Addition |
| SUB | `sub rax, rbx` | Subtraction |
| INC | `inc rax` | Increment |
| DEC | `dec rax` | Decrement |
| MUL | `mul rbx` | Unsigned multiply (RAX * RBX → RDX:RAX) |
| IMUL | `imul rbx` | Signed multiply |
| DIV | `div rbx` | Unsigned divide (RDX:RAX / RBX → RAX=quotient, RDX=remainder) |
| IDIV | `idiv rbx` | Signed divide |
| NEG | `neg rax` | Two's complement negation |

### Bitwise Operations
| Instruction | Example | Description |
|-------------|---------|-------------|
| AND | `and rax, rbx` | Bitwise AND |
| OR | `or rax, rbx` | Bitwise OR |
| XOR | `xor rax, rbx` | Bitwise XOR |
| NOT | `not rax` | Bitwise NOT |
| SHL | `shl rax, cl` | Shift left |
| SHR | `shr rax, cl` | Shift right (logical) |
| SAR | `sar rax, cl` | Shift right (arithmetic) |

### Control Flow
| Instruction | Example | Description |
|-------------|---------|-------------|
| JMP | `jmp label` | Unconditional jump |
| JE/JZ | `je label` | Jump if equal/zero |
| JNE/JNZ | `jne label` | Jump if not equal/not zero |
| JG/JNLE | `jg label` | Jump if greater |
| JGE/JNL | `jge label` | Jump if greater or equal |
| JL/JNGE | `jl label` | Jump if less |
| JLE/JNG | `jle label` | Jump if less or equal |
| CALL | `call function` | Call function |
| RET | `ret` | Return from function |
| LOOP | `loop label` | Decrement RCX and jump if not zero |

### String Operations
| Instruction | Example | Description |
|-------------|---------|-------------|
| MOVSB | `movsb` | Move byte from [RSI] to [RDI] |
| MOVSW | `movsw` | Move word |
| MOVSD | `movsd` | Move doubleword |
| MOVSQ | `movsq` | Move quadword |
| CMPSB | `cmpsb` | Compare bytes |
| SCASB | `scasb` | Scan string |
| STOSB | `stosb` | Store byte |
| LODSB | `lodsb` | Load byte |

---

## Memory Addressing

### Addressing Modes
```asm
mov rax, [rbx]          ; Direct: RAX = value at address in RBX
mov rax, [rbx + rcx]    ; Base + index: RAX = value at RBX + RCX
mov rax, [rbx + rcx*4]  ; Scaled index: RAX = value at RBX + RCX*4
mov rax, [rbx + 10]     ; Displacement: RAX = value at RBX + 10
mov rax, [rbx + rcx + 10] ; All combined
```

### Example
```asm
section .data
    array dq 10, 20, 30, 40, 50

section .text
    mov rbx, array      ; RBX points to array
    mov rax, [rbx]      ; RAX = 10
    mov rax, [rbx + 8]  ; RAX = 20 (8 bytes per element)
    mov rax, [rbx + 16] ; RAX = 30
```

---

## System Calls

### Linux x86-64 System Call Convention
| Register | Purpose |
|----------|---------|
| RAX      | System call number |
| RDI      | First argument |
| RSI      | Second argument |
| RDX      | Third argument |
| R10      | Fourth argument |
| R8       | Fifth argument |
| R9       | Sixth argument |

### Common System Calls
| Call | RAX | RDI | RSI | RDX | Description |
|------|-----|-----|-----|-----|-------------|
| read | 0 | fd | buffer | count | Read from file |
| write | 1 | fd | buffer | count | Write to file |
| open | 2 | pathname | flags | mode | Open file |
| close | 3 | fd | - | - | Close file |
| exit | 60 | status | - | - | Exit process |
| brk | 12 | addr | - | - | Change data segment size |

### System Call Example
```asm
section .data
    msg db 'Hello, World!', 10
    msg_len equ $ - msg

section .text
    global _start

_start:
    ; Write to stdout
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, msg        ; message
    mov rdx, msg_len    ; message length
    syscall

    ; Exit
    mov rax, 60         ; sys_exit
    mov rdi, 0          ; exit code
    syscall
```

---

## Function Calls

### Calling Convention (System V AMD64 ABI)
| Parameter | Register |
|-----------|----------|
| 1st | RDI |
| 2nd | RSI |
| 3rd | RDX |
| 4th | RCX |
| 5th | R8 |
| 6th | R9 |
| Additional | Stack |
| Return value | RAX |

### Function Prologue and Epilogue
```asm
my_function:
    push rbp            ; Save old base pointer
    mov rbp, rsp        ; Set new base pointer
    sub rsp, 16         ; Allocate space for local variables

    ; Function body

    mov rsp, rbp        ; Restore stack pointer
    pop rbp             ; Restore base pointer
    ret                 ; Return
```

### Example Function
```asm
; Function that adds two numbers
; Input: RDI = a, RSI = b
; Output: RAX = a + b
add_numbers:
    push rbp
    mov rbp, rsp

    mov rax, rdi
    add rax, rsi

    mov rsp, rbp
    pop rbp
    ret

; Call the function
mov rdi, 10
mov rsi, 20
call add_numbers
; RAX now contains 30
```

---

## Conditional Execution

### Comparison Instructions
| Instruction | Example | Description |
|-------------|---------|-------------|
| CMP | `cmp rax, rbx` | Compare RAX and RBX |
| TEST | `test rax, rax` | Bitwise AND (sets flags) |

### Conditional Jumps
| Instruction | Condition | Description |
|-------------|-----------|-------------|
| JE/JZ | ZF=1 | Jump if equal/zero |
| JNE/JNZ | ZF=0 | Jump if not equal/not zero |
| JG/JNLE | ZF=0 and SF=OF | Jump if greater |
| JGE/JNL | SF=OF | Jump if greater or equal |
| JL/JNGE | SF≠OF | Jump if less |
| JLE/JNG | ZF=1 or SF≠OF | Jump if less or equal |
| JA/JNBE | CF=0 and ZF=0 | Jump if above (unsigned) |
| JAE/JNB | CF=0 | Jump if above or equal (unsigned) |
| JB/JNAE | CF=1 | Jump if below (unsigned) |
| JBE/JNA | CF=1 or ZF=1 | Jump if below or equal (unsigned) |

### Example
```asm
cmp rax, rbx
jg greater          ; Jump if RAX > RBX
jl less             ; Jump if RAX < RBX
je equal            ; Jump if RAX == RBX

greater:
    ; RAX is greater
    jmp done

less:
    ; RAX is less
    jmp done

equal:
    ; RAX is equal to RBX

done:
```

---

## Stack Operations

### Stack Instructions
| Instruction | Example | Description |
|-------------|---------|-------------|
| PUSH | `push rax` | Push onto stack |
| POP | `pop rax` | Pop from stack |
| PUSHF | `pushf` | Push flags register |
| POPF | `popf` | Pop flags register |
| ENTER | `enter 16, 0` | Create stack frame |
| LEAVE | `leave` | Destroy stack frame |

### Stack Example
```asm
section .text
    push rax        ; Save RAX
    push rbx        ; Save RBX

    ; Do something

    pop rbx         ; Restore RBX
    pop rax         ; Restore RAX
```

---

## Building and Linking

### Assembling with NASM
```bash
# For 64-bit
nasm -f elf64 program.asm -o program.o

# For 32-bit
nasm -f elf32 program.asm -o program.o
```

### Linking with LD
```bash
# For 64-bit
ld program.o -o program

# For 32-bit
ld -m elf_i386 program.o -o program
```

### Linking with GCC (for C libraries)
```bash
# For 64-bit
gcc -nostdlib program.o -o program

# For 32-bit
gcc -m32 -nostdlib program.o -o program
```

### Complete Build Script
```bash
#!/bin/bash
# Build script for x86-64 assembly

# Assemble
nasm -f elf64 "$1.asm" -o "$1.o"

# Link
ld "$1.o" -o "$1"

# Clean up (optional)
rm "$1.o"

echo "Built $1 successfully"
```

---

## Useful Tools

### Debuggers
- **GDB**: GNU Debugger with assembly support
- **LLDB**: LLVM Debugger
- **Radare2**: Reverse engineering framework

### Disassemblers
- **objdump**: `objdump -d program`
- **ndisasm**: NASM disassembler
- **IDA Pro**: Commercial disassembler
- **Ghidra**: NSA's reverse engineering tool

### Other Tools
- **strace**: Trace system calls
- **ltrace**: Trace library calls
- **readelf**: Display ELF information
- **hexdump**: Hex viewer

### GDB Commands for Assembly
```
gdb ./program
(gdb) layout asm      # Show assembly layout
(gdb) break *0x400000 # Set breakpoint at address
(gdb) ni              # Next instruction
(gdb) si              # Step instruction
(gdb) info registers  # Show all registers
(gdb) x/10i $rip      # Examine 10 instructions at RIP
```

---

## Quick Reference

### Common Instructions Cheat Sheet
```
Data Movement: MOV, LEA, XCHG, MOVZX, MOVSX
Arithmetic: ADD, SUB, INC, DEC, MUL, IMUL, DIV, IDIV, NEG
Bitwise: AND, OR, XOR, NOT, SHL, SHR, SAR
Control Flow: JMP, JE, JNE, JG, JL, JGE, JLE, CALL, RET, LOOP
String: MOVSB, MOVSW, MOVSD, MOVSQ, CMPSB, SCASB, STOSB, LODSB
Stack: PUSH, POP, PUSHF, POPF, ENTER, LEAVE
```

### Common Syscalls (Linux x86-64)
```
0: read       1: write      2: open       3: close
60: exit      9: mmap       10: mprotect  11: munmap
12: brk       13: rt_sigaction 14: rt_sigprocmask
```

This cheat sheet covers the essentials of x86/x64 assembly programming. Keep it handy as you work on your projects!
