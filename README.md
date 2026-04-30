# DUT Verification Project - SystemVerilog

## Project Overview
This project focuses on the verification of a **Black-Box Design Under Test (DUT)** using advanced verification methodologies. The goal was to ensure the functional correctness of the memory-mapped DUT through constrained-random testing and thorough coverage analysis.

[cite_start]**Student Name:** Ghaydaa Ramadan [cite: 2]
[cite_start]**Student ID:** 12216926 [cite: 3]

---

## Verification Methodology
[cite_start]The verification environment was built using a **constrained-random SystemVerilog testbench**[cite: 5]. The process was structured into three distinct execution phases to ensure full state coverage:

1.  [cite_start]**After-Reset Read Verification:** Validating the initial state of the memory[cite: 5].
2.  [cite_start]**Main Randomized Operation:** Stress-testing the DUT with various signal combinations[cite: 5].
3.  [cite_start]**Final Read Verification:** Checking data integrity and retention after operations[cite: 5].

### Key Features:
* [cite_start]**Functional Coverage:** Used to measure stimulus completeness[cite: 5].
* [cite_start]**Black-Box Testing:** Mismatches were detected using PASS/FAIL monitor messages[cite: 5].
* [cite_start]**Coverage Result:** Successfully achieved **100% functional coverage**[cite: 7].

---

## Functional Coverage Model
The testbench tracked several critical coverage points to ensure no corner case was missed:
* [cite_start]Address patterns and Write/Read operations[cite: 7].
* [cite_start]Control signals (`acc`, `func`) and Write data patterns[cite: 7].
* [cite_start]Scenario-based cross coverage[cite: 7].

---

## Detected Bugs
[cite_start]The verification process uncovered **multiple independent functional bugs** in the DUT[cite: 68]. [cite_start]These issues were consistently observed across randomized phases, indicating design-level flaws[cite: 10].

| Bug ID | Issue Description | Observed Behavior | Expected Behavior |
| :--- | :--- | :--- | :--- |
| **Bug 1** | Incorrect Read when `acc=1` | [cite_start]Read operations returned `0` instead of reset value when `acc` was high[cite: 11, 13]. | [cite_start]`acc` should only affect write operations, not reads[cite: 18]. |
| **Bug 2** | Pre-write Memory Modification | [cite_start]Some addresses returned non-reset values before any write occurred[cite: 23, 25]. | [cite_start]All memory must hold `24'h123456` after reset until written[cite: 32]. |
| **Bug 3** | `func` Signal Coupling | [cite_start]Read data changed based on the `func` signal value[cite: 38, 40]. | [cite_start]Reads should be independent of the `func` signal[cite: 46]. |
| **Bug 4** | Reset/Retention Flaw | [cite_start]Previously written data persisted in phases where reset values were expected[cite: 50, 52]. | [cite_start]Memory should hold reset values unless explicitly written after reset[cite: 57]. |

---

## Conclusion
[cite_start]The use of **constrained-random testing + functional coverage** proved highly effective[cite: 71]. [cite_start]Despite the DUT's instability, the testbench reached 100% coverage and successfully isolated critical design bugs, confirming the robustness of the verification environment[cite: 71].

---
*This project was completed as part of the Final Assignment for the Verification Course.*
