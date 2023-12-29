# RISC-V Pipeline Processor with Three Stages

## Description

This project implements a RISC-V pipeline processor with an innovative three-stage design. The stages include Instruction Fetch, combined Decode and Execute, and combined Memory and Writeback. This design efficiently manages instruction processing while handling hazards and maintaining Control and Status Registers (CSRs). The processor includes a Hazard Detection Unit for resolving data and control hazards, crucial in pipelined architectures.

## Features

- *Three-Stage Pipeline*: Instruction Fetch, combined Decode and Execute, combined Memory and Writeback.
- *Control and Status Registers (CSR)*: Manages processor state and control settings.
- *Hazard Detection Unit*: Identifies and resolves pipeline hazards to maintain efficiency.

## SystemVerilog Files Overview

- alu.sv: Arithmetic Logic Unit for arithmetic and logical operations.
- branch_comp.sv: Branch Comparator for branch instruction decisions.
- csr_reg.sv: Control and Status Register for special register operations.
- data_mem.sv: Data Memory simulating memory component for data storage.
- hazard_unit.sv: Hazard Detection Unit for identifying and resolving execution hazards.
- imm_gen.sv: Immediate Generator for processing immediate values from instructions.
- inst_decode.sv: Instruction Decoder for decoding fetched instructions.
- inst_mem.sv: Instruction Memory storing the instruction set.
- PC.sv: Program Counter tracking the current instruction address.
- Processor.sv: Main processor module integrating all components.
- reg_file.sv: Register File managing the set of processor registers.
- tb_processor.sv: Testbench for Processor used for simulation and verification.
- timer_interrupt.sv: Timer Interrupt for handling timing and interrupt operations.
