## stage-01-getting-started - 01-registers-memory
# Toolchain Setup

## Linux (x86_64)
- Install NASM and LD:
  sudo apt install nasm build-essential -y

- Build and run:
  nasm -f elf64 regs.asm -o regs.o
  ld regs.o -o regs
  ./regs

