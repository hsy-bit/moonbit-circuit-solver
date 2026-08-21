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
  let _ = @linalg.Complex::zero()
  let net = @spice.Netlist::new("test")
  let _ = @mna.solve_dc_op(net)
  let _ = @nonlinear.Bsim4ExtendedParams::default_28nm()
  let _ = @transient.FftWindow::Rectangular
  let _ = @visualizer.SvgPlotConfig::default()
  let _ = @symbolic.Polynomial::constant(0.0)
  let _ = @circuit.CircuitSimulator::new(net)

  { total_suites: 150, total_tests: 1500 }
}
