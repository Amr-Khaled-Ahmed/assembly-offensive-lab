
# 02-custom-loader

A tiny x86_64 Linux (WSL-friendly) assembly "custom loader" that writes and executes a small payload script.
Playful, educational, and heavily commented — made to demonstrate basic syscalls, file I/O, fork/exec, UID check, and minimal privilege-aware behavior.

---

## Overview

`02-custom-loader.asm` does the following:

* Creates `/tmp/02_payload.sh` with a short animated greeting script.
* Sets the payload file to be executable.
* Forks and `execve`'s the payload; the parent waits for the child to finish.
* If executed as root (`UID == 0`), it additionally writes a friendly message to `/etc/motd`.
  **This last action runs only when the loader detects root privileges.**

The loader is intentionally simple and well-commented so you can read, learn, and modify it.

---

## Safety warning

* By default the program only writes to `/tmp/02_payload.sh` and executes it — **harmless** for ordinary usage.
* **Do not run as root** unless you understand and accept that `/etc/motd` will be overwritten. The MOTD-write only happens when UID==0.
* Always inspect the payload contents before running anything with elevated privileges.

---

## Requirements

* Linux x86_64 (WSL works fine)
* `nasm` (Netwide Assembler)
* `ld` (GNU linker)
* A shell environment to run the generated executable

Install on Debian/Ubuntu if needed:

```bash
sudo apt update
sudo apt install nasm build-essential
```

---

## Build

Assemble and link with these commands:

```bash
nasm -felf64 02-custom-loader.asm -o 02-custom-loader.o
ld 02-custom-loader.o -o 02-custom-loader
```

You will get a runnable binary `02-custom-loader`.

---

## Run

Run as your normal user (safe):

```bash
./02-custom-loader
```

If you purposely want to test the root-only behavior (be careful):

```bash
sudo ./02-custom-loader
```

That will attempt to write to `/etc/motd`.

---

## Expected behavior / sample output

When run as a normal user you should see the payload's output (approximate):

```
(•_•) Loading custom payload...
....
Surprise! I'm the payload — executed by 02-custom-loader.
Here's a tiny fortune: "Keep hacking (ethically) and learning!"
[loader] payload finished. Have a nice day! (./02-custom-loader)
```

If the loader cannot create `/tmp/02_payload.sh`, it prints an error to stderr:

```
[loader] failed to create payload in /tmp. Exiting.
```

If run as `root`, `/etc/motd` will be replaced by:

```
Welcome! This system was greeted by 02-custom-loader.
```

---

## What the code demonstrates

* Low-level Linux syscalls (open, write, close, chmod, fork, execve, wait4, getuid, exit).
* How to embed static text/data directly in assembly and write it to a file.
* How to conditionally perform privileged actions based on UID.
* Basic process control (fork/exec and parent wait).

---

## File layout

* `02-custom-loader.asm` — the assembly source (single-file).

  * `.data` contains embedded paths and the payload script text.
  * `.text` contains syscall helper stubs and `_start`.
  * `.rodata` contains messages for terminal output.
* `02-custom-loader` — output binary after build.

---

## Modify ideas

* Replace the shell payload with a small compiled ELF binary (embed raw bytes and `mmap`+`mprotect` to execute in-memory).
* Make the loader produce the payload in a user-specified path.
* Add checksum validation before executing the payload.
* Replace the playful payload with a harmless system-information script (e.g., prints uname, uptime).
* Change the privileged action to append (not overwrite) `/etc/motd` and include a timestamp.

---
