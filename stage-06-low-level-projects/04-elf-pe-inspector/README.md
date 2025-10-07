# 04-elf-pe-inspector — README.md

A small **learning tool** (x86_64 NASM) that reads the first bytes of a file and identifies whether it is an **ELF** (Linux/Unix executable) or a **PE/MZ** (Windows Portable Executable) file, then prints a few important header fields.
This repository and README are designed **as an educational guide** — you’ll learn what the tool checks and what the printed fields mean.

---

## Table of contents

* Overview
* Quick start (build & run)
* What the tool prints

  * ELF: brief anatomy & fields shown
  * PE (MZ): brief anatomy & fields shown
* Examples (expected output)
* Limitations & caveats

---

## Overview

This program (`04-elf-pe-inspector.asm`) is a minimal, syscall-only inspector written in NASM x86_64. It:

* opens a file,
* reads up to the first 4096 bytes,
* checks for ELF magic (`0x7F 'E' 'L' 'F'`) or DOS MZ (`'M' 'Z'`),
* if ELF: prints class (32/64), endianness, `e_type`, `e_machine`, `e_entry`, `e_phoff`, `e_shoff`,
* if PE: finds `e_lfanew`, validates `PE\0\0`, prints COFF fields `Machine`, `NumberOfSections`, `TimeDateStamp`, and Optional Header values `AddressOfEntryPoint` and `ImageBase` (supports PE32 and PE32+).

This is intentionally compact and educational — it focuses on reading header fields and showing them in hex/decimal so you can learn how headers look on disk.

---

## Quick start (build & run)

Requirements:

* Linux x86_64 (WSL is fine)
* `nasm` and `ld`

Build:

```bash
nasm -felf64 04-elf-pe-inspector.asm -o 04-elf-pe-inspector.o
ld 04-elf-pe-inspector.o -o elf_pe_inspector
```

Run:

```bash
./elf_pe_inspector /path/to/binary
# Example: ./elf_pe_inspector ./target
```

If you run without an argument the program prints usage and exits.

---

## What the tool prints — learning guide

Below is an explanation of the headers and the specific fields the inspector prints. After each short explanation you’ll see why the field matters.

### ELF (Executable and Linkable Format)

ELF is the standard executable format on Linux/Unix. The first 16 bytes are `e_ident` and include the magic and metadata.

Fields shown by this tool:

* **ELF class** (`e_ident[EI_CLASS]`): shows whether the file is ELF32 (32-bit) or ELF64 (64-bit).

  * Why: determines field sizes and offsets in the ELF header and program/section headers.
* **Endianness** (`e_ident[EI_DATA]`): little or big endian.

  * Why: determines byte-order when interpreting multi-byte fields.
* **e_type** (16-bit): object file type (ET_EXEC, ET_DYN, ET_REL, ET_CORE).

  * Why: indicates whether file is executable, shared object, relocatable, etc.
* **e_machine** (16-bit): CPU architecture (e.g., x86_64 = EM_X86_64).

  * Why: tells which CPU the binary targets.
* **e_entry**: program entry point virtual address (32-bit for ELF32, 64-bit for ELF64).

  * Why: where execution begins.
* **e_phoff**: offset in file to the Program Header Table.

  * Why: program headers describe runtime segments (what to load into memory).
* **e_shoff**: offset in file to the Section Header Table.

  * Why: section headers describe link-time sections (useful for static analysis).

> The tool prints these values in hex (addresses) and some numeric fields in decimal where meaningful.

### PE / MZ (Portable Executable, Windows)

Windows PE files start with a DOS stub (`MZ`) and contain a pointer (`e_lfanew`) to the PE header.

Fields shown by this tool:

* **MZ header check**: confirms the file starts with `'M' 'Z'`. If present, the tool reads `e_lfanew`.
* **e_lfanew** (DWORD at offset 0x3C): file offset to the PE header (`"PE\0\0"`).

  * Why: locate the PE header.
* **PE signature**: expects `"PE\0\0"` at `e_lfanew`.
* **COFF File Header**:

  * **Machine** (WORD): CPU architecture (e.g., 0x14c = x86, 0x8664 = x86_64).
  * **NumberOfSections** (WORD): number of section table entries.
  * **TimeDateStamp** (DWORD): linker timestamp (UNIX epoch-based integer).
* **Optional Header** (PE32 or PE32+):

  * **AddressOfEntryPoint**: RVA of the entry point (relative virtual address).
  * **ImageBase**: preferred load base address (32-bit in PE32 or 64-bit in PE32+).

> These PE fields help you determine where the program will start at runtime and basic layout metadata.

---

## Examples (approximate expected output)

### ELF example (64-bit):

```
[info] detected: ELF file
  ELF class: ELF64
  Type: 0x0002
  Machine: 0x003e
  Entry point: 0x0000000000400f50
  Program header offset: 0x0000000000000040
  Section header offset: 0x0000000000040000
```

### PE example:

```
[info] detected: PE (MZ) file
  e_lfanew (PE header offset): 0x00000200
  COFF Machine: 0x8664
  NumberOfSections: 5
  TimeDateStamp: 0x5f2a3b80
  AddressOfEntryPoint: 0x00001000
  ImageBase: 0x0000000140000000
```

---

## Limitations & caveats (important learning points)

* **We read at most 4096 bytes.** Some files may store important headers/payloads beyond that; increase the read size if necessary.
* **Endian & layout assumptions.** The code assumes typical layouts and little-endian ordering for values (x86/x86_64 common). If you run on a big-endian system the parsing would need to account for it.
* **ELF `user_regs_struct`/C structs not used.** This is raw byte parsing — offsets are hard-coded to standard ELF/PE layouts. If a platform has different headers, validate offsets.
* **No full validation.** The tool performs elementary checks and prints fields, but it does not validate the entire format or sanity-check all numeric values.
* **Not a substitute for full parsers.** For heavy-duty analysis, use `readelf`, `objdump`, `file`, or libraries (libelf, pefile). This tool is for learning and experimenting with raw bytes and syscalls in assembly.

---

## Learning next steps & extensions

If you want to turn this into a deeper learning project, consider:

* **Pretty-printing symbolic names** (e.g., map `e_type` values to `ET_EXEC`, `ET_DYN`, etc., map `e_machine` to CPU names).
* **Parse section/program headers** by reading offsets `e_phoff`/`e_shoff` and printing each entry.
* **Full PE parsing**: read section table, show section names, virtual sizes, and imports/exports.
* **Endian-independent parsing**: add explicit endianness handling using `e_ident[EI_DATA]`.
* **Larger reads & streaming parsing**: `mmap` the file (or read more bytes) to handle headers located further in the file.
* **Build a tiny C helper** that exposes well-defined data structures while keeping the inspector in assembly (hybrid approach for safety).
* **Add unit tests / known-binaries dataset** to validate parsing correctness across many real binaries.

---
