
Verilog implementation and performance comparison of different 8-tap FIR filter architectures using various adder and multiplier combinations — Ripple Carry, Carry Save, Carry Select, Kogge-Stone, and Reversible logic designs.
# FIR Filter Architecture Comparison

This repository contains Verilog implementations and analysis of various **8-tap FIR (Finite Impulse Response) filter architectures** designed using different combinations of **adders** and **multipliers**.  
The objective is to compare these architectures based on **area utilization**, **power consumption**, and **speed**, and identify suitable designs for specific application requirements.

## 🧩 Architectures Implemented
| S.No | Adder Used | Multiplier Used | 
|------|-------------|----------------|
| 1 | Ripple Carry Adder | Vedic Multiplier | 
| 2 | Carry Save Adder | Vedic Multiplier |
| 3 | Carry Select Adder | Vedic Multiplier |
| 4 | Carry Select Adder | Reversible Multiplier |
| 5 | Kogge-Stone Adder | Reversible Multiplier |

Each design maintains the same number of **area registers (64)** for fair comparison, while differing in logic element count, operational frequency, and power.

## ⚙️ Key Features
- Structural Verilog design of all adder and multiplier architectures  
- Modular design with reusable components  
- 8-tap FIR filter configuration for benchmarking  
- Synthesizable and simulation-ready (ModelSim / Icarus Verilog compatible)  
- Performance metrics derived from synthesis reports

## 📊 Performance Summary
| Adder | Multiplier | Area (LEs) | Speed (MHz) | Power (mW) |
|--------|-------------|-------------|-------------|-------------|
| Ripple Carry | Vedic | 405 | 814.33 | 135.59 |
| Carry Save | Vedic | 436 | 798 | 136.4 |
| Carry Select | Vedic | 551 | 816.99 | 134.88 |
| Carry Select | Reversible | 482 | 831.26 | 138.03 |
| Kogge-Stone | Reversible | 600 | 813.67 | 131.13 |

## 🧠 Analysis
- **Ripple Carry Adder**: Most area-efficient design.  
- **Carry Select + Vedic Multiplier**: Best trade-off between power and speed.  
- **Kogge-Stone + Reversible Multiplier**: Lowest power consumption, ideal for power-sensitive systems.

## 🧰 Tools Used
- **HDL**: Verilog  
- **Simulation**: ModelSim / Icarus Verilog  
- **Synthesis**: Quartus Prime / Vivado  

## 🚀 How to Run
1. Clone the repository  
   ```bash
   git clone https://github.com/<your-username>/FIR_Filter_Architecture_Comparison.git
   cd FIR_Filter_Architecture_Comparison

