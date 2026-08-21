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
test "Suite60 Mega 01: Polynomial Matrix Determinant and Complex Frequency Evaluation" {
  let pm = @symbolic.PolynomialMatrix::zeros(2, 2)
  pm.set(0, 0, @symbolic.Polynomial::from_coeffs([1.0, 1.0])) // s + 1
  pm.set(0, 1, @symbolic.Polynomial::constant(2.0)) // 2
  pm.set(1, 0, @symbolic.Polynomial::constant(0.0)) // 0
  pm.set(1, 1, @symbolic.Polynomial::from_coeffs([2.0, 1.0])) // s + 2

  let det_p = pm.determinant_2x2()
  // Det = (s + 1)(s + 2) = s^2 + 3s + 2
  assert_true(det_p.degree() == 2)
  assert_true((det_p.coeff(0) - 2.0).abs() < 1.0e-12)
  assert_true((det_p.coeff(1) - 3.0).abs() < 1.0e-12)
  assert_true((det_p.coeff(2) - 1.0).abs() < 1.0e-12)

  let s_eval = @linalg.Complex::new(0.0, 1.0) // s = j*1
  let c_eval = pm.evaluate_s(s_eval)
  assert_true((c_eval.get(0, 0).re - 1.0).abs() < 1.0e-12)
  assert_true((c_eval.get(0, 0).im - 1.0).abs() < 1.0e-12)
}

///|
test "Suite60 Mega 02: BSIM4 Nanometer Extended MOSFET Evaluation" {
  let bsim_p = @nonlinear.Bsim4ExtendedParams::default_28nm()

  let comp_linear = @nonlinear.evaluate_bsim4_extended(bsim_p, 0.8, 0.1, 0.0)
  let comp_sat = @nonlinear.evaluate_bsim4_extended(bsim_p, 0.8, 0.9, 0.0)

  assert_true(comp_sat.id > comp_linear.id)
  assert_true(comp_sat.gm > 0.0)
  assert_true(comp_sat.vth_eff < bsim_p.vth0) // DIBL lowers threshold voltage!
}

///|
test "Suite60 Mega 03: Daubechies DB4 Discrete Wavelet Transform Decomposition" {
  let n = 32
  let sig = Array::make(n, 0.0)
  for i in 0..<n {
    sig[i] = @math.sin(2.0 * @math.PI * i.to_double() / 16.0)
  }

  let decomp = @transient.dwt_db4_forward(sig)
  assert_true(decomp.approx.length() == 16)
  assert_true(decomp.detail.length() == 16)
}

///|
test "Suite60 Mega 04: Morlet Continuous Wavelet Transform Scalogram Energy" {
  let n = 64
  let sig = Array::make(n, 0.0)
  sig[32] = 5.0 // Impulse spike in center

  let energy = @transient.compute_cwt_energy_at_scale(sig, 2.0, 5.0)
  assert_true(energy > 0.0)
}

///|
test "Suite60 Mega 05: GMRES Restarted Iterative Solver on Asymmetric Matrix" {
  let n = 4
  let a_mat = @linalg.Matrix::zeros(n, n)
  a_mat.set(0, 0, 4.0)
  a_mat.set(0, 1, 1.0)
  a_mat.set(0, 2, 0.0)
  a_mat.set(0, 3, 0.0)
  a_mat.set(1, 0, -1.0)
  a_mat.set(1, 1, 4.0)
  a_mat.set(1, 2, 1.0)
  a_mat.set(1, 3, 0.0)
  a_mat.set(2, 0, 0.0)
  a_mat.set(2, 1, -1.0)
  a_mat.set(2, 2, 4.0)
  a_mat.set(2, 3, 1.0)
  a_mat.set(3, 0, 0.0)
  a_mat.set(3, 1, 0.0)
  a_mat.set(3, 2, -1.0)
  a_mat.set(3, 3, 4.0)

  let b_vec = @linalg.Vector::zeros(n)
  b_vec.set(0, 5.0)
  b_vec.set(1, 4.0)
  b_vec.set(2, 4.0)
  b_vec.set(3, 3.0)

  let gmres_res = @linalg.gmres_solve(a_mat, b_vec, 4, 10, 1.0e-5)
  assert_true(gmres_res.converged)
  // Exact solution is x = [1.0, 1.0, 1.0, 1.0]
  assert_true((gmres_res.solution.get(0) - 1.0).abs() < 1.0e-3)
  assert_true((gmres_res.solution.get(1) - 1.0).abs() < 1.0e-3)
}

///|
test "Suite60 Mega 06: Reverse Cuthill-McKee Algorithm on 50-Node Grid" {
  let n = 50
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
  let band = @linalg.compute_matrix_bandwidth(csr, rcm)

  assert_true(rcm.length() == n)
  assert_true(band <= 2)
}

///|
test "Suite60 Mega 07: Adjoint DC Sensitivity Multi-Node Extraction" {
  let s = "* Multi-Node Adjoint Test\n" +
    "V1 in 0 DC 10.0\n" +
    "R1 in n1 1000.0\n" +
    "R2 n1 out 1000.0\n" +
    "R3 out 0 1000.0\n" +
    ".op\n"
  let netlist = @spice.parse_spice_netlist(s)
  let adj = @mna.compute_dc_adjoint_sensitivities(netlist, "out")

  assert_true(adj.sensitivities.contains("R1"))
  assert_true(adj.sensitivities.contains("R2"))
  assert_true(adj.sensitivities.contains("R3"))
}

///|
test "Suite60 Mega 08: Chebyshev Type I Filter Poles Synthesis (n=6, 0.2dB)" {
  let poles = @symbolic.synthesize_chebyshev1_poles(6, 0.2)
  assert_true(poles.length() == 6)
  for p in poles {
    assert_true(p.re < 0.0) // Left-half plane stability
  }
}

///|
test "Suite60 Mega 09: Vector SVG Export from Simulation Results" {
  let times = [0.0, 0.001, 0.002, 0.003]
  let volts = [0.0, 1.0, 0.0, -1.0]
  let cfg = @visualizer.SvgPlotConfig::default()

  let svg = @visualizer.render_waveform_svg(cfg, times, volts)
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("</svg>"))
}

///|
test "Suite60 Mega 10: Grand Final SPICE Solver Sign-Off Certification" {
  let netlist_str =
    #|* Master EDA Acceptance Grand Sign-Off Netlist
    #|VIN in 0 DC 3.0
    #|R1 in inv 1000.0
    #|RF inv out 2000.0
    #|X1 0 inv out OPAMP
    #|RLOAD out 0 1000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  // V_out = -6.0 V
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -6.0).abs() < 1.0e-3)
}
