# Basys3-UART-Transceiver
VHDL UART transmitter/receiver for the Basys3 FPGA, verified in simulation and tested over serial communication with PuTTY.

# UART Communication on FPGA (Basys3, VHDL)

## Overview
This project implements a complete UART (Universal Asynchronous Receiver/Transmitter) system in VHDL and deploys it on a **Basys3 FPGA board**.

The design supports serial communication between a PC and the FPGA via USB-UART and was verified through both **Vivado simulation** and **real hardware testing using PuTTY**.

---

## Features
- Baud Rate Generator
- UART Transmitter (TX)
- UART Receiver (RX)
- Full simulation + hardware validation

---

## System Architecture

The system enables bidirectional serial communication:

PC (PuTTY) ↔ UART RX (FPGA) ↔ Logic ↔ UART TX (FPGA) ↔ PC (PuTTY)

---

## Modules

### Baud Rate Generator
- Generates timing ticks for TX/RX  
- Ensures synchronization with serial protocol  

### UART Transmitter
- Converts parallel data to serial stream  
- Adds start and stop bits  
- Operates at defined baud rate  

### UART Receiver
- Detects incoming serial data  
- Samples bits at correct timing  
- Reconstructs original byte  

---

## Simulation

Simulation was performed using **Vivado**:

- Verified correct TX/RX behavior  
- Checked timing and bit alignment  
- Validated start/stop bit detection  

To run:
1. Compile all VHDL files
2. Run testbench (`uart_tb.vhd`)
3. Inspect waveform output

---

## Hardware Testing

- Board: **Basys3 FPGA**
- Interface: USB-UART
- Terminal: **PuTTY**

### Setup
1. Program FPGA with generated bitstream  
2. Connect via USB  
3. Open PuTTY with correct COM port and baud rate  
4. Send/receive data  

---

## Demo

### UART Communication in Action

Full video:
[▶ Watch Demo](media/demo.mp4)

---

## Results
- Reliable serial communication established  
- Accurate data transmission and reception  
- Stable operation at configured baud rate  

---

## Tools & Technologies
- **Language:** VHDL  
- **Simulation:** Vivado  
- **FPGA:** Basys3 (Artix-7)  
- **Terminal:** PuTTY  

---

## What I Learned
- Designing communication protocols in hardware  
- Timing-critical digital design  
- Simulation vs real hardware behavior  
- Debugging using waveform + physical testing  

---

## Notes
This project demonstrates end-to-end FPGA development:
from simulation → synthesis → real hardware validation.