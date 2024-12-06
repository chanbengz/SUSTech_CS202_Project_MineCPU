<div align=center>

# SUSTech CS202 Project: MineCPU

RISC-V Von Neumann Architecture with 5-Stage Pipeline, Branch Predictor, L1 Cache and UART

:book: Language: <a href="https://github.com/chanbengz/SUSTech_CS202_Project_MineCPU/blob/main/README.md">English</a> • <a href="https://github.com/chanbengz/SUSTech_CS202_Project_MineCPU/blob/main/README.zh.md">中文</a> 

**HAVE FUN ! :satisfied:**

<div align="center">
    <img src="./docs/pic/pacman1.png" alt="" width="550">
</div>

</div>

## Structure

```
.
├── docs
│   ├── pic                     # pictures used
│   ├── Architecture.drawio     # design draft
│   ├── project_desciption.pdf  # project description
│   ├── Report.md               # report of this project
│   └── riscv-card.pdf          # ISA reference
├── generated
│   └── *.bit                   # bitstream file with different configurations
├── program
│   ├── lib                     # library of hardware API (driver)
│   ├── pacman                  # game by C++ (easier cross-compiling to RV)
│   └── testcase                # used for project presentation
├── sources
│   ├── assembly
│   │   ├── *.asm               # assembly code for test and fun
│   │   ├── *.coe               # hex version of machine code
│   │   └── *.txt               # data using UART to be put into memory            
│   ├── constrain
│   │   └── constr.xdc          # constrain file
│   ├── core
│   │   ├── *.sv                # code of CPU core
│   │   └── *.svh               # head file for constant
│   ├── io
│   │   └── *.sv                # code related to IO and Clock
│   ├── sim
│   │   ├── *.cpp               # verilator simulation
│   │   └── *.sv                # vivado simulation
│   └── Top.sv                  # top module of MineCPU
├── test
│   ├── DiffTest.cpp            # differential test of CPU
│   ├── *.sv                    # on-board-test code
│   └── *.xdc                   # on-board-test constrain
├── tools
│   ├── inst2txt.py             # instruction to text file for UART
│   ├── ecall2sv.py             # coe to code for burning into ROM
│   └── UARTAssist.exe          # tool for UART
├── .gitignore
├── LICENSE
└── README.md
```

## Features

_* indicates bonus function_

- [x] Core
  - [x] IF Stage
    - [x] Branch Prediction *
      - [x] Pre-Decode *
      - [x] Branch History Table, BHT *
      - [x] Return Address Stack, RAS *
    - [x] Instruction Cache *
      - [x] Direct Mapping *
      - [ ] Pre-Fetch *
  - [x] ID Stage
    - [x] Immediate Generation
    - [x] Register File
    - [x] Control Unit
    - [x] Hazard Detection
  - [x] EX Stage
    - [x] ALU
      - [x] RV32I
      - [x] RV32M *
    - [x] BRU
    - [x] Forward Unit *
  - [x] MEM Stage
    - [x] Byte / Halfword / Word Memory Access
    - [x] Data Cache *
      - [x] Direct Mapping *
      - [x] Write Back *
  - [x] WB Stage
  - [x] Memory
    - [x] BRAM
    - [x] MMIO
    - [x] ROM
  - [x] ecall & sret *
- [x] IO
  - [x] Switch & Button
  - [x] 4*4 Builtin Keyboard *
  - [x] Led & 7 Segment Display
  - [x] UART *
  - [x] VGA *
- [x] Software
  - [x] Testcase #1
  - [x] Testcase #2
  - [x] Pacman *

## Architecture

![Architecture](./docs/pic/architecture.png)
Powered by [draw.io](https://app.diagrams.net/)


## Specification

### Hardware

- **Von Neumann Architecture**, **RISC-V** ISA RV32IM support, **5 Stage Pipeline**，IPC ~0.95
- 32-bit Register
- Memory Space 32 bit (4 byte)
- **Clock:** 
  + CPU: Maximum 50MHz
  + MEM: Share with CPU
  + VGA: 40MHz
- **Branch Predictor**:
  + BHT: 32 entries, 2 bits
  + RAS: 32 entries, 32 bits
- **Cache**:
  + ICache: Direct Mapping, 1472 bits, 32 entries
  + DCache: Direct Mapping/Write Back, 1504 bits, 32 entries
- **Trap**:
  + ecall: internally triggered to access MMIO, see [Environment Call](#environment-call) for detail


### ISA

Supports RV32IM ISA

| Instruction            | Type     | Operation                                 |
| ---------------------- | -------- | ----------------------------------------- |
| `add rd, rs1, rs2`     | R        | rd = rs1 + rs2                            |
| `sub rd, rs1, rs2`     | R        | rd = rs1 - rs2                            |
| `xor rd, rs1, rs2`     | R        | rd = rs1 ^ rs2                            |
| `or rd, rs1, rs2`      | R        | rd = rs1 \| rs2                           |
| `and rd, rs1, rs2`     | R        | rd = rs1 & rs2                            |
| `sll rd, rs1, rs2`     | R        | rd = rs1 << rs2                           |
| `srl rd, rs1, rs2`     | R        | rd = rs1 >> rs2                           |
| `sra rd, rs1, rs2`     | R        | rd = rs1 >> rs2 (sign-extend)             |
| `slt rd, rs1, rs2`     | R        | rd = ( rs1 < rs2 ) ? 1 : 0                |
| `sltu rd, rs1, rs2`    | R        | rd = ( (u)rs1 < (u)rs2 ) ? 1 : 0          |
| `addi rd, rs1, rs2`    | I        | rd = rs1 + imm                            |
| `xori rd, rs1, rs2`    | I        | rd = rs1 ^ imm                            |
| `ori rd, rs1, rs2`     | I        | rd = rs1 \| imm                           |
| `andi rd, rs1, rs2`    | I        | rd = rs1 & imm                            |
| `slli rd, rs1, rs2`    | I        | rd = rs1 << imm[4:0]                      |
| `srli rd, rs1, rs2`    | I        | rd = rs1 >> imm[4:0]                      |
| `srai rd, rs1, rs2`    | I        | rd = rs1 >> imm[4:0] (sign-extend)        |
| `slti rd, rs1, rs2`    | I        | rd = (rs1 < imm) ? 1 : 0                  |
| `sltiu rd, rs1, rs2`   | I        | rd = ( (u)rs1 < (u)imm ) ? 1 : 0          |
| `lb rd, imm(rs1)`      | I        | Read 1 byte and sign-extend               |
| `lh rd, imm(rs1)`      | I        | Read 1 half-word (2 bytes) and sign-extend|
| `lw rd, imm(rs1)`      | I        | Read 1 word (4 bytes)                     |
| `lbu rd, imm(rs1)`     | I        | Read 1 byte and zero-extend               |
| `lhu rd, imm(rs1)`     | I        | Read 2 byte and zero-extend               |
| `sb rd, imm(rs1)`      | S        | Store 1 byte                              |
| `sh rd, imm(rs1)`      | S        | Store 1 half-word (2 bytes)               |
| `sw rd, imm(rs1)`      | S        | Store 1 word (4 bytes)                    |
| `beq rs1, rs2, label`  | B        | if (rs1 == rs2)  PC += (imm << 1)         |
| `bne rs1, rs2, label`  | B        | if (rs1 != rs2)  PC += (imm << 1)         |
| `blt rs1, rs2, label`  | B        | if (rs1 < rs2)  PC += (imm << 1)          |
| `bge rs1, rs2, label`  | B        | if (rs1 >= rs2)  PC += (imm << 1)         |
| `bltu rs1, rs2, label` | B        | if ( (u)rs1 < (u)rs2 )  PC += (imm << 1)  |
| `bgeu rs1, rs2, label` | B        | if ( (u)rs1 >= (u)rs2 )  PC += (imm << 1) |
| `jal rd, label`        | J        | rd = PC + 4; PC += (imm << 1)             |
| `jalr rd, rs1, imm`    | I        | rd = PC + 4; PC = rs1 + imm               |
| `lui rd, imm`          | U        | rd = imm << 12                            |
| `auipc rd, imm`        | U        | rd = PC + (imm << 12)                     |
| `ecall`                | I        | Transfer control to firmware (ROM)        |
| `sret` *               | I        | Transfer back to user program             |
| `mul rd, rs1, rs2` *   | R        | rd = (rs1 * rs2)[31:0]                    |
| `mulh rd, rs1, rs2` *  | R        | rd = (rs1 * rs2)[63:32]                   |
| `mulhsu rd, rs1, rs2` *| R        | rd = (rs1 * (u)rs2)[63:32]                |
| `mulhu rd, rs1, rs2` * | R        | rd = ( (u)rs1 * (u)rs2 )[63:32]           |
| `div rd, rs1, rs2` *   | R        | rd = rs1 / rs2                            |
| `rem rd, rs1, rs2` *   | R        | rd = rs1 % rs2                            |

### Environment Call

| No. (a7) | Arguments | Operation | Return Value |
| :----| --- | ---------------------- | ----- |
| 0x01 | a0  | Write 1 byte to LED #1 | N/A |
| 0x02 | a0  | Write 1 byte to LED #2 | N/A |
| 0x03 | a0  | Write 4 bytes to 7Seg  | N/A |
| 0x05 | N/A | Read 1 byte from switch #1 | a0 |
| 0x06 | N/A | Read 1 byte from switch #2 | a0 |
| 0x07 | N/A | Read 1 byte from switch #3 | a0 |
| 0x0A | N/A | End of program (Idle loop) | N/A |

### IO

- **MMIO** (Memory Mapping IO) to perform IO and supports UART
- UART
  - Burn program and data into memory through UART without reprogramming FPGA
  - **Baud Rate:** 115200Hz, 8 data bits, 1 stop bits
  - Data directly written into memory, CPU will start after receiving data and being idle for more than 0.5s
- Input
  - 24 switches
  - 5 buttons
  - 4 × 4 builtin keyboard
- Output
  - 24 LEDs, 8 of which shows CPU status
  - 7 segment display to print 4 Bytes
  - VGA
    - buffers with builtin fonts and colors
    - 800×600 60Hz
    - font: 8×16, 96×32 fullscreen with ratio 3 : 2

<div align="center">
    <img src="./docs/pic/VGA.png" alt="" width="600">
</div>

**MMIO Address** 

| Address    | R/W   | Note              | Range       |
| :--------- | ----- | ----------------- | ----------- |
| 0xFFFFFF00 | R     | Switch #1 (8)     | 0x00 - 0xFF |
| 0xFFFFFF04 | R     | Switch #2 (8)     | 0x00 - 0xFF |
| 0xFFFFFF08 | R     | Switch #3 (8)     | 0x00 - 0xFF |
| 0xFFFFFF0C | W     | LED #1 (8)        | 0x00 - 0xFF |
| 0xFFFFFF10 | W     | LED #2 (8)        | 0x00 - 0xFF |
| 0xFFFFFF14 | R     | Button 1 (Center) | 0x00 - 0x01 |
| 0xFFFFFF18 | R     | Button 2 (Up)     | 0x00 - 0x01 |
| 0xFFFFFF1C | R     | Button 3 (Down)   | 0x00 - 0x01 |
| 0xFFFFFF20 | R     | Button 4 (Left)   | 0x00 - 0x01 |
| 0xFFFFFF24 | R     | Button 5 (Right)  | 0x00 - 0x01 |
| 0xFFFFFF28 | W     | 7 Segment Display | 0x00000000 - 0xFFFFFFFF |
| 0xFFFFFF2C | R     | 4*4 Keyboard Status | 0x00 - 0x01 |
| 0xFFFFFF30 | R     | 4*4 Keyboard Location| 0x00 - 0x0F |
| 0xFFFFE___ (000-BFF) | W | VGA Font | 0x00 - 0xFF |
| 0xFFFFD___ (000-BFF) | W | VGA Color | 0x00 - 0xFF |

### Pacman

A little game in [assembly](./program/pacman/pacman.asm)，as a showcase of the capability of MineCPU.

<div align="center">
    <img src="./docs/pic/pacman2.png" alt="" height="250">
    <img src="./docs/pic/pacman3.png" alt="" height="250">
</div>

## Usage

### Generate Bitstream

 1. **Create Vivado Project**：Project device **xc7a100tfgg484-1**，Target Language: `System Verilog`，import all codes in [sources](./sources), [sources/core](./sources/core) and [sources/io](./sources/io)，and then import `constr.xdc` from [sources/constrain](./sources/constrain).

 2. **Create IP** 
    - Create Clocking Wizard
      - Rename to `VGAClkGen`
      - Select PLL Clock
      - Modify `clk_in1: Source` to Global buffer
      - Set frequency of `clk_out1` to 40MHz and uncheck reset and locked signal

      <div align="center">
          <img src="./docs/pic/ip1.png" alt="" width="370">
          <img src="./docs/pic/ip2.png" alt="" width="370">
      </div>

      <div align="center">
          <img src="./docs/pic/ip3.png" alt="" width="370">
          <img src="./docs/pic/ip4.png" alt="" width="370">
      </div>

    - Create Block Memory Generator

      - Name it to `Mem`
      - Select `True Dual Port RAM` as Memory Type
      - Modify Write Width of Port A to 32，Write Depth to 16384 (Read Width, Read Depth and Port B will also be changed automatically)

      <div align="center">
          <img src="./docs/pic/ip5.png" alt="" width="370">
          <img src="./docs/pic/ip6.png" alt="" width="370">
      </div>

 3. Execute **Synthesis -> Implementation -> Generate Bitstream**，to generate bitstream (*.bit) 
 4. Alternatively, use pre-[generated](./generated) bitstream to program FPGA


### Compile Bare-Metal Program

**Compile source codes to bin**：open sources with `RARS`，execute it and click `File -> Dump Memory`，select `Hexadecimal Text` in `Dump Format`，click `Dump To File...`

<div align="center">
    <img src="./docs/pic/rars1.png" alt="" height="220">
    <img src="./docs/pic/rars2.png" alt="" height="220">
</div>

Alternatively, cross-compiling C++ code to RISC-V assembly code and then to binary

```bash
riscv64-unknown-elf-g++ -march=rv32im -mabi=ilp32 --static your-program.c -o your-program
riscv64-unknown-elf-objcopy -O binary your-program your-program.bin
hexdump -v -e '1/4 "%08x" "\n"' your-program.bin > your-program.txt
```

Then convert hex to txt with [inst2txt.py](./tools/inst2txt.py), simply change the path inside script and run `python inst2txt.py`

### Load and Run Program

Open [UARTAssist.exe](./tools/UartAssist.exe)，select COM6 and baud rate as 115200, open connection and send by hex with the text file generated above.

<div align="center">
    <img src="./docs/pic/uart1.png" alt="" width="400">
</div>

Or if you're using Linux/Mac, you can use `minicom`. You know how to do it.

## Development

+ Program: [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) cross compiler
+ Simulation: [Verilator](https://verilator.org/guide/latest/overview.html), [Unicorn](https://github.com/unicorn-engine/unicorn) for simulation of instruction in differential test
+ Serial: [UARTAssist](./tools/UartAssist.exe) serial tool, [inst2txt](./tools/inst2txt.py) to translate the binary to hex
