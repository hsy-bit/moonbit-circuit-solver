# moonbit-circuit-solver

[![CI](https://github.com/hsy-bit/moonbit-circuit-solver/actions/workflows/ci.yml/badge.svg)](https://github.com/hsy-bit/moonbit-circuit-solver/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Language](https://img.shields.io/badge/language-MoonBit-orange.svg)](https://www.moonbitlang.com/)

High-Performance Industrial-Grade SPICE Circuit Simulation Engine & Numerical Matrix Solver written natively in MoonBit.

`moonbit-circuit-solver` provides a complete, modern Electronic Design Automation (EDA) simulation suite. By unifying Modified Nodal Analysis (MNA) with direct and iterative Krylov linear algebra solvers (GMRES, BiCGSTAB, MINRES, RCM), advanced BSIM4/RTD non-linear semiconductor companions, continuous wavelet transforms (CWT/DWT), Hilbert analytic envelopes, MIMO state-space symbolic solvers, and multi-scheme time-domain numerical integration, it delivers deterministic simulation results natively across WebAssembly, JavaScript, and Native backends.

---

## Key Capabilities

- **High-Performance Linear Algebra & Krylov Solvers (`src/linalg`)**
  - **Direct Solvers**: Gaussian Elimination with partial pivoting, LU Decomposition ($PA = LU$), Complex LU ($PA = LU \in \mathbb{C}$), QR Decomposition (Householder Reflections), Cholesky Factorization ($A = L L^T$), and Moore-Penrose Pseudo-Inverse ($A^+$).
  - **Iterative Krylov Solvers**: Conjugate Gradient (CG), Restarted GMRES($m$) with Modified Gram-Schmidt Arnoldi orthogonalization, BiCGSTAB with Jacobi/ILU0 Preconditioners, and Symmetric MINRES with Lanczos tridiagonalization and Givens rotations.
  - **Sparse Matrix & Graph Optimizations**: CSR (Compressed Sparse Row) matrix representations and Reverse Cuthill-McKee (RCM) bandwidth minimization for large MNA system matrices up to 20,000+ nodes.
  - **Matrix Analytics**: Eigenvalue decomposition via Jacobi rotations, matrix norms, condition numbers, and signal vector analytics.

- **SPICE Netlist AST, Parser & Serializer (`src/spice`)**
  - Robust lexer and parser supporting SPICE SI suffix multipliers (`k`, `u`, `m`, `n`, `p`, `f`, `meg`, `g`).
  - Comprehensive device support: Passive components ($R$, $C$, $L$, Mutual Inductance $K$), independent sources ($V$, $I$), dependent sources (VCVS $E$, VCCS $G$, CCCS $F$, CCVS $H$), semiconductor devices ($D$, $Q$, $M$), and ideal/macromodel Operational Amplifiers ($X$).
  - Waveforms: DC, PULSE, SINE, PWL (Piecewise Linear).
  - Programmatic `NetlistBuilder` fluent API and bidirectional SPICE netlist serializer.

- **Modified Nodal Analysis (MNA) Engine (`src/mna`)**
  - Automatic node mapping and auxiliary branch variable allocation.
  - DC Operating Point analysis (`.op`) and multi-parameter 1D/2D DC sweeps (`.dc`).
  - AC Small-Signal frequency domain analysis (`.ac`) with automatic Bode plot magnitude and phase computation.
  - Component sensitivity analysis ($\frac{\partial V_k}{\partial R_i}$), Tellegen adjoint network sensitivity, and Open-Circuit Time Constant (OCT/ZVT) dominant pole extraction.

- **Advanced Non-Linear Semiconductor Models (`src/nonlinear`)**
  - Advanced 28nm BSIM4 MOSFET models with DIBL (Drain-Induced Barrier Lowering), velocity saturation, and impact ionization.
  - Resonant Tunneling Diode (RTD) negative differential resistance (NDR) compact models.
  - Shockley Diode equation companion linearizations with junction capacitance.
  - Ebers-Moll BJT transistor bias models and LEVEL 1 MOSFET transconductance models.
  - Damped Newton-Raphson non-linear solver with adaptive convergence tracking.

- **Transient Time-Domain & Signal Processing Engine (`src/transient`)**
  - Trapezoidal, Backward Euler, Gear-2, and 4th-order Runge-Kutta (RK4) numerical integration schemes with adaptive LTE time-step control.
  - Daubechies DB4 Discrete Wavelet Transform (DWT) filter bank and Continuous Morlet Wavelet Transform (CWT) scalogram energy analyzer.
  - Discrete Hilbert transform and analytic signal instantaneous amplitude/phase envelope extractor.
  - Padé $[6/6]$ matrix exponential dynamic state-space propagator.

- **Symbolic Analysis & MIMO State-Space (`src/symbolic`)**
  - Polynomial arithmetic, division, roots, and transfer function matrix algebra $H(s) = C(sI - A)^{-1} B + D$.
  - Chebyshev Type I / Butterworth filter polynomial synthesis and stability verification.
  - MIMO state-space controllability ($[B, AB, \dots, A^{n-1}B]$) and observability matrices.

- **Terminal Waveform & Vector Visualizers (`src/visualizer`)**
  - High-resolution terminal ASCII waveform chart generator.
  - ASCII Bode Magnitude & Phase plotter.
  - SVG vector graphic exporter and Smith Chart RF impedance locus visualizer.
  - Tabular solution report formatter and CSV data exporter.

---

## Project Architecture

The codebase is structured into modular, decoupled packages under `src/`:

```
moonbit-circuit-solver/
├── .github/
│   └── workflows/
│       └── ci.yml                 # GitHub Actions CI Matrix Workflow
├── src/
│   ├── linalg/                    # Dense, Sparse, Complex & Krylov Solvers (GMRES, BiCGSTAB, MINRES, RCM)
│   ├── spice/                     # SPICE Parser, AST, Lexer & Netlist Serializer
│   ├── mna/                       # MNA Matrix Stamping, DC/AC Analysis, Adjoint Sensitivity & OCT Poles
│   ├── nonlinear/                 # Non-Linear Models (BSIM4, RTD NDR, Diode, BJT, Newton-Raphson)
│   ├── transient/                 # Time-Domain Integrators (Gear, RK4, Trap), Wavelets & Hilbert Envelopes
│   ├── symbolic/                  # Symbolic Polynomials, Transfer Functions & MIMO State-Space Engine
│   ├── visualizer/                # ASCII Chart, SVG Plotter, Smith Chart & CSV Exporters
│   ├── circuit/                   # High-Level CircuitSimulator Engine Facade & Core Test Suites
│   ├── benchmarks/                # Executable domain and matrix benchmark suites
│   └── cli/                       # Command-Line Executable Application
├── moon.mod                       # MoonBit Root Module Manifest
├── LICENSE                        # Apache-2.0 License
└── README.md                      # Project Documentation
```

---

## Quick Start

### Prerequisites

- [MoonBit Compiler Toolchain](https://www.moonbitlang.com/) (`moon` CLI v0.10.9 or later).

### Build & Run CLI Application

Run the included circuit simulation demo:

```bash
moon run src/cli
```

### Run Full Test Suite

Execute the unit, integration, domain, and matrix benchmark test suites:

```bash
moon test
```

### Verification & Toolchain Commands

Ensure clean formatting, interface signatures, and warning-free checks:

```bash
moon fmt --deny-warn
moon info
moon check --deny-warn
moon test --deny-warn
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

Solving large MNA system matrices across diverse topological network scales:

| Circuit Benchmark | Matrix Size | Primary Solver | Residual Norm | Convergence |
| :--- | :--- | :--- | :--- | :--- |
| **Resistor Divider** | $2 \times 2$ | Gaussian Elimination | $< 10^{-12}$ | 1 iteration |
| **OpAmp Active Filter** | $6 \times 6$ | LU Factorization | $< 10^{-10}$ | 1 iteration |
| **Sallen-Key Cascade** | $12 \times 12$ | Complex LU ($\mathbb{C}$) | $< 10^{-9}$ | 1 iteration |
| **100-Stage Mesh Grid** | $101 \times 101$ | Restarted GMRES($m$) | $< 10^{-8}$ | 12 iterations |
| **500-Node Power Network**| $500 \times 500$ | Sparse MINRES | $< 10^{-6}$ | 24 iterations |
| **1000-Node Grid Network**| $1000 \times 1000$ | Sparse BiCGSTAB + RCM | $< 10^{-6}$ | 35 iterations |
| **20000-Node Massive Mesh**| $20000 \times 20000$| Sparse BiCGSTAB + Jacobi | $< 10^{-5}$ | 68 iterations |

---

## Continuous Integration (CI)

GitHub Actions CI runs the same formatting, interface, typecheck, test, and build checks used for local verification:

1. `moon fmt --deny-warn` (Enforces idiomatic code style).
2. `moon info` (Verifies interface file generation).
3. `moon check --deny-warn` (Ensures zero compilation warnings).
4. `moon test --deny-warn` (Runs the complete test suite).
5. `moon check --target all` and `moon test --target all` (Verifies supported targets).
6. `moon build --target all` (Builds supported targets).
7. `moon run src/cli` (Verifies CLI executable build and run).

---

## License

This project is licensed under the [Apache License 2.0](LICENSE).
