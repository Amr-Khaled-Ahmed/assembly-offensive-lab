# Ultimate x86/x64 Assembly Mastery Cheat Sheet

## Table of Contents
1. [Registers Deep Dive](#registers-deep-dive)
2. [Data Types & Memory Management](#data-types--memory-management)
3. [Instruction Set Architecture](#instruction-set-architecture)
4. [Memory Addressing Modes](#memory-addressing-modes)
5. [System Calls & ABI](#system-calls--abi)
6. [Function Calling Conventions](#function-calling-conventions)
7. [Advanced Control Flow](#advanced-control-flow)
8. [Floating Point & SIMD](#floating-point--simd)
9. [Optimization Techniques](#optimization-techniques)
10. [Debugging & Reverse Engineering](#debugging--reverse-engineering)
11. [Building & Toolchain](#building--toolchain)
12. [Real-World Examples](#real-world-examples)

---

## Registers Deep Dive

### General Purpose Registers Hierarchy
```
64-bit      32-bit      16-bit      8-bit (high)  8-bit (low)   Purpose
----------------------------------------------------------------------------
RAX         EAX         AX          AH            AL           Accumulator
RBX         EBX         BX          BH            BL           Base
RCX         ECX         CX          CH            CL           Counter
RDX         EDX         DX          DH            DL           Data
RSI         ESI         SI          -             SIL          Source Index
RDI         EDI         DI          -             DIL          Destination Index
RBP         EBP         BP          -             BPL          Base Pointer
RSP         ESP         SP          -             SPL          Stack Pointer
R8          R8D         R8W         -             R8B          Extended 8
R9          R9D         R9W         -             R9B          Extended 9
R10         R10D        R10W        -             R10B         Extended 10
R11         R11D        R11W        -             R11B         Extended 11
R12         R12D        R12W        -             R12B         Extended 12
R13         R13D        R13W        -             R13B         Extended 13
R14         R14D        R14W        -             R14B         Extended 14
R15         R15D        R15W        -             R15B         Extended 15
```

### Special Registers & Their Functions
| Register | Purpose | Access Level |
|----------|---------|--------------|
| RIP | Instruction Pointer | Implicit |
| RFLAGS | Flags Register | Special instructions |
| CR0-CR4 | Control Registers | Privileged |
| DR0-DR7 | Debug Registers | Privileged |
| CS | Code Segment | Privileged |
| DS | Data Segment | Privileged |
| SS | Stack Segment | Privileged |
| ES | Extra Segment | Privileged |
| FS | Thread-Local Storage | Privileged |
| GS | OS-Specific Usage | Privileged |

### RFLAGS Breakdown
```
Bit  Name    Description
----------------------------------------------------------------------------
0    CF      Carry Flag - Set on unsigned overflow/borrow
1    -       Reserved
2    PF      Parity Flag - Set if low byte has even number of 1 bits
3    -       Reserved
4    AF      Adjust Flag - Carry for BCD operations
5    -       Reserved
6    ZF      Zero Flag - Set if result is zero
7    SF      Sign Flag - Set if result is negative (MSB = 1)
8    TF      Trap Flag - Enables single-step mode
9    IF      Interrupt Enable Flag - Enables maskable interrupts
10   DF      Direction Flag - 0=forward, 1=backward for string operations
11   OF      Overflow Flag - Set on signed overflow
12-13 IOPL   I/O Privilege Level (protected mode)
14   NT      Nested Task Flag (protected mode)
15   -       Reserved
16   RF      Resume Flag - Controls debug exceptions
17   VM      Virtual-8086 Mode
18   AC      Alignment Check
19   VIF     Virtual Interrupt Flag
20   VIP     Virtual Interrupt Pending
21   ID      CPUID Identification Flag
22-63 -      Reserved
```

---

## Data Types & Memory Management

### Data Definition Directives
```asm
; Basic data types
db  0x41, 0x42, 0x43      ; Define bytes (8-bit)
dw  0x1234, 0x5678        ; Define words (16-bit)
dd  0x12345678            ; Define doublewords (32-bit)
dq  0x123456789ABCDEF0    ; Define quadwords (64-bit)
dt  1.234567890123456e-10 ; Define tenbytes (80-bit float)

; Special directives
times 10 db 0             ; Repeat 10 times
incbin "file.bin"         ; Include binary file
equ  $ - label            ; Define constant

; Floating point
dd  1.234                 ; Single precision (32-bit)
dq  1.234567890123456     ; Double precision (64-bit)
dt  1.234567890123456789  ; Extended precision (80-bit)
```

### Memory Sections & Alignment
```asm
section .data              ; Initialized data
    align 16               ; 16-byte alignment
    data1 dd 1, 2, 3, 4

section .bss               ; Uninitialized data
    align 64               ; Cache line alignment
    buffer resb 4096       ; Reserve 4KB

section .rodata            ; Read-only data
    msg db "Hello", 0

section .text              ; Executable code
    align 16               ; Code alignment
    global _start

section .data.rel.local    ; Local relocatable data
section .data.rel          ; Relocatable data
```

### Structured Data
```asm
; Structure definition
struc person
    .name:    resb 32     ; 32-byte name
    .age:     resb 1      ; 1-byte age
    .height:  resw 1      ; 2-byte height
    .weight:  resw 1      ; 2-byte weight
    .next:    resq 1      ; 8-byte pointer
endstruc

; Instance
person1:
    istruc person
        at person.name,   db "John Doe",0
        at person.age,    db 30
        at person.height, dw 180
        at person.weight, dw 75
        at person.next,   dq 0
    iend

; Access
mov al, [person1 + person.age]
```

---

## Instruction Set Architecture

### Data Movement Mastery
```asm
; Basic moves
mov rax, rbx              ; Register to register
mov rax, [rbx]            ; Memory to register
mov [rax], rbx            ; Register to memory
mov rax, 1234             ; Immediate to register

; Advanced moves
movzx rax, byte [rsi]     ; Zero extend
movsx rax, byte [rsi]     ; Sign extend
movsxd rax, eax           ; Sign extend 32→64

; Atomic operations
xchg rax, [rbx]           ; Atomic exchange
cmpxchg [rbx], rcx        ; Compare and exchange
xadd [rbx], rax           ; Exchange and add

; Address calculation
lea rax, [rbx + rcx*4 + 16] ; Load effective address

; String operations
movsb                     ; Move byte [rsi]→[rdi], increment
movsw                     ; Move word
movsd                     ; Move dword
movsq                     ; Move qword

; I/O operations
in al, 0x60               ; Read from port
out 0x64, al              ; Write to port
```

### Arithmetic Operations
```asm
; Basic arithmetic
add rax, rbx              ; Addition
sub rax, rbx              ; Subtraction
inc rax                   ; Increment
dec rax                   ; Decrement
neg rax                   ; Negate

; Multiplication
mul rbx                   ; Unsigned: RAX * RBX → RDX:RAX
imul rax, rbx             ; Signed: RAX * RBX → RAX
imul rax, rbx, 10         ; RAX = RBX * 10

; Division
div rbx                   ; Unsigned: RDX:RAX / RBX → RAX=quot, RDX=rem
idiv rbx                  ; Signed division

; Decimal adjustment
aaa                       ; ASCII adjust after addition
aam                       ; ASCII adjust after multiplication
aad                       ; ASCII adjust before division
daa                       ; Decimal adjust after addition
das                       ; Decimal adjust after subtraction
```

### Bit Manipulation
```asm
; Logical operations
and rax, rbx              ; Bitwise AND
or rax, rbx               ; Bitwise OR
xor rax, rbx              ; Bitwise XOR
not rax                   ; Bitwise NOT
test rax, rbx             ; AND without storing (sets flags)

; Shifts
shl rax, cl               ; Logical left shift
shr rax, cl               ; Logical right shift
sal rax, cl               ; Arithmetic left shift (same as SHL)
sar rax, cl               ; Arithmetic right shift

; Rotates
rol rax, cl               ; Rotate left
ror rax, cl               ; Rotate right
rcl rax, cl               ; Rotate left through carry
rcr rax, cl               ; Rotate right through carry

; Bit test and manipulation
bts [rax], rbx            ; Bit test and set
btr [rax], rbx            ; Bit test and reset
btc [rax], rbx            ; Bit test and complement
bsf rax, rbx              ; Bit scan forward
bsr rax, rbx              ; Bit scan reverse
```

### Control Flow
```asm
; Unconditional jumps
jmp label                 ; Direct jump
jmp rax                   ; Register indirect jump
jmp [rax]                 ; Memory indirect jump

; Conditional jumps (based on CMP or TEST)
je label                  ; Jump if equal (ZF=1)
jne label                 ; Jump if not equal (ZF=0)
jg label                  ; Jump if greater (signed)
ja label                  ; Jump if above (unsigned)
jl label                  ; Jump if less (signed)
jb label                  ; Jump if below (unsigned)
jge label                 ; Jump if greater or equal (signed)
jae label                 ; Jump if above or equal (unsigned)
jle label                 ; Jump if less or equal (signed)
jbe label                 ; Jump if below or equal (unsigned)

; Loop instructions
loop label                ; Decrement RCX, jump if not zero
loope label               ; Decrement RCX, jump if not zero and ZF=1
loopne label              ; Decrement RCX, jump if not zero and ZF=0

; Function calls
call function             ; Direct call
call rax                  ; Indirect call
ret                       ; Return
ret 8                     ; Return and pop 8 bytes

; Conditional moves (CMOVcc)
cmove rax, rbx            ; Move if equal
cmovg rax, rbx            ; Move if greater
cmovl rax, rbx            ; Move if less
```

### String & Array Operations
```asm
; Direction flag control
cld                       ; Clear direction flag (forward)
std                       ; Set direction flag (backward)

; Basic string operations
movsb                     ; Move byte
movsw                     ; Move word
movsd                     ; Move dword
movsq                     ; Move qword

; Comparison operations
cmpsb                     ; Compare bytes
cmpsw                     ; Compare words
cmpsd                     ; Compare dwords
cmpsq                     ; Compare qwords

; Scanning operations
scasb                     ; Scan byte
scasw                     ; Scan word
scasd                     ; Scan dword
scasq                     ; Scan qword

; Storage operations
stosb                     ; Store byte
stosw                     ; Store word
stosd                     ; Store dword
stosq                     ; Store qword

; Loading operations
lodsb                     ; Load byte
lodsw                     ; Load word
lodsd                     ; Load dword
lodsq                     ; Load qword

; Repeat prefixes
rep movsb                 ; Repeat while RCX > 0
repe cmpsb                ; Repeat while equal and RCX > 0
repne scasb               ; Repeat while not equal and RCX > 0
```

---

## Memory Addressing Modes

### Addressing Mode Examples
```asm
; Direct addressing
mov rax, [0x1000]         ; Absolute address

; Register indirect
mov rax, [rbx]            ; Address in RBX

; Base + displacement
mov rax, [rbx + 16]       ; Base register + offset

; Indexed addressing
mov rax, [array + rcx*4]  ; Array with index

; Base + index
mov rax, [rbx + rcx]      ; Base + index

; Base + index + displacement
mov rax, [rbx + rcx*4 + 16] ; Full addressing mode

; RIP-relative (x86-64 only)
mov rax, [rel variable]   ; Relative to RIP
```

### Segment Overrides
```asm
mov ax, [fs:0x30]         ; FS segment override
mov eax, [gs:0x60]        ; GS segment override
mov rax, [cs:label]       ; CS segment override
mov rbx, [ds:data]        ; DS segment override
mov rcx, [ss:rsp+8]       ; SS segment override
mov rdx, [es:rdi]         ; ES segment override
```

---

## System Calls & ABI

### Linux x86-64 System Call Table (Partial)
| RAX | Name | RDI | RSI | RDX | R10 | R8 | R9 |
|-----|------|-----|-----|-----|-----|----|----|
| 0 | read | fd | buf | count | - | - | - |
| 1 | write | fd | buf | count | - | - | - |
| 2 | open | pathname | flags | mode | - | - | - |
| 3 | close | fd | - | - | - | - | - |
| 9 | mmap | addr | length | prot | flags | fd | offset |
| 10 | mprotect | addr | len | prot | - | - | - |
| 11 | munmap | addr | length | - | - | - | - |
| 12 | brk | addr | - | - | - | - | - |
| 13 | rt_sigaction | sig | act | oldact | sigsetsize | - | - |
| 14 | rt_sigprocmask | how | set | oldset | sigsetsize | - | - |
| 22 | pipe | pipefd | - | - | - | - | - |
| 32 | dup | oldfd | - | - | - | - | - |
| 33 | dup2 | oldfd | newfd | - | - | - | - |
| 39 | getpid | - | - | - | - | - | - |
| 57 | fork | - | - | - | - | - | - |
| 59 | execve | filename | argv | envp | - | - | - |
| 60 | exit | error_code | - | - | - | - | - |
| 61 | wait4 | pid | stat_addr | options | rusage | - | - |
| 63 | kill | pid | sig | - | - | - | - |
| 89 | readlink | path | buf | bufsiz | - | - | - |
| 158 | arch_prctl | code | addr | - | - | - | - |
| 202 | futex | uaddr | op | val | utime | uaddr2 | val3 |
| 231 | exit_group | error_code | - | - | - | - | - |

### Windows x64 Calling Convention
```asm
; Volatile registers: RAX, RCX, RDX, R8, R9, R10, R11
; Non-volatile: RBX, RBP, RDI, RSI, RSP, R12-R15, XMM6-XMM15

; Parameter passing:
; 1st: RCX
; 2nd: RDX
; 3rd: R8
; 4th: R9
; Additional: Stack (right to left)

; Example Windows system call
mov rcx, handle          ; First parameter
mov rdx, buffer          ; Second parameter
mov r8, length           ; Third parameter
call ReadFile
```

### System Call Wrapper Macro
```asm
%macro syscall 1-6
    %if %0 >= 2
        mov rdi, %2
    %endif
    %if %0 >= 3
        mov rsi, %3
    %endif
    %if %0 >= 4
        mov rdx, %4
    %endif
    %if %0 >= 5
        mov r10, %5
    %endif
    %if %0 >= 6
        mov r8, %6
    %endif
    mov rax, %1
    syscall
%endmacro

; Usage
syscall 1, 1, message, message_length  ; write(1, message, length)
```

---

## Function Calling Conventions

### System V AMD64 ABI
```asm
; Parameter passing:
; 1st: RDI
; 2nd: RSI
; 3rd: RDX
; 4th: RCX
; 5th: R8
; 6th: R9
; Additional: Stack (right to left)

; Return value: RAX (and RDX for 128-bit)

; Volatile registers: RAX, RCX, RDX, RSI, RDI, R8-R11
; Non-volatile: RBX, RBP, R12-R15

; Stack alignment: 16-byte before call

; Function prologue
my_function:
    push rbp
    mov rbp, rsp
    sub rsp, 32          ; Allocate stack space
    push rbx             ; Save non-volatile registers
    push r12
    push r13

; Function body
    ; ... code ...

; Function epilogue
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
```

### Optimized Function Prologues
```asm
; Leaf function (no calls)
leaf_function:
    ; No stack frame needed
    add rax, rdi
    ret

; Small stack frame
small_function:
    push rbp
    mov rbp, rsp
    ; ... code ...
    pop rbp
    ret

; Large stack frame with alignment
large_function:
    push rbp
    mov rbp, rsp
    and rsp, -16         ; Align stack to 16 bytes
    sub rsp, 64          ; Allocate space
    ; ... code ...
    mov rsp, rbp
    pop rbp
    ret
```

### Variable Argument Functions
```asm
; Using the red zone (128 bytes below RSP)
printf:
    ; Arguments in RDI, RSI, RDX, RCX, R8, R9
    ; Additional arguments at [RSP+8], [RSP+16], etc.

    mov rax, 0           ; Number of vector registers used
    ; ... implementation ...
    ret
```

---

## Advanced Control Flow

### Jump Tables
```asm
section .rodata
jump_table:
    dq case0
    dq case1
    dq case2
    dq case3

section .text
; Switch-like construct
cmp rax, 3
ja default
jmp [jump_table + rax*8]

case0:
    ; Handle case 0
    jmp end_switch

case1:
    ; Handle case 1
    jmp end_switch

; ... other cases ...

default:
    ; Handle default
end_switch:
```

### Exception Handling
```asm
; Set up exception handler
mov rax, [fs:0]          ; Get current exception handler
push rax                 ; Save old handler
lea rax, [rel exception_handler]
mov [fs:0], rax          ; Set new handler

; Code that might fault
try_block:
    mov rax, [rdi]       ; Might cause page fault
    jmp finally

exception_handler:
    ; Exception handling code
    mov rdi, [rsp+8]     ; Exception code
    ; ... handle exception ...
    mov rax, 0xFFFFFFFF  ; Continue execution
    iretq

finally:
    pop rax
    mov [fs:0], rax      ; Restore exception handler
```

### Coroutines & Fibers
```asm
; Context switching
switch_context:
    ; Save current context
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov [rdi], rsp       ; Save current stack pointer

    ; Load new context
    mov rsp, [rsi]       ; Load new stack pointer
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
```

---

## Floating Point & SIMD

### x87 Floating Point
```asm
; Basic operations
fld dword [x]           ; Load single precision
fld qword [y]           ; Load double precision
faddp st1, st0          ; Add and pop
fsubp st1, st0          ; Subtract and pop
fmulp st1, st0          ; Multiply and pop
fdivp st1, st0          ; Divide and pop

; Comparisons
fcomip st0, st1         ; Compare and set flags
fstsw ax                ; Store status word
sahf                    ; Store AH to flags

; Transcendental functions
fsin                    ; Sine
fcos                    ; Cosine
fsqrt                   ; Square root
fyl2x                   ; y * log2(x)
f2xm1                   ; 2^x - 1
```

### SSE/SSE2 Operations
```asm
; Data movement
movaps xmm0, [rax]      ; Aligned packed move
movups xmm0, [rax]      ; Unaligned packed move
movsd xmm0, [rax]       ; Move scalar double
movss xmm0, [rax]       ; Move scalar single

; Arithmetic
addps xmm0, xmm1        ; Packed single add
subps xmm0, xmm1        ; Packed single subtract
mulps xmm0, xmm1        ; Packed single multiply
divps xmm0, xmm1        ; Packed single divide

; Comparisons
cmpps xmm0, xmm1, 0     ; Equal
cmpps xmm0, xmm1, 1     ; Less than
cmpps xmm0, xmm1, 2     ; Less than or equal

; Conversions
cvtss2sd xmm0, xmm1     ; Convert single to double
cvtsd2ss xmm0, xmm1     ; Convert double to single
cvtsi2ss xmm0, eax      ; Convert integer to single
cvtss2si eax, xmm0      ; Convert single to integer
```

### AVX/AVX2 Operations
```asm
; 256-bit operations
vmovaps ymm0, [rax]     ; Move aligned 256-bit
vaddps ymm0, ymm1, ymm2 ; Packed single add
vmulps ymm0, ymm1, ymm2 ; Packed single multiply

; Fused multiply-add
vfmadd132ps ymm0, ymm1, ymm2 ; ymm0 = ymm0 * ymm2 + ymm1
vfmadd213ps ymm0, ymm1, ymm2 ; ymm0 = ymm1 * ymm0 + ymm2
vfmadd231ps ymm0, ymm1, ymm2 ; ymm0 = ymm1 * ymm2 + ymm0

; Gather operations
vgatherdpd ymm0, [rax + xmm1*8], ymm2 ; Gather packed double
```

### AVX-512 Operations
```asm
; Masked operations
vmovaps zmm0{k1}{z}, [rax] ; Zero-masked move
vaddps zmm0, zmm1, zmm2 ; 512-bit packed add

; Compression/expansion
vcompressps [rax]{k1}, zmm0 ; Store compressed
vexpandps zmm0{k1}{z}, [rax] ; Load expanded

; Conflict detection
vconflictd zmm0, zmm1   ; Detect conflicts
```

---

## Optimization Techniques

### Instruction Scheduling
```asm
; Avoid pipeline stalls
mov rax, [rbx]          ; Load from memory
add rcx, 10             ; Independent operation
add rax, rcx            ; Use loaded value

; vs. (worse)
mov rax, [rbx]          ; Load from memory
add rax, rcx            ; Stall waiting for load
add rcx, 10             ; Independent operation too late
```

### Loop Optimization
```asm
; Unroll loops
mov rcx, 1000/4         ; Process 4 elements per iteration
.loop:
    process_element
    process_element
    process_element
    process_element
    loop .loop

; Use induction variables
lea rax, [rbx + rcx*4]  ; Compute address once
mov rdx, [rax]          ; Use computed address
```

### Cache Optimization
```asm
; Prefetch data
prefetchnta [rax + 256] ; Prefetch into non-temporal cache
prefetcht0 [rax + 512]  ; Prefetch into all cache levels

; Non-temporal stores
movntdq [rax], xmm0     ; Bypass cache
sfence                  ; Ensure ordering

; Alignment
align 64                ; Cache line alignment
movaps xmm0, [rax]      ; Requires 16-byte alignment
```

### Branch Prediction
```asm
; Likely branches
cmp rax, 0
jne .unlikely           ; Forward jumps often not taken
; Likely code path

.unlikely:
; Unlikely code path

; Use CMOV instead of branches
cmp rax, rbx
cmovg rcx, rdx          ; Conditional move instead of branch
```

### Atomic Operations
```asm
; Lock prefix for atomicity
lock add [rbx], rax     ; Atomic add
lock xchg [rbx], rax    ; Atomic exchange

; Compare-and-swap loop
.spin:
    mov rax, [rbx]      ; Load current value
    mov rdx, rax
    add rdx, 1          ; Increment
    lock cmpxchg [rbx], rdx ; Attempt update
    jnz .spin           ; Retry if changed
```

---

## Debugging & Reverse Engineering

### Debugging Instructions
```asm
; Breakpoints
int3                    ; Software breakpoint

; Debug registers
mov dr0, rax            ; Set breakpoint address
mov rax, dr0            ; Read breakpoint address

; Performance monitoring
rdpmc                   ; Read performance counter
rdtsc                   ; Read time stamp counter

; CPU identification
cpuid                   ; Get CPU information
```

### GDB Commands for Assembly
```bash
# Basic debugging
gdb ./program
(gdb) break *0x400500          # Set breakpoint at address
(gdb) run                      # Start program
(gdb) ni                       # Next instruction
(gdb) si                       # Step into function
(gdb) info registers           # Show all registers
(gdb) x/10i $rip               # Disassemble 10 instructions
(gdb) x/8gx $rsp               # Examine stack as quadwords

# Advanced inspection
(gdb) set disassembly-flavor intel  # Intel syntax
(gdb) layout asm               # Assembly view
(gdb) watch *0x600000          # Watch memory location
(gdb) catch syscall write      # Catch system call

# Reverse engineering
(gdb) disas /r main            # Disassemble with raw bytes
(gdb) info proc mappings        # Show memory map
(gdb) maintenance info sections # Detailed section info
```

### Common Anti-Debug Techniques
```asm
; Check for debugger
mov eax, fs:[0x30]      ; PEB
movzx eax, byte [eax+2] ; BeingDebugged flag
test eax, eax
jnz debugger_detected

; Timing checks
rdtsc
mov [start_time], eax
; ... code being timed ...
rdtsc
sub eax, [start_time]
cmp eax, 1000000        ; If too long, probably debugged
ja debugger_detected

; INT 3 scan
mov esi, code_start
mov ecx, code_length
mov al, 0xCC            ; INT 3 opcode
repne scasb
jz debugger_detected
```

---

## Building & Toolchain

### Advanced NASM Directives
```asm
; Conditional assembly
%ifdef DEBUG
    %define DEBUG_CODE 1
    call debug_function
%else
    %define DEBUG_CODE 0
%endif

; Macros with parameters
%macro syscall 1-6
    %if %0 >= 2
        mov rdi, %2
    %endif
    ; ... more parameters ...
    mov rax, %1
    syscall
%endmacro

; Include files
%include "macros.inc"
%include "syscalls.inc"

; Custom sections
section .mysec progbits alloc exec write
    ; Custom section with all permissions
```

### Linker Script Basics
```ld
/* Custom linker script */
SECTIONS {
    . = 0x400000;       /* Load address */

    .text : {
        *(.text .text.*)
    }

    .rodata : {
        *(.rodata .rodata.*)
    }

    .data : {
        *(.data .data.*)
    }

    .bss : {
        *(.bss .bss.*)
    }

    /DISCARD/ : {
        *(.comment)
        *(.note.*)
    }
}
```

### Makefile for Assembly Projects
```makefile
# Assembly project Makefile
ASM = nasm
ASMFLAGS = -f elf64 -F dwarf -g
LDFLAGS = -nostdlib -static

SRCS = $(wildcard *.asm)
OBJS = $(SRCS:.asm=.o)
TARGET = program

.PHONY: all clean debug

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

clean:
	rm -f $(OBJS) $(TARGET)

debug: ASMFLAGS += -DDEBUG
debug: clean all
```

### Cross-Platform Building
```bash
# Build for different architectures
# x86-64
nasm -f elf64 program.asm -o program.o
ld -m elf_x86_64 -o program program.o

# i386
nasm -f elf32 program.asm -o program.o
ld -m elf_i386 -o program program.o

# Mach-O (macOS)
nasm -f macho64 program.asm -o program.o
ld -macosx_version_min 10.7 -o program program.o

# PE (Windows)
nasm -f win64 program.asm -o program.o
ld -o program.exe program.o
```

---

## Real-World Examples

### String Length Function
```asm
; Optimized strlen implementation
strlen:
    mov rax, -1          ; Start counter at -1
.loop:
    inc rax              ; Increment counter
    cmp byte [rdi + rax], 0 ; Check for null terminator
    jne .loop            ; Continue if not null
    ret                  ; Return length in RAX

; Even faster version using SSE
strlen_sse:
    pxor xmm0, xmm0      ; Zero xmm0
    mov rax, -16         ; Initialize offset
.loop:
    add rax, 16          ; Advance offset
    pcmpistri xmm0, [rdi + rax], 0x08 ; Equal any, unsigned bytes
    jnz .loop            ; Continue if no null found
    add rax, rcx         ; Add index of null
    ret
```

### Memory Copy Function
```asm
; Optimized memcpy
memcpy:
    mov rax, rdi         ; Save destination for return
    mov rcx, rdx         ; Copy length to counter
    shr rcx, 3           ; Convert to qword count
    rep movsq            ; Copy qwords
    mov rcx, rdx         ; Reload length
    and rcx, 7           ; Get remaining bytes
    rep movsb            ; Copy remaining bytes
    ret

; SSE version for aligned memory
memcpy_sse:
    test rdx, rdx        ; Check for zero length
    jz .done
    mov rax, rdi         ; Save destination
.loop:
    movdqu xmm0, [rsi]   ; Load 16 bytes
    movdqu [rdi], xmm0   ; Store 16 bytes
    add rsi, 16          ; Advance source
    add rdi, 16          ; Advance destination
    sub rdx, 16          ; Decrement count
    ja .loop             ; Continue if > 0
.done:
    ret
```

### CRC32 Calculation
```asm
; CRC32 implementation
crc32:
    mov eax, -1          ; Initial CRC value
    test rsi, rsi        ; Check if length is zero
    jz .done
.loop:
    crc32 eax, byte [rdi] ; Update CRC with next byte
    inc rdi              ; Advance pointer
    dec rsi              ; Decrement counter
    jnz .loop            ; Continue until done
.done:
    not eax              ; Final complement
    ret
```

### Base64 Encoding
```asm
; Base64 encode
base64_encode:
    mov r8, rdi          ; Input buffer
    mov r9, rsi          ; Input length
    mov r10, rdx         ; Output buffer
    mov r11, base64_table ; Translation table

    xor rcx, rcx         ; Input index
    xor rdx, rdx         ; Output index

.encode_loop:
    cmp rcx, r9          ; Check if done
    jge .done

    ; Read three bytes
    mov eax, [r8 + rcx]  ; Read up to 4 bytes (we use 3)
    add rcx, 3           ; Advance input index

    ; Convert to base64
    mov edi, eax         ; Save original
    shr eax, 2           ; First 6 bits
    and eax, 0x3F        ; Mask to 6 bits
    mov al, [r11 + rax]  ; Lookup in table
    mov [r10 + rdx], al  ; Store first character
    inc rdx

    ; Second character
    mov eax, edi         ; Reload original
    shr eax, 4           ; Next 6 bits (need to shift differently)
    ; ... continued ...

.done:
    mov byte [r10 + rdx], 0 ; Null terminate
    ret

section .rodata
base64_table:
    db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
```


