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
test "CircuitSimulator public analysis facade" {
  let spice_str =
    #|* Public API regression circuit
    #|V1 in 0 10.0
    #|R1 in out 1k
    #|R2 out 0 1k
    #|C1 out 0 1u
    #|.op
    #|.tran 10u 1m
    #|.end

  let sim = CircuitSimulator::from_spice_string(spice_str)

  let report = sim.run_dc_op_report()
  assert_true(report.contains("DC OPERATING POINT"))

  let dc = sim.solve_dc()
  assert_true((dc.get("out").unwrap() - 5.0).abs() < 1.0e-6)

  let transient = sim.solve_transient(0.00001, 0.001)
  assert_true(transient.steps.length() > 5)

  let chart = sim.render_transient_chart(0.00001, 0.001, "out")
  assert_true(chart.length() > 20)
}

///|
test "CircuitSimulator noise, Monte Carlo, and FFT facades" {
  let spice_str =
    #|* Statistical and spectral API regression circuit
    #|V1 in 0 10.0
    #|R1 in out 1k
    #|R2 out 0 1k
    #|.op
    #|.tran 10u 1m
    #|.end
  let sim = CircuitSimulator::from_spice_string(spice_str)

  let noise = sim.solve_noise("out", "V1", 100.0, 1000.0, 4)
  assert_eq(noise.points.length(), 4)
  assert_true(noise.points[0].contributions.length() > 0)
  assert_true(noise.total_integrated_output_noise_rms >= 0.0)

  let vars = [@mna.ComponentVariation::new("R1", 1000.0, 5.0, false)]
  let mc = sim.run_monte_carlo(vars, 8, "out", 4.0, 6.0, 42)
  assert_eq(mc.num_runs, 8)
  assert_eq(mc.runs.length(), 8)
  assert_true(mc.mean_voltage > 4.0 && mc.mean_voltage < 6.0)

  let fft = sim.compute_fft(0.00001, 0.001, "out", 1000.0)
  assert_true(fft.num_samples > 0)
  assert_true(fft.harmonics.length() > 0)
}

///|
test "CircuitSimulator symbolic design and least-squares facades" {
  let sim = CircuitSimulator::from_spice_string("* facade test\n.end\n")
  let design = sim.design_sallen_key(1000.0, 0.707)
  assert_true((design.fc_hz - 1000.0).abs() < 1.0e-9)
  assert_true(design.q_factor > 0.0)

  let a_mat = @linalg.Matrix::zeros(2, 2)
  a_mat.set(0, 0, 2.0)
  a_mat.set(1, 1, 3.0)
  let b_vec = @linalg.Vector::from_array([2.0, 6.0])
  let x = sim.solve_least_squares(a_mat, b_vec)
  assert_true((x.get(0) - 1.0).abs() < 1.0e-6)
  assert_true((x.get(1) - 2.0).abs() < 1.0e-6)
}
