## stage-06-low-level-projects - 02-custom-loader
---

# Custom Loader (x86 Bootloader Demo)

This project is a **simple custom loader** written in **x86 Assembly (16-bit)**.
It runs as a real **boot sector** and performs something useful:
It reads **sector 2** of the boot disk (the first sector after the boot sector), loads it into memory, and then displays the first 128 bytes on screen as **hex + ASCII**.

---

## Features

* Boots directly under BIOS.
* Uses `INT 13h` to read a disk sector.
* Loads data into memory at `0x1000:0x0000`.
* Prints the data to screen in both hex and ASCII with line breaks.
* Includes simple error handling if the disk read fails.

---

## How It Works

1. BIOS loads the boot sector at `0x7C00`.
2. The loader sets up basic registers and stack.
3. It calls `INT 13h` to read sector 2 from the boot disk.
4. The loaded data is displayed using `INT 10h` teletype printing.
5. The loader halts (`jmp $`) after showing the data.

---

## Possible Extensions

* Read multiple sectors (a second-stage loader).
* Parse a filesystem (e.g., FAT12).
* Load and execute an ELF kernel.

---
