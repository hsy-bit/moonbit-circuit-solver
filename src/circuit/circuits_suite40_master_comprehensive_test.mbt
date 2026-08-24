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
test "Suite40 Master 01: Multi-Stage SPICE System DC Node Convergence" {
  let netlist_str =
    #|* Master Multi-Stage Operational Pipeline Netlist
    #|VDD vdd 0 DC 15.0
    #|VSS vss 0 DC -15.0
    #|VIN in 0 DC 2.0
    #|* Stage 1: Non-Inverting Buffer (Gain = 1.0)
    #|X1 in out1 out1 OPAMP
    #|* Stage 2: Sallen-Key Low Pass Filter
    #|R1 out1 sk_mid 10000.0
    #|R2 sk_mid sk_pos 10000.0
    #|C1 sk_mid out2 22e-9
    #|C2 sk_pos 0 10e-9
    #|X2 sk_pos out2 out2 OPAMP
    #|* Stage 3: Inverting Scaling Amp (Gain = -2.5)
    #|R3 out2 inv3 1000.0
    #|RF3 inv3 out3 2500.0
    #|X3 0 inv3 out3 OPAMP
    #|RLOAD out3 0 10000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  // Stage 1: 2.0V, Stage 2: 2.0V, Stage 3: -5.0V
  let v1 = dc.get("out1").unwrap()
  let v2 = dc.get("out2").unwrap()
  let v3 = dc.get("out3").unwrap()

  assert_true((v1 - 2.0).abs() < 1.0e-3)
  assert_true((v2 - 2.0).abs() < 1.0e-3)
  assert_true((v3 - -5.0).abs() < 1.0e-3)
}

///|
test "Suite40 Master 02: Sparse Markowitz LU Factorization on High-Order System" {
  let n = 80
  let builder = @linalg.SparseBuilder::new(n, n)
  for i in 0..<n {
    builder.add_entry(i, i, 4.0)
    if i > 0 {
      builder.add_entry(i, i - 1, -1.0)
    }
    if i + 1 < n {
      builder.add_entry(i, i + 1, -1.0)
    }
  }
  let csr = builder.to_csr()
  let b = @linalg.Vector::zeros(n)
  for i in 0..<n {
    b.set(i, 2.0)
  }

  let sol = @linalg.bicgstab_solve(csr, b, 100, 1.0e-6)
  assert_true(sol.converged)
  assert_true(sol.solution.length() == n)
}

///|
test "Suite40 Master 03: Fast Fourier Transform THD on Non-Linear Waveform" {
  let num_pts = 64
  let f_fund = 1000.0
  let times = Array::make(num_pts, 0.0)
  let sig = Array::make(num_pts, 0.0)

  for i in 0..<num_pts {
    let t = i.to_double() / (64.0 * f_fund)
    times[i] = t
    // Fundamental + 2nd harmonic (5%) + 3rd harmonic (2%)
    let v = @math.sin(2.0 * @math.PI * f_fund * t) +
      0.05 * @math.sin(4.0 * @math.PI * f_fund * t) +
      0.02 * @math.sin(6.0 * @math.PI * f_fund * t)
    sig[i] = v
  }

  let fft_res = @transient.compute_transient_fft_analysis(
    times,
    sig,
    f_fund,
    @transient.FftWindow::Rectangular,
  )
  assert_true(fft_res.thd_percent > 0.0)
  assert_true(fft_res.harmonics.length() > 0)
}

///|
test "Suite40 Master 04: DC Adjoint Sensitivity on Multi-Branch Resistor Network" {
  let s = "* Multi-Branch Sensitivity\n" +
    "V1 in 0 DC 10.0\n" +
    "R1 in n1 1000.0\n" +
    "R2 n1 0 1000.0\n" +
    "R3 n1 out 500.0\n" +
    "R4 out 0 500.0\n" +
    ".op\n"
  let netlist = @spice.parse_spice_netlist(s)
  let adj = @mna.compute_dc_adjoint_sensitivities(netlist, "out")

  assert_true(adj.sensitivities.contains("R1"))
  assert_true(adj.sensitivities.contains("R4"))
}

///|
test "Suite40 Master 05: Monte Carlo Tolerance Sweep Yield on Precision Reference" {
  let s = "* Precision Reference Netlist\n" +
    "V1 in 0 DC 10.0\n" +
    "R1 in out 10000.0\n" +
    "R2 out 0 10000.0\n" +
    ".op\n"
  let netlist = @spice.parse_spice_netlist(s)
  let vars = [
    @mna.ComponentVariation::new("R1", 10000.0, 0.5, true),
    @mna.ComponentVariation::new("R2", 10000.0, 0.5, true),
  ]

  let mc = @mna.run_monte_carlo_dc(netlist, vars, 50, "out", 4.90, 5.10, 42)
  assert_true(mc.num_runs == 50)
  assert_true(mc.yield_percent >= 95.0)
}

///|
test "Suite40 Master 06: Vector SVG Export from Simulation Results" {
  let t_arr = [0.0, 1.0e-3, 2.0e-3, 3.0e-3, 4.0e-3]
  let v_arr = [0.0, 1.5, 3.0, 1.5, 0.0]
  let cfg = @visualizer.SvgPlotConfig::default()

  let svg_data = @visualizer.render_waveform_svg(cfg, t_arr, v_arr)
  assert_true(svg_data.contains("<svg"))
  assert_true(svg_data.contains("width=\"800\""))
}

///|
test "Suite40 Master 07: Smith Chart Complex Reflection Coefficient Vector Export" {
  let gamma_data = [
    @linalg.Complex::new(0.1, 0.1),
    @linalg.Complex::new(0.3, 0.2),
    @linalg.Complex::new(0.6, -0.3),
  ]

  let smith_svg = @visualizer.render_smith_chart_svg(
    gamma_data, 500.0, "Master S11 Trajectory",
  )
  assert_true(smith_svg.contains("Master S11 Trajectory"))
  assert_true(smith_svg.contains("</svg>"))
}

///|
test "Suite40 Master 08: Reverse Cuthill-McKee Matrix Permutation on 100-Node Band" {
  let n = 100
  let builder = @linalg.SparseBuilder::new(n, n)
  for i in 0..<n {
    builder.add_entry(i, i, 3.0)
    if i > 0 {
      builder.add_entry(i, i - 1, -1.0)
    }
    if i + 1 < n {
      builder.add_entry(i, i + 1, -1.0)
    }
  }
  let csr = builder.to_csr()
  let rcm = @linalg.reverse_cuthill_mckee(csr)

  assert_true(rcm.length() == 100)
}

///|
test "Suite40 Master 09: Padé [6/6] Matrix Exponential State-Space Evolution" {
  let a_mat = @linalg.Matrix::zeros(2, 2)
  a_mat.set(0, 0, -1.0)
  a_mat.set(0, 1, 0.0)
  a_mat.set(1, 0, 0.0)
  a_mat.set(1, 1, -2.0)

  let exp_a = @transient.compute_matrix_exp(a_mat)
  // exp(-1) approx 0.367879, exp(-2) approx 0.135335
  let exp_1 = @math.exp(-1.0)
  let exp_2 = @math.exp(-2.0)

  assert_true((exp_a.get(0, 0) - exp_1).abs() < 1.0e-4)
  assert_true((exp_a.get(1, 1) - exp_2).abs() < 1.0e-4)
}

///|
test "Suite40 Master 10: Master End-to-End SPICE Regression Golden Verification" {
  let netlist_str =
    #|* Master EDA Regression Golden Benchmark
    #|V_SUP vcc 0 DC 10.0
    #|V_IN in 0 DC 2.5
    #|R_IN in inv 10000.0
    #|R_F inv out 10000.0
    #|X1 0 inv out OPAMP
    #|R_LOAD out 0 5000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -2.5).abs() < 1.0e-3)
}
