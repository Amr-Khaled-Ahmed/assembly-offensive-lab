# 03-simple-debugger-tracer — README.md

A small educational **x86_64 NASM** tracer/debugger implemented in assembly for Linux.
This project demonstrates the core tracer flow using `ptrace` from assembly:

* child: `ptrace(PTRACE_TRACEME)` → `execve(target, argv, NULL)`
* parent: `wait` → `PTRACE_GETREGS` → place `INT3` (breakpoint) at entry `RIP` using `PTRACE_PEEKTEXT`/`PTRACE_POKETEXT` → `PTRACE_CONT` → on trap restore original byte → `PTRACE_SINGLESTEP` → `PTRACE_CONT` until exit

> Educational — intentionally compact and not production-grade. Useful to learn syscall-level debugger primitives.

---

## Files

* `03-simple-debugger-tracer.asm` — NASM x86_64 assembly tracer implementation.
* (optional) `target` — any small test program (e.g., the `target_program.c` from examples).
* `README.md` — this file.

---

## Requirements

* Linux x86_64 (WSL works)
* `nasm` (Netwide Assembler)
* `ld` (GNU linker)
* `gcc` (if you want to build a `target` from C for testing)

Install on Debian/Ubuntu:

```bash
sudo apt update
sudo apt install nasm build-essential
```

---

## Build

Assemble and link the tracer:

```bash
nasm -felf64 03-simple-debugger-tracer.asm -o 03-simple-debugger-tracer.o
ld 03-simple-debugger-tracer.o -o tracer
```

(Optional) build a small C `target` for testing:

```c
// save as target_program.c
#include <stdio.h>
#include <unistd.h>
int main(void) {
    printf("[target] started. pid=%d\n", getpid());
    for (int i = 0; i < 5; ++i) {
        printf("[target] loop %d\n", i);
        sleep(1);
    }
    printf("[target] finished.\n");
    return 0;
}
```

Compile the `target`:

```bash
gcc -Wall -O2 target_program.c -o target
```

---

## Usage

Run the tracer with a target program path:

```bash
./tracer ./target
```

If you omit the target argument, the tracer uses `./target` by default.

---

## What to expect (high-level)

1. The tracer forks.
2. The child sets `PTRACE_TRACEME` and `execve`s the target.
3. The parent waits for the child to stop after execve.
4. The parent reads the child registers to obtain `RIP`.
5. The parent reads the 8-byte word at `RIP` via `PTRACE_PEEKTEXT`.
6. The parent writes an `INT3` byte (`0xCC`) into that word (`PTRACE_POKETEXT`) to set a breakpoint.
7. The parent continues the child (`PTRACE_CONT`). When the child hits the `INT3`, it stops with `SIGTRAP`.
8. The parent restores the original word, sets `RIP` back to the breakpoint address (so the original instruction will execute), single-steps the instruction (`PTRACE_SINGLESTEP`), then continues the child normally (`PTRACE_CONT`).
9. The tracer waits until the child exits and prints a final message.

---

## Important notes & caveats

* **Offset assumption:** The assembly reads `RIP` from a byte offset inside a local `regs_buf` (the code uses offset `128` for `rip`). This assumption comes from the common layout of `struct user_regs_struct` on x86_64 kernels, but it is brittle. If you port the code to a different kernel/build, you must verify the offsets or provide a correct `struct` layout.
* **PEEKTEXT/POKETEXT operate on word-size (8 bytes)** — the code modifies the low byte of that word to `0xCC`. This is normal for placing `INT3` breakpoints but be careful when restoring.
* **wait/status parsing is simplified.** The example uses basic `wait4` calls and does not fully implement complete parsing of `status` (WIFSTOPPED/WIFEXITED/WTERMSIG). For robust behavior add proper status checks.
* **Permissions:** You can trace only processes you own. Tracing another user's processes or system processes may require additional privileges.
* **Not a full debugger:** This tracer demonstrates core mechanics (breakpoint, restore, singlestep). It does not implement source-level mapping, multiple breakpoints, robust signal handling, or syscall tracing.

---

## Extensions / improvements you might add

* Parse ELF of the target to place breakpoints at `main` or symbol addresses (instead of the immediate `RIP` value).
* Implement full `wait`/`status` parsing and handle signals properly (relay signals to child).
* Support multiple breakpoints and maintain a breakpoint table.
* Implement `PTRACE_SYSCALL` mode to monitor system calls.
* Replace the fragile `regs_buf` offset approach by using a correct `struct user_regs_struct` layout (or call into a small C shim).
* Add CLI options: specify breakpoint addresses, verbose logging, save/restore registers.

---

## Example session (expected approximate output)

```
$ ./tracer ./target
[tracer] child stopped after execve, placing bp at RIP
[tracer] RIP = 0x00400f50
[tracer] original word = 0x55f4b8d0...
[tracer] breakpoint hit. restoring and single-stepping...
[tracer] child exited with code 0
```

(Actual hex values and textual output vary by target and environment.)

---

## Safety & license

* Educational use only. Do not use for unauthorized debugging or intrusion.
* No warranty. Use at your own risk.
* You may reuse and modify for learning and experimentation.

