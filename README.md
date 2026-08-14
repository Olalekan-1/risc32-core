# ARM-Inspired 32-bit RISC Processor

> A 32-bit ARM-inspired RISC processor designed in Verilog HDL, verified through simulation, and implemented on the Lattice iCEBreaker FPGA using an open-source hardware design flow.

![Verilog HDL](https://img.shields.io/badge/HDL-Verilog-blue)
![FPGA](https://img.shields.io/badge/FPGA-Lattice%20iCE40-orange)
![Board](https://img.shields.io/badge/Board-iCEBreaker-green)
![Status](https://img.shields.io/badge/Status-Working%20Prototype-yellow)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Overview

This project is the design and implementation of a simplified **32-bit ARM-inspired Reduced Instruction Set Computer (RISC) processor** developed from the ground up using Verilog HDL.

The project explores fundamental concepts in digital processor design, including instruction encoding, datapath design, register operations, arithmetic and logical computation, memory access, branching, control logic, simulation, and FPGA implementation.

The processor was developed through the following digital hardware design workflow:

```text
Architecture Design
        ↓
RTL Development
        ↓
Unit & System Simulation
        ↓
Waveform Analysis
        ↓
Logic Synthesis
        ↓
Place & Route
        ↓
FPGA Implementation
        ↓
Hardware Verification
```

The design has been implemented on the **Lattice iCEBreaker FPGA** and includes a UART-based execution trace for observing processor activity during hardware testing.

The project is currently a **working prototype under active development**. Future development will focus on extending its instruction set, capabilities, peripherals, verification environment, and overall architecture.

---

## Project Goals

The project brings together three areas of interest:

### Processor Engineering

To gain practical experience in designing and implementing a processor at the RTL level, from instruction definition and datapath design to control logic, memory access, and FPGA implementation.

### Open-Source Hardware

To explore processor and digital hardware development using accessible FPGA hardware and open-source Electronic Design Automation (EDA) tools.

### Education

To provide a practical processor design that can be studied and extended by students, educators, and hardware enthusiasts interested in digital logic, computer architecture, Verilog, and FPGA development.

---

## Project Highlights

| Area                 | Implementation       |
| -------------------- | -------------------- |
| Processor            | 32-bit RISC          |
| Architecture         | ARM-inspired         |
| HDL                  | Verilog              |
| Target FPGA          | Lattice iCE40        |
| Development Board    | iCEBreaker           |
| RTL Simulation       | Icarus Verilog       |
| Waveform Analysis    | GTKWave              |
| Logic Synthesis      | Yosys                |
| Place & Route        | nextpnr-ice40        |
| Bitstream Generation | IceStorm             |
| FPGA Programming     | iceprog              |
| Hardware Debugging   | UART execution trace |
| Project Status       | Working prototype    |

---

## Architecture

The processor is organized around a 32-bit datapath and a set of dedicated hardware modules responsible for instruction execution.

### High-Level Execution Flow

```text
                 ┌────────────────────┐
                 │   Program Counter  │
                 └─────────┬──────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │ Instruction Fetch  │
                 │      PC → IMEM     │
                 └─────────┬──────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │ Instruction Decode │
                 │ Decoder + Register │
                 │       File         │
                 └─────────┬──────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │      Execute       │
                 │        ALU         │
                 │   + Status Flags   │
                 └─────────┬──────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │   Data   │ │  Memory  │ │  Branch  │
        │Processing│ │ LDR / STR│ │    PC    │
        └────┬─────┘ └────┬─────┘ └────┬─────┘
             │            │            │
             └────────────┼────────────┘
                          ▼
                 ┌────────────────────┐
                 │   State / Register │
                 │       Update       │
                 └─────────┬──────────┘
                           │
                           ▼
                    Next Instruction
```

A detailed processor architecture and datapath description will be provided in [`docs/architecture.md`](docs/architecture.md).

---

## Instruction Set

The processor currently implements a subset of ARM-inspired instructions organized into three major categories.

### Data Processing

| Instruction | Operation   |
| ----------- | ----------- |
| `ADD`       | Addition    |
| `SUB`       | Subtraction |
| `AND`       | Bitwise AND |
| `ORR`       | Bitwise OR  |
| `EOR`       | Bitwise XOR |
| `MOV`       | Move        |
| `CMP`       | Compare     |

### Memory Access

| Instruction | Operation               |
| ----------- | ----------------------- |
| `LDR`       | Load a word from memory |
| `STR`       | Store a word to memory  |

### Branch

| Instruction        | Operation                              |
| ------------------ | -------------------------------------- |
| `B`                | Branch                                 |
| Conditional Branch | Branch based on processor status flags |

The instruction set is intentionally limited in the current prototype to provide a manageable foundation for understanding and extending processor architecture.

See [`docs/instruction-set.md`](docs/instruction-set.md) for detailed instruction formats, encoding, fields, and execution behavior.

---

## Design and Development Flow

The processor was developed incrementally, with individual hardware modules verified before being integrated into the complete processor system.

```text
Individual RTL Modules
          │
          ▼
     Unit Testing
          │
          ▼
   Datapath Testing
          │
          ▼
  Controller Testing
          │
          ▼
      CPU Testing
          │
          ▼
 Processor System Testing
          │
          ▼
    FPGA Implementation
          │
          ▼
   Hardware Verification
```

This approach allowed individual components and larger subsystems to be examined independently before full system integration.

---

## Verification

Verification was performed at multiple levels using simulation and hardware testing.

### RTL and Unit-Level Verification

Individual processor components were tested using dedicated testbenches.

The repository contains testbenches for components including:

* ALU
* Adder
* Condition logic
* Decoder
* Extend unit
* Data memory
* Instruction memory
* Multiplexer
* Program Counter
* Register
* Datapath

### Integration Verification

Higher-level testbenches were used to verify:

* Datapath behavior
* Controller behavior
* CPU operation
* Processor system integration

### Simulation Tools

Simulation is performed using **Icarus Verilog**, while **GTKWave** is used to inspect generated waveform files.

For example:

```bash
make cpu
make cpu_run
```

Waveforms can be inspected using:

```bash
gtkwave sim/waves/cpu.vcd
```

Simulation outputs and waveform files generated during development are stored in the `sim/` directory.

---

## FPGA Implementation

The processor targets the **Lattice iCEBreaker**, a development board based on the Lattice iCE40 FPGA family.

The FPGA implementation uses an open-source toolchain:

```text
Verilog RTL
    │
    ▼
  Yosys
    │
    ▼
JSON Netlist
    │
    ▼
nextpnr-ice40
    │
    ▼
ASCII Bitstream
    │
    ▼
  IceStorm
    │
    ▼
Binary Bitstream
    │
    ▼
  iceprog
    │
    ▼
iCEBreaker FPGA
```

The FPGA-specific files are located in:

```text
fpga/
├── soc.pcf
└── top.v
```

The pin constraints are defined in `soc.pcf`, while `top.v` provides the FPGA-level top module.

---

## UART Execution Trace

A UART transmitter and trace module are included to provide visibility into processor execution during hardware testing.

The trace system provides information such as:

* Program Counter
* Instruction
* ALU result
* Memory-related execution information

This provides a practical debugging mechanism when running the processor on physical FPGA hardware.

---

## Repository Structure

```text
.
├── LICENSE
├── README.md
├── build/
│   ├── top.asc
│   ├── top.bin
│   └── top.json
├── docs/
├── fpga/
│   ├── soc.pcf
│   └── top.v
├── images/
├── makefile
├── rtl/
│   ├── cpu/
│   ├── memory/
│   ├── peripherals/
│   ├── processor_system.v
│   └── trace/
├── sim/
│   ├── files/
│   └── waves/
└── tb/
    ├── integration/
    ├── system/
    └── units/
```

### Directory Overview

| Directory          | Purpose                               |
| ------------------ | ------------------------------------- |
| `rtl/`             | Processor and system RTL              |
| `rtl/cpu/`         | CPU datapath and control modules      |
| `rtl/memory/`      | Instruction and data memory           |
| `rtl/peripherals/` | Hardware peripherals                  |
| `rtl/trace/`       | Processor execution tracing           |
| `tb/`              | Testbenches                           |
| `sim/`             | Simulation outputs and waveforms      |
| `fpga/`            | FPGA top-level design and constraints |
| `build/`           | FPGA build artifacts                  |
| `docs/`            | Technical documentation               |
| `images/`          | Project diagrams and screenshots      |

---

## Getting Started

### Prerequisites

The project uses the following tools:

* Icarus Verilog
* GTKWave
* Yosys
* nextpnr-ice40
* IceStorm
* iceprog

A Linux environment is recommended for the complete FPGA workflow.

### Clone the Repository

```bash
git clone https://github.com/Olalekan-1/risc32-core.git
cd  risc32-core
```

### Simulation

The current Makefile provides commands used during processor development and verification.

#### CPU Simulation

```bash
make cpu
make cpu_run
```

#### Processor System Simulation

```bash
make processor
make system
```

#### Controller Simulation

```bash
make controller
make control_run
```

#### Datapath Simulation

```bash
make
make run
```

### Waveform Analysis

GTKWave can be used to inspect generated VCD files.

For example:

```bash
make gtk
```

or:

```bash
gtkwave sim/waves/cpu.vcd
```

Available waveform files are stored in:

```text
sim/waves/
```

---

## FPGA Build Flow

The current Makefile provides synthesis and place-and-route commands.

### Synthesis

```bash
make soc
```

This uses Yosys to synthesize the processor for the target iCE40 FPGA.

### Place and Route

```bash
make route_soc
```

This uses `nextpnr-ice40` with the target device and FPGA pin constraints.

### FPGA Programming

The generated binary can be programmed using:

```bash
iceprog build/top.bin
```

> The current Makefile reflects the development workflow used during the design and verification of the processor. It will be refined as the project evolves into a more reproducible open-source development environment.

---

## Documentation

Detailed technical documentation will be maintained in the [`docs/`](docs/) directory.

Planned documentation includes:

| Document                                        | Description                                  |
| ----------------------------------------------- | -------------------------------------------- |
| [`architecture.md`](docs/architecture.md)       | Overall processor architecture               |
| [`datapath.md`](docs/datapath.md)               | Datapath organization and data flow          |
| [`control-unit.md`](docs/control-unit.md)       | Control logic and instruction decoding       |
| [`instruction-set.md`](docs/instruction-set.md) | Instruction formats and supported operations |
| [`simulation.md`](docs/simulation.md)           | Simulation and waveform analysis             |
| [`fpga.md`](docs/fpga.md)                       | FPGA implementation and programming          |
| [`uart.md`](docs/uart.md)                       | UART execution tracing                       |
| [`developer-guide.md`](docs/developer-guide.md) | Guide for extending the processor            |

---

## Project Status

### Working Prototype — Active Development

The current processor is a functional prototype that has progressed from RTL design and simulation to FPGA implementation and hardware verification.

The current stage establishes the processor's core architecture and provides a foundation for future development.

The project is intentionally being developed incrementally, with new capabilities being added and evaluated as the architecture evolves.

---

## Roadmap

### Processor Architecture

* [x] 32-bit processor datapath
* [x] Register file
* [x] ALU
* [x] Instruction decoder
* [x] Control unit
* [x] Condition logic
* [x] Data-processing instructions
* [x] Load/store instructions
* [x] Branch instructions
* [x] Status flags
* [ ] Expand instruction set
* [ ] Improve instruction coverage
* [ ] Additional addressing modes
* [ ] Pipelined architecture
* [ ] Interrupt support

### Peripherals

* [x] UART transmitter
* [x] Button interface
* [ ] UART receiver
* [ ] GPIO
* [ ] Timer
* [ ] Additional memory-mapped peripherals

### Verification

* [x] Unit-level simulation
* [x] Datapath verification
* [x] Controller verification
* [x] CPU verification
* [x] Processor-system verification
* [x] Waveform analysis
* [x] FPGA validation
* [x] UART execution tracing
* [ ] Automated regression testing
* [ ] Expanded processor test programs
* [ ] Formal verification

### Development Infrastructure

* [x] Open-source synthesis flow
* [x] FPGA place-and-route flow
* [x] FPGA programming workflow
* [ ] Simplified project build commands
* [ ] Improved simulation automation
* [ ] Assembly/programming utilities
* [ ] Expanded developer documentation

---

## Contributing

This project is being developed as an open-source hardware and educational project.

Contributions, suggestions, discussions, bug reports, and improvements are welcome.

Areas of interest include:

* Processor architecture
* RTL design
* Verilog
* FPGA development
* Digital hardware verification
* Open-source EDA
* Processor peripherals
* Educational hardware

Contribution guidelines will be added as the project develops.

---

## License

This project is licensed under the **MIT License**.

See the [`LICENSE`](LICENSE) file for the complete license text.

---

## Author

**Olalekan Ahmed**

Digital Hardware Design

[GitHub](https://github.com/olalekan-1)

---

> **Build it. Understand it. Extend it.**
>
> An ongoing exploration of processor design, open hardware, and practical digital systems engineering.
