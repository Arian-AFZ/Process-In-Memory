# Process-in-Memory (PIM) System - Verilog Implementation

## Overview
This repository contains the Verilog implementation of a **Process-in-Memory (PIM)** system. The PIM system integrates memory, an Arithmetic Logic Unit (ALU), and a Control Unit (CU) to perform in-memory computations. The system supports basic memory read/write operations as well as arithmetic and logical operations on data stored in memory. A block diagram of the system is included in the repository.

---

## Table of Contents
1. [System Specifications](#system-specifications)
2. [Module Descriptions](#module-descriptions)
3. [Instruction Format](#instruction-format)
4. [Operation Scenarios](#operation-scenarios)
5. [Testbench](#testbench)
6. [Simulation and Results](#simulation-and-results)

---

## System Specifications
- **Inputs**:
  - `clk`: Clock signal for synchronization.
  - `rst`: Reset signal to initialize the system.
  - `instruction`: A 45-bit instruction for controlling operations.
  - `operation_enable`: Signal to enable the execution of operations.
- **Outputs**:
  - `data_out`: 32-bit output data from memory or ALU.
  - `ready`: Signal indicating the completion of an operation.

---

## Module Descriptions

### 1. **ALU**
The ALU performs arithmetic and logical operations based on the `opcode`:
- **Operations**:
  - `00`: Addition (`A + B`)
  - `01`: Subtraction (`A - B`)
  - `10`: Bitwise AND (`A & B`)
  - `11`: Bitwise OR (`A | B`)

### 2. **Control Unit (CU)**
The CU decodes the 45-bit instruction and generates control signals for memory, ALU, and registers. It handles:
- Memory read/write operations.
- ALU operation sequencing.
- Register file management.

### 3. **Memory**
A 1KB memory module with 32-bit words. Supports:
- Read operations: Outputs data at a specified address.
- Write operations: Stores data at a specified address.

### 4. **DataPath**
Integrates the ALU and register file. It handles:
- Loading data into registers.
- Performing ALU operations.
- Outputting results.

### 5. **MUX**
A 2:1 multiplexer for selecting between:
- ALU output.
- Immediate data from the instruction.

### 6. **RegFile**
A register file with two 32-bit registers for storing intermediate data during ALU operations.

### 7. **PIM**
The top-level module that integrates all components and manages the overall operation of the system.

---

## Instruction Format
The 45-bit instruction is divided into the following fields:
1. **Opcode (3 bits)**:
   - `1xx`: ALU operation (bits 1-0 specify the ALU operation).
   - `0xx`: Memory operation (`00` for read, otherwise write).
2. **Operand A (10 bits)**: Address for memory read/write or the first ALU operand.
3. **Operand B (10 bits)**: Address for the second ALU operand.
4. **Operand C (10 bits)**: Address for storing the ALU result.
5. **Immediate Data (12 bits)**: Used for write operations (combined with Operands B and C to form a 32-bit value).

---

## Operation Scenarios

### 1. **Write Operation**
- **Opcode**: `001`, `010`, or `011`.
- **Steps**:
  1. Set `memory_write` to `1`.
  2. Provide `memory_address` and `immediate_memory_data`.
  3. Wait for `ready` signal to indicate completion.

### 2. **Read Operation**
- **Opcode**: `000`.
- **Steps**:
  1. Set `memory_read` to `1`.
  2. Provide `memory_address`.
  3. Wait for `ready` signal and read `data_out`.

### 3. **ALU Operation**
- **Opcode**: `1xx`.
- **Steps**:
  1. Fetch the first operand from memory.
  2. Fetch the second operand from memory.
  3. Perform the ALU operation.
  4. Store the result in memory.

---

## Testbench
The testbench (`tb`) verifies the functionality of the PIM system. It includes tasks for:
- Writing to memory.
- Reading from memory.
- Performing ALU operations.

### Test Cases
1. **Memory Initialization**:
   - Write edge-case values to memory (e.g., largest positive integer, smallest negative integer, zero).
   - Verify writes by reading back the values.
2. **ALU Operations**:
   - Addition, subtraction, bitwise AND, and bitwise OR.
   - Verify results by reading from memory.

---

## Simulation and Results
Running the testbench file (tb.v) produces the following output:

![image](https://github.com/user-attachments/assets/123ebd5d-5110-4c10-ac27-85188afd5ed5)

---

## Authored By:
- Arian Afzalzadeh
- [Sina Imani](https://github.com/mr-sina-imani/)
