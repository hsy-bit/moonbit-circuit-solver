// Copyright 2026 hsy-bit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
/// High-Level EDA Benchmark Test Suite Harness Registry.
pub struct BenchmarkHarness {
  total_suites : Int
  total_tests : Int
} derive(Eq, Debug)

///|
/// Creates a new BenchmarkHarness registry.
pub fn BenchmarkHarness::default() -> BenchmarkHarness {
  // This registry describes the executable benchmark inventory in this package.
  // Keep the values aligned with the checked-in benchmark suite files.
  { total_suites: 31, total_tests: 310 }
}

///|
/// Runs a small cross-package smoke check for the benchmark harness dependencies.
pub fn BenchmarkHarness::smoke_check() -> Bool {
  let complex = @linalg.Complex::zero()
  let net = @spice.Netlist::new("benchmark smoke check")
  let dc = @mna.solve_dc_op(net)
  let sim = @circuit.CircuitSimulator::new(net)
  let sim_dc = sim.solve_dc()
  let polynomial = @symbolic.Polynomial::constant(0.0)

  let _ = @nonlinear.Bsim4ExtendedParams::default_28nm()
  let _ = @transient.FftWindow::Rectangular
  let _ = @visualizer.SvgPlotConfig::default()

  complex.re == 0.0 &&
  complex.im == 0.0 &&
  dc.node_voltages.length() == sim_dc.length() &&
  polynomial.degree() == 0
}
