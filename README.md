# DUT Verification Project - SystemVerilog

## Project Overview
This project focuses on the verification of a **Black-Box Design Under Test (DUT)** using advanced verification methodologies. The main objective was to validate the functional correctness of a memory-mapped DUT using a constrained-random verification environment and detailed functional coverage analysis.

**Student Name:** Nadia Blaibleh  
**Department:** Computer Engineering  
**University:** An-Najah National University

---

## Verification Methodology
The verification environment was developed using a **constrained-random SystemVerilog testbench**. The verification flow was divided into three major execution phases to ensure complete behavioral validation:

1. **After-Reset Read Verification**  
   Verifying that all memory locations contain the expected default reset value.

2. **Main Randomized Operation Phase**  
   Applying randomized read/write transactions with different combinations of control signals.

3. **Final Read Verification**  
   Checking memory integrity and confirming data retention after randomized operations.

### Key Features
- **Constrained-Random Testing** to generate diverse test scenarios.
- **Functional Coverage** to measure verification completeness.
- **Black-Box Verification** without internal DUT visibility.
- **PASS/FAIL Monitoring** for automatic mismatch detection.
- **100% Functional Coverage Achieved**

---

## Functional Coverage Model
The testbench monitored several important coverage points, including:

- Address access patterns  
- Read and Write operations  
- Control signals (`acc`, `func`)  
- Write data variations  
- Scenario-based cross coverage between signals

This ensured that corner cases and rare combinations were exercised successfully.

---

## Detected Bugs
The verification process successfully identified multiple independent functional issues inside the DUT.

| Bug ID | Issue Description | Observed Behavior | Expected Behavior |
|-------|-------------------|------------------|------------------|
| Bug 1 | Incorrect Read when `acc=1` | Read returned invalid data when `acc` was high | `acc` should not affect read operations |
| Bug 2 | Pre-write Memory Modification | Some addresses changed before any write transaction | Memory must preserve reset value until written |
| Bug 3 | `func` Signal Dependency | Read output changed depending on `func` value | Read path should be independent of `func` |
| Bug 4 | Reset / Retention Issue | Old written values remained unexpectedly | Reset values should be restored correctly |

---

## Conclusion
This project demonstrates the effectiveness of combining **constrained-random verification** with **functional coverage** in detecting hidden DUT bugs.

The developed testbench achieved **100% functional coverage** and successfully exposed several design flaws, proving the strength and reliability of the verification environment.

---

## Tools & Technologies
- SystemVerilog  
- Functional Coverage  
- Constrained Random Verification  
- Simulation & Debugging  
- Black-Box Testing Methodology

---

*Completed as part of the Design Verification Course Final Project.*
