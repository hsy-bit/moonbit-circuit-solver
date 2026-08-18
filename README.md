# moonbit-circuit-solver

[![CI](https://github.com/hsy-bit/moonbit-circuit-solver/actions/workflows/ci.yml/badge.svg)](https://github.com/hsy-bit/moonbit-circuit-solver/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Language](https://img.shields.io/badge/language-MoonBit-orange.svg)](https://www.moonbitlang.com/)

High-Performance SPICE Circuit Simulation Engine & Numerical Matrix Solver written natively in MoonBit.

`moonbit-circuit-solver` provides a complete, modern circuit simulation toolkit designed for electronic design automation (EDA), circuit analysis education, and online virtual instrumentation. By utilizing Modified Nodal Analysis (MNA) with direct and iterative linear algebra solvers, non-linear semiconductor companions, and multi-scheme time-domain numerical integration, it delivers fast, deterministic simulation results natively across WebAssembly, JavaScript, and Native backends.

---

## Key Capabilities

- **High-Performance Linear Algebra Matrix Engine (`src/linalg`)**
  - **Dense Solvers**: Gaussian Elimination with partial pivoting, LU Decomposition ($PA = LU$), QR Decomposition (Householder Reflections), Cholesky Factorization ($A = L L^T$), and Moore-Penrose Pseudo-Inverse ($A^+$).
  - **Iterative Solvers**: Conjugate Gradient (CG), GMRES, and BiCGSTAB with Jacobi & ILU0 Preconditioners.
  - **Sparse Matrix**: CSR (Compressed Sparse Row) matrix representations optimized for large MNA system matrices.
  - **Matrix Analytics**: Eigenvalue decomposition via Jacobi rotations, matrix norms, condition numbers, and signal vector analytics.

- **SPICE Netlist AST & Parser (`src/spice`)**
  - Robust lexer and parser supporting SPICE SI suffix multipliers (`k`, `u`, `m`, `n`, `p`, `f`, `meg`, `g`).
  - Passive components ($R$, $C$, $L$), independent sources ($V$, $I$), dependent sources (VCVS $E$, VCCS $G$, CCCS $F$, CCVS $H$), semiconductor devices ($D$, $Q$, $M$), and ideal Operational Amplifiers ($X$).
  - Waveforms: DC, PULSE, SINE, PWL (Piecewise Linear).
  - Programmatic `NetlistBuilder` fluent API and bidirectional SPICE netlist serializer.

- **Modified Nodal Analysis (MNA) Engine (`src/mna`)**
  - Automatic node mapping and auxiliary branch variable allocation.
  - DC Operating Point analysis (`.op`) and multi-parameter 1D/2D DC sweeps (`.dc`).
  - AC Small-Signal frequency domain analysis (`.ac`) with automatic Bode plot magnitude and phase computation.
  - Component sensitivity analysis ($\frac{\partial V_k}{\partial R_i}$) and RLGC transmission line lumped cascade synthesis.

- **Non-Linear Semiconductor Solvers (`src/nonlinear`)**
  - Shockley Diode equation companion linearizations.
  - Ebers-Moll BJT transistor bias models.
  - LEVEL 1 MOSFET transconductance and output conductance models.
  - Damped Newton-Raphson non-linear solver with adaptive convergence tracking.

- **Transient Time-Domain Integration Engine (`src/transient`)**
  - Trapezoidal, Backward Euler, Gear-2, and 4th-order Runge-Kutta (RK4) numerical integration schemes.
  - Companion equivalent circuit models ($R_{eq}$, $I_{eq}$) for reactive elements ($C$, $L$).
  - Adaptive time-step control based on local truncation error (LTE).

- **Terminal Waveform & Export Utilities (`src/visualizer`)**
  - High-resolution terminal ASCII waveform chart generator.
  - ASCII Bode Magnitude plot renderer.
  - SVG vector graphic exporter for high-quality plot documentation.
  - Tabular solution report formatter and CSV data exporter.

---

## Project Architecture

The codebase is organized into focused, decoupled packages under `src/`:

```
moonbit-circuit-solver/
├── .github/
│   └── workflows/
│       └── ci.yml                 # GitHub Actions CI Workflow
├── src/
│   ├── linalg/                    # Dense & Sparse Linear Algebra Solvers
│   │   ├── vector.mbt             # 1D Vector operations & L2 norms
│   │   ├── matrix.mbt             # 2D Row-major dense Matrix operations
│   │   ├── sparse.mbt             # CSR (Compressed Sparse Row) matrix
│   │   ├── gaussian.mbt           # Gaussian Elimination solver
│   │   ├── lu.mbt                 # LU Decomposition with partial pivoting
│   │   ├── qr.mbt                 # QR Householder decomposition & least squares
│   │   ├── cholesky.mbt           # Cholesky factorization & solver
│   │   ├── iterative.mbt          # Conjugate Gradient & Preconditioners
│   │   ├── matrix_ops.mbt         # Jacobi Eigenvalue solver
│   │   ├── matrix_sparse_solvers.mbt # BiCGSTAB iterative sparse solver
│   │   └── vector_ops.mbt         # Moving average smoothing & signal statistics
│   ├── spice/                     # SPICE Parser & Netlist AST Engine
│   │   ├── ast.mbt                # Netlist AST, Components, Analysis commands
│   │   ├── lexer.mbt              # Tokenizer with SI suffix multiplier parsing
│   │   ├── parser.mbt             # Netlist string parser (DC, PULSE, SINE, PWL)
│   │   ├── netlist_builder.mbt    # Programmatic fluent Builder API
│   │   ├── netlist_serializer.mbt # AST to SPICE text serializer
│   │   ├── subckt.mbt             # Subcircuit definition & expansion engine
│   │   └── model_table.mbt        # Standard built-in semiconductor model registry
│   ├── mna/                       # Modified Nodal Analysis Matrix Stamp Engine
│   │   ├── node_map.mbt           # Circuit node indexer & aux variable allocator
│   │   ├── stamp.mbt              # MNA matrix conductance & source stamping rules
│   │   ├── dc_analysis.mbt        # DC Operating Point & 1D Sweep engine
│   │   ├── dc_sweep_advanced.mbt  # 2D Multi-parameter DC Sweep engine
│   │   ├── ac_analysis.mbt        # AC Frequency sweep & Bode magnitude/phase
│   │   ├── sensitivities.mbt      # DC component sensitivity calculator
│   │   └── transmission_line.mbt  # RLGC transmission line lumped cascade synthesizer
│   ├── nonlinear/                 # Non-Linear Device Models & Newton-Raphson
│   │   ├── diode.mbt              # Diode companion model
│   │   ├── bjt.mbt                # BJT hybrid-pi companion model
│   │   ├── mosfet.mbt             # MOSFET LEVEL 1 companion model
│   │   └── newton_raphson.mbt     # Damped Newton-Raphson non-linear solver
│   ├── transient/                 # Time-Domain Transient Simulation Engine
│   │   ├── integration.mbt        # Trapezoidal, Backward Euler, Gear schemes
│   │   ├── gear_solver.mbt        # Multi-step Gear-2 solver
│   │   ├── runge_kutta.mbt        # Explicit RK4 ODE integration solver
│   │   └── transient_solver.mbt   # Time-domain transient simulation solver
│   ├── visualizer/                # Terminal & Vector Visualization Output
│   │   ├── ascii_chart.mbt        # Terminal ASCII waveform plotter
│   │   ├── bode_plot.mbt          # Terminal ASCII Bode magnitude plotter
│   │   ├── svg_plot.mbt           # Standalone SVG graphic renderer
│   │   ├── table_formatter.mbt    # Tabular operating point report builder
│   │   └── csv_export.mbt         # CSV time-series exporter
│   ├── circuit/                   # High-Level Simulation Facade & Test Suite
│   │   ├── circuit.mbt            # CircuitSimulator Facade API
│   │   ├── benchmark.mbt          # Matrix performance benchmark suite
│   │   └── *_test.mbt             # Exhaustive test suites (39 unit & integration tests)
│   └── cli/                       # Command-Line Executable Application
│       └── main.mbt               # Terminal CLI Entry Point
├── moon.mod                       # MoonBit Root Module Manifest
├── LICENSE                        # Apache-2.0 License
└── README.md                      # Documentation
```

---

## Quick Start

### Prerequisites

- [MoonBit Compiler Toolchain](https://www.moonbitlang.com/) (`moon` CLI v0.10.0 or later).

### Build & Run CLI Application

Run the included circuit simulation demo:

```bash
moon run src/cli
```

### Run Full Test Suite

Execute all 39 unit, integration, and benchmark test suites:

```bash
moon test
```

### Verification & Toolchain Commands

Ensure clean formatting, interface signatures, and warning-free checks:

```bash
moon fmt --deny-warn
moon info --deny-warn
moon check --deny-warn
```

---

## Usage Example

```moonbit
import "hsy-bit/moonbit-circuit-solver/src/circuit"

fn main {
  // Define SPICE netlist string
  let netlist_str =
    #|* RC Low-Pass Filter Transient Simulation
    #|V1 in 0 5.0
    #|R1 in out 1k
    #|C1 out 0 1u
    #|.op
    #|.tran 10u 2m
    #|.end

  // Create simulator instance
  let sim = @circuit.CircuitSimulator::from_spice_string(netlist_str)

  // Compute DC Operating Point
  let voltages = sim.solve_dc()
  println("Node 'out' DC Voltage: " + voltages.get("out").to_string() + " V")

  // Render Terminal ASCII Waveform
  let chart = sim.render_transient_chart(0.00001, 0.002, "out")
  println(chart)
}
```

---

## Benchmarks & Performance Metrics

Solving large MNA system matrices for multi-stage ladder networks ($N = 100$ nodes):

| Circuit Benchmark | Matrix Size | Direct Solver | Residual Norm |
| :--- | :--- | :--- | :--- |
| **Resistor Divider** | $2 \times 2$ | Gaussian Elimination | $< 10^{-12}$ |
| **OpAmp Amplifier** | $4 \times 4$ | LU Factorization | $< 10^{-10}$ |
| **10-Stage Ladder** | $11 \times 11$ | LU Factorization | $< 10^{-8}$ |
| **50-Stage Ladder** | $51 \times 51$ | LU Factorization | $< 10^{-6}$ |
| **100-Stage Ladder**| $101 \times 101$ | Sparse BiCGSTAB | $< 10^{-6}$ |

---

## Continuous Integration (CI)

This project strictly adheres to MoonBit community toolchain workflows. GitHub Actions CI automatically runs on every commit pushing to `main`:

1. `moon fmt --deny-warn` (Enforces idiomatic code style).
2. `moon info --deny-warn` (Verifies interface file generation).
3. `moon check --deny-warn` (Ensures zero compilation warnings).
4. `moon test` (Verifies all 39 test suites pass).

---

## License

This project is licensed under the [Apache License 2.0](LICENSE).
