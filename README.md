<div align=center>

# SUSTech CS202 Course Project: MineCPU

南方科技大学 2024 年春季 `CS202 计算机组成原理` 的课程 Project RISC-V CPU（标准五级流水线版）

</div>

## 小组成员及分工

| 成员 | CPU核心 | IO | 仿真 & 测试 | 汇编 & 应用 | 报告 |
| --- | --- | --- | --- | --- | --- |
| [@wLUOw](https://github.com/wLUOw) | :heavy_check_mark: |  | :heavy_check_mark: |  |  |
| [@Yao1OoO](https://github.com/Yao1OoO) |  | :heavy_check_mark: |  | :heavy_check_mark: |  |
| [@chanbengz](https://github.com/chanbengz) | :heavy_check_mark: |  | :heavy_check_mark: |  |  |



## 项目结构

```
MineCPU
├── docs
│   ├── CPU.*                  # design draft
│   ├── Report.md              # report of this project
│   ├── cpu_design.pdf         # CPU design from textbook
│   └── riscv-card.pdf         # ISA reference
├── program
│   ├── lib                    # library of some API
│   └── list.md                # maybe useful
├── sources                                              
│   ├── assembly               # assembly program for test and fun
│   │   ├── *.asm              
│   │   └── *.coe             
│   ├── constrain
│   │   └── constr.xdc         # constrain file
│   ├── core
│   │   └── *.sv               # code of CPU core
│   ├── io
│   │   └── *.sv               # code related to IO
│   ├── sim
│   │   ├── *.cpp              # verilator simulation
│   │   └── *.sv               # vivado simulation
│   └── Top.sv                 # top module of MineCPU
├── test
│   └── DiffTest.cpp           # differential test of CPU
├── .gitignore
├── LICENSE
└── README.md
```



## 完成列表

- [x] CPU 核心
  - [x] IF Stage
  - [x] ID Stage
    - [x] 立即数生成模块
    - [x] 寄存器模块
    - [x] 控制模块
    - [x] 数据冒险停顿模块
    - [x] 分支预测模块
  - [x] EX Stage
    - [x] ALU
      - [x] RV32I
      - [ ] RV32M *
    - [x] BRU
    - [x] 前递模块
  - [x] MEM Stage
  - [x] WB Stage
  - [x] Memory
    - [ ] Cache *
    - [ ] UART *
  - [x] 异常控制 *
- [ ] IO
  - [ ] 拨码开关 & 按钮
  - [ ] Led & 7 段数码管
  - [ ] VGA *
- [ ] 软件
  - [ ] 测试场景1
  - [ ] 测试场景2
  - [ ] Pac-Man *



## 功能

### CPU

- **冯诺依曼架构**支持 **RISC-V** 指令集的**五级流水线** CPU
- 时钟频率：

### ISA

RISC-V 基本指令集 (RV32I) 及乘除法拓展 (RV32M)

| 指令                   | 指令类型 | 执行操作                                  |
| ---------------------- | -------- | ----------------------------------------- |
| `add rd, rs1, rs2`     | R        | rd = rs1 + rs2                            |
| `sub rd, rs1, rs2`     | R        | rd = rs1 - rs2                            |
| `xor rd, rs1, rs2`     | R        | rd = rs1 ^ rs2                            |
| `or rd, rs1, rs2`      | R        | rd = rs1 \| rs2                           |
| `and rd, rs1, rs2`     | R        | rd = rs1 & rs2                            |
| `sll rd, rs1, rs2`     | R        | rd = rs1 « rs2                            |
| `srl rd, rs1, rs2`     | R        | rd = rs1 » rs2                            |
| `sra rd, rs1, rs2`     | R        | rd = rs1 » rs2 (Arith*)                   |
| `slt rd, rs1, rs2`     | R        | rd = ( rs1 < rs2 ) ? 1 : 0                |
| `sltu rd, rs1, rs2`    | R        | rd = ( (u)rs1 < (u)rs2 ) ? 1 : 0          |
| `addi rd, rs1, rs2`    | I        | rd = rs1 + imm                            |
| `xori rd, rs1, rs2`    | I        | rd = rs1 ^ imm                            |
| `ori rd, rs1, rs2`     | I        | rd = rs1 \| imm                           |
| `andi rd, rs1, rs2`    | I        | rd = rs1 & imm                            |
| `slli rd, rs1, rs2`    | I        | rd = rs1 « imm[4:0]                       |
| `srli rd, rs1, rs2`    | I        | rd = rs1 » imm[4:0]                       |
| `srai rd, rs1, rs2`    | I        | rd = rs1 » imm[4:0] (Arith*)              |
| `slti rd, rs1, rs2`    | I        | rd = (rs1 < imm) ? 1 : 0                  |
| `sltiu rd, rs1, rs2`   | I        | rd = ( (u)rs1 < (u)imm ) ? 1 : 0          |
| `lb rd, imm(rs1)`      | I        | 读取 1 byte 并做符号位扩展                |
| `lh rd, imm(rs1)`      | I        | 读取 2 byte 并做符号位扩展                |
| `lw rd, imm(rs1)`      | I        | 读取 4 byte                               |
| `lbu rd, imm(rs1)`     | I        | 读取 1 byte 并做 0 扩展                   |
| `lhu rd, imm(rs1)`     | I        | 读取 2 byte 并做 0 扩展                   |
| `sb rd, imm(rs1)`      | S        | 存入 1 byte                               |
| `sh rd, imm(rs1)`      | S        | 存入 2 byte                               |
| `sw rd, imm(rs1)`      | S        | 存入 4 byte                               |
| `beq rs1, rs2, label`  | B        | if (rs1 == rs2)  PC += {imm,1’b0}         |
| `bne rs1, rs2, label`  | B        | if (rs1 != rs2)  PC += {imm,1’b0}         |
| `blt rs1, rs2, label`  | B        | if (rs1 < rs2)  PC += {imm,1’b0}          |
| `bge rs1, rs2, label`  | B        | if (rs1 >= rs2)  PC += {imm,1’b0}         |
| `bltu rs1, rs2, label` | B        | if ( (u)rs1 < (u)rs2 )  PC += {imm,1’b0}  |
| `bgeu rs1, rs2, label` | B        | if ( (u)rs1 >= (u)rs2 )  PC += {imm,1’b0} |
| `jal rd, label`        | J        | rd = PC + 4; PC += {imm,1’b0}             |
| `jalr rd, rs1, imm`    | I        | rd = PC + 4; PC = rs1 + imm               |
| `lui rd, imm`          | U        | rd = imm « 12                             |
| `auipc rd, imm`        | U        | rd = PC + (imm « 12)                      |
| `ecall`                | I        | 控制权交给操作系统 (采用输入设备模拟)     |
| `mul rd, rs1, rs2`     | R        | rd = (rs1 * rs2)[31:0]                    |
| `mulh rd, rs1, rs2`    | R        | rd = (rs1 * rs2)[63:32]                   |
| `mulhsu rd, rs1, rs2`  | R        | rd = (rs1 * (u)rs2)[63:32]                |
| `mulhu rd, rs1, rs2`   | R        | rd = ( (u)rs1 * (u)rs2 )[63:32]           |
| `div rd, rs1, rs2`     | R        | rd = rs1 / rs2                            |
| `divu rd, rs1, rs2`    | R        | rd = (u)rs1 / (u)rs2                      |
| `rem rd, rs1, rs2`     | R        | rd = rs1 % rs2                            |
| `remu rd, rs1, rs2`    | R        | rd = (u)rs1 % (u)rs2                      |

### IO

- 使用 **MMIO** (Memory Mapping IO，内存映射) 进行 IO 操作并支持 UART
- UART
  - 支持通过软件而非重新烧写 FPGA 的方式进行程序与数据的加载
  - 115200Hz 比特率
  - 
- 输入 (Input)
  - 支持 24 个拨码开关
  - 5 个按钮
  - 4 × 4 小键盘
- 输出 (Output)
  - 支持 24 个 LED 灯
  - 7 段数码管
  - VGA
    - 使用软硬件协同的方式实现
    - 800×600 60Hz
    - 单个字符为 8×16 像素，全屏可显示 96×32 个字符，显示区域长宽比为 3 : 2

**MMIO 对应地址** 

| 地址       | 读/写 | 映射内容               | 取值范围 (省略前导0) |
| :--------- | ----- | ---------------------- | -------------------- |
| 0xFFFFFF00 | R     | 第 1 组拨码开关 (8 个) | 0x00 - 0xFF          |
| 0xFFFFFF04 | R     | 第 2 组拨码开关 (8 个) | 0x00 - 0xFF          |
| 0xFFFFFF08 | R     | 第 3 组拨码开关 (8 个) | 0x00 - 0xFF          |
| 0xFFFFFF0C | W     | 第 1 组 LED (8 个)     | 0x00 - 0xFF          |
| 0xFFFFFF10 | W     | 第 2 组 LED (8 个)     | 0x00 - 0xFF          |
| 0xFFFFFF14 | W     | 第 3 组 LED (8 个)     | 0x00 - 0xFF          |
| 0xFFFFFF18 | R     | 按钮 1 (中)            | 0x00 - 0x01          |
| 0xFFFFFF1C | R     | 按钮 2 (上)            | 0x00 - 0x01          |
| 0xFFFFFF20 | R     | 按钮 3 (下)            | 0x00 - 0x01          |
| 0xFFFFFF24 | R     | 按钮 4 (左)            | 0x00 - 0x01          |
| 0xFFFFFF28 | R     | 按钮 5 (右)            | 0x00 - 0x01          |
| 0xFFFFFF2C | R     | 异常中断后跳转的 PC    | 无固定范围           |
|            |       |                        |                      |



## 使用方法

还是先略...



## 总结与注意事项

最后再写



## 问题及解决方案

+ **[Data Hazard]** `ret (jalr zero, ra, 0)` 指令必须在 `ld ra, 0(sp)` 4 条指令之后，或者函数指令数必须大于 4，否则会出现异常.
  - **原因**: ra 寄存器的更改发生在 4 个周期后，而 `ret` 指令在访问 ra 寄存器时导致数据冒险
  - **解决方案**: 
    1. 保证 `ret` 指令在 `ld ra, 0(sp)` 4 条指令后执行
    2. 在 `ret` 指令之前插入 nop 指令
    3. 进行停顿 ~~(懒得改了)~~ 
