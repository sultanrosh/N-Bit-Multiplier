# N-Bit Binary Multiplier with BCD Conversion (Double Dabble)

## Table of Contents

* [Overview](#overview)
* [Project Purpose](#project-purpose)
* [Design Description](#design-description)

  * [High-Level Functionality](#high-level-functionality)
  * [Binary Multiplication](#binary-multiplication)
  * [BCD and Why It's Used](#bcd-and-why-its-used)
  * [Double Dabble Algorithm](#double-dabble-algorithm)
* [Module Architecture](#module-architecture)
* [Signal Breakdown](#signal-breakdown)
* [Core Concepts & Aha Moments](#core-concepts--aha-moments)
* [Simulation](#simulation)

  * [Test Cases](#test-cases)
  * [Expected Results](#expected-results)
* [Waveform Analysis](#waveform-analysis)
* [Possible Enhancements](#possible-enhancements)
* [Conclusion](#conclusion)
* [Author](#author)

---

## Overview

This project is a fully synchronous Verilog hardware design implementing an **N-bit binary multiplier** with **BCD (Binary-Coded Decimal)** conversion using the **Double Dabble algorithm**. The purpose is to translate the hardware product of two binary numbers into a human-readable BCD format that can be output to display hardware like 7-segment displays.

The design is modular, parametric, and built for simulation. It also demonstrates practical digital design concepts such as multiplication, clock-driven state machines, data shifting, and number system conversion.

---

## Project Purpose

In many real-world applications (calculators, embedded control panels, digital meters), it's necessary to multiply two binary values and display the result as decimal digits on a screen. Microcontrollers may use firmware to convert binary to decimal, but pure hardware logic—particularly on FPGAs or ASICs—needs a hardware-friendly algorithm like **Double Dabble** to perform this task efficiently.

This design:

* Multiplies two unsigned binary numbers (e.g., 8-bit values A and B)
* Computes their binary product
* Converts the binary result into BCD format
* Outputs each BCD digit in a separate 4-bit register (suitable for display)

---

## Design Description

### High-Level Functionality

* Inputs: Two N-bit numbers (A and B), clock (`clk`), and reset (`reset`)
* Outputs: 2N-bit binary product and four 4-bit BCD digit registers
* Internal: Registers to store the binary product, temporary shifting buffer, and BCD digit registers

### Binary Multiplication

The first step is a standard binary multiplication using Verilog's built-in `*` operator:

```verilog
bin_product <= A * B;
```

This gives a result that is 2N bits wide, which is then converted to BCD.

### BCD and Why It's Used

**BCD** (Binary-Coded Decimal) encodes each decimal digit in a 4-bit binary format:

* Decimal `0` = 4'b0000
* Decimal `9` = 4'b1001

This makes BCD ideal for display systems like 7-segment displays, which often map a 4-bit input directly to display logic. BCD is easy to decode visually and human-friendly.

### Double Dabble Algorithm

This is a hardware-friendly algorithm to convert binary numbers to BCD without using division. It works in these steps:

1. Start with the binary number in a shift register.
2. Initialize BCD digit registers to 0.
3. For each bit:

   * Check each BCD digit: If the digit is >= 5, add 3.
   * Shift all BCD digits and the binary register left by one bit.
   * Repeat this for the number of bits in the binary product (2N times).

This method keeps each 4-bit BCD digit within valid BCD bounds during shifting.

---

## Module Architecture

```verilog
module NBitMultiplierWithBCD #(
  parameter N = 8
)(
  input wire clk,
  input wire reset,
  input wire [N-1:0] A,
  input wire [N-1:0] B,
  output reg [2*N-1:0] bin_product,
  output reg [3:0] BCD_0,
  output reg [3:0] BCD_1,
  output reg [3:0] BCD_2,
  output reg [3:0] BCD_3
);
```

### Internals:

* `bin_product`: Stores the result of `A * B`
* `shift_reg`: Holds the product during conversion
* `bcd_array[3:0]`: Array of four 4-bit registers to store BCD digits
* `count`: Tracks number of shifts (loop control)
* `running`: Flag to indicate conversion in progress

---

## Signal Breakdown

| Signal        | Width       | Role                                   |
| ------------- | ----------- | -------------------------------------- |
| `A`, `B`      | N bits      | Inputs to multiplier                   |
| `bin_product` | 2N bits     | Binary product of A and B              |
| `BCD_0..3`    | 4 bits each | BCD digits (ones to thousands)         |
| `shift_reg`   | 2N bits     | Register used in Double Dabble process |
| `count`       | 8 bits      | Counts how many shifts are done        |
| `running`     | 1 bit       | Indicates whether conversion is active |

---

## Core Concepts & Aha Moments

* **Add-3 Rule**: Any BCD digit >= 5 before shifting must be corrected with +3 to ensure valid BCD after shift.
* **Shift-and-Add**: Left-shifting binary and BCD registers simulates decimal conversion.
* **Hex vs Decimal**: `132` decimal = `0x84` hex, which is what you see in waveform viewers.
* **`shift_reg` Usage**: Keeps the original binary product safe during conversion.
* **Array Slicing**: Understanding things like `bcd_array[2][3]` means accessing the MSB of the 3rd BCD digit.
* **Sequential Timing**: Multiplication and conversion must occur on valid clock cycles—timing is critical.
* **Waveform Interpretation**: You must know how to interpret VCD outputs and simulation timing.

---

## Simulation

### Testbench Procedure

* Initialize `clk = 0`, apply reset.
* Set values for `A` and `B`.
* Deassert reset.
* Wait for conversion to complete (`running == 0`).
* Print BCD and binary output.

### Sample Test Cases

| A   | B   | Binary Product | Expected BCD |
| --- | --- | -------------- | ------------ |
| 12  | 11  | 132            | 0 1 3 2      |
| 25  | 4   | 100            | 0 1 0 0      |
| 255 | 1   | 255            | 0 2 5 5      |
| 0   | 128 | 0              | 0 0 0 0      |

---

## Waveform Analysis

Use GTKWave or EPWave to inspect:

* `clk` and `reset` alignment
* When `bin_product` is computed
* When `running` goes low (conversion done)
* Final values of `BCD_0` through `BCD_3`

Watch how BCD digits increment and shift as each bit is processed.

---

## Possible Enhancements

* Support 5-digit BCD for full 16-bit product (up to 65535)
* Add enable/start conversion control
* Add 7-segment display encoder module
* Debounce logic for real hardware buttons
* Synthesizable version for FPGA implementation

---

## Conclusion

This design showcases a complete pipeline of digital arithmetic:

* Binary multiplication
* Data conversion
* Sequential logic control
* Binary to decimal interface design

It is a powerful example of how fundamental computer engineering concepts are translated into real hardware using Verilog.

This project also deepened understanding of RTL design practices, timing, and waveform analysis.

---

## Author

**Kourosh Rashidiyan**
FPGA & Digital Design Enthusiast
June 2025

```
