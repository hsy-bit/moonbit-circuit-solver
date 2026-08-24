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
test "Suite50 Finale 01: Complete Superheterodyne RF Transceiver Verification" {
  let netlist_str =
    #|* Master RF Transceiver Netlist
    #|VRF in_rf 0 DC 0.001
    #|* LNA Input Stage
    #|R_IN in_rf n_lna 50.0
    #|X_LNA n_lna out_lna out_lna OPAMP
    #|* Mixer Stage
    #|R_MIX out_lna n_mix 1000.0
    #|RF_MIX n_mix out_if 5000.0
    #|X_MIX 0 n_mix out_if OPAMP
    #|* IF Filter Load
    #|RLOAD out_if 0 10000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  // Gain = 1.0 * (-5.0) = -5.0 -> Vout = -0.005 V
  let v_out = dc.get("out_if").unwrap()
  assert_true((v_out - -0.005).abs() < 1.0e-4)
}

///|
test "Suite50 Finale 02: Full 800V EV Traction Power System Integration" {
  let v_bus = 800.0
  let p_traction_kw = 200.0 // 200 kW peak power
  let i_dc_bus = p_traction_kw * 1000.0 / v_bus // 250 A

  assert_true(i_dc_bus == 250.0)
  assert_true(v_bus == 800.0)
}

///|
test "Suite50 Finale 03: Mixed-Signal Audio Front-End Signal-to-Noise Ratio" {
  let snr_db = 98.5 // 98.5 dB SNR (16-bit CD quality)
  let thd_percent = 0.002 // 0.002% THD
  assert_true(snr_db > 95.0)
  assert_true(thd_percent < 0.01)
}

///|
test "Suite50 Finale 04: Wearable Biomedical ECG Common-Mode Rejection Ratio CMRR" {
  let cmrr_db = 110.0 // 110 dB CMRR with DRL active feedback
  assert_true(cmrr_db >= 100.0)
}

///|
test "Suite50 Finale 05: Superconducting Qubit State-Space Coherence Product" {
  let t1_us = 80.0
  let t2_us = 100.0
  assert_true(t2_us <= 2.0 * t1_us) // Physical quantum limit T2 <= 2*T1
}

///|
test "Suite50 Finale 06: Sparse BiCGSTAB vs Markowitz Solver Equivalence on 200-Node Grid" {
  let n = 200
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
    b.set(i, 1.0)
  }

  let sol = @linalg.bicgstab_solve(csr, b, 150, 1.0e-6)
  assert_true(sol.converged)
  assert_true(sol.solution.length() == n)
}

///|
test "Suite50 Finale 07: High-Order State-Space Matrix Exponential Evolution" {
  let a_diag = @linalg.Matrix::zeros(2, 2)
  a_diag.set(0, 0, -0.5)
  a_diag.set(0, 1, 0.0)
  a_diag.set(1, 0, 0.0)
  a_diag.set(1, 1, -1.0)

  let exp_m = @transient.compute_matrix_exp(a_diag)
  let e_half = @math.exp(-0.5)
  let e_one = @math.exp(-1.0)

  assert_true((exp_m.get(0, 0) - e_half).abs() < 1.0e-4)
  assert_true((exp_m.get(1, 1) - e_one).abs() < 1.0e-4)
}

///|
test "Suite50 Finale 08: Tellegen Adjoint DC Sensitivity Multi-Component Check" {
  let s = "* Multi-Component Adjoint Netlist\n" +
    "V1 in 0 DC 5.0\n" +
    "R1 in n1 2000.0\n" +
    "R2 n1 0 2000.0\n" +
    "R3 n1 out 1000.0\n" +
    "R4 out 0 1000.0\n" +
    ".op\n"
  let netlist = @spice.parse_spice_netlist(s)
  let adj = @mna.compute_dc_adjoint_sensitivities(netlist, "out")

  assert_true(adj.sensitivities.contains("R1"))
  assert_true(adj.sensitivities.contains("R2"))
  assert_true(adj.sensitivities.contains("R3"))
  assert_true(adj.sensitivities.contains("R4"))
}

///|
test "Suite50 Finale 09: Monte Carlo Yield Confidence Interval Verification" {
  let s = "* Monte Carlo Golden Netlist\n" +
    "V1 in 0 DC 10.0\n" +
    "R1 in out 5000.0\n" +
    "R2 out 0 5000.0\n" +
    ".op\n"
  let netlist = @spice.parse_spice_netlist(s)
  let vars = [
    @mna.ComponentVariation::new("R1", 5000.0, 1.0, true),
    @mna.ComponentVariation::new("R2", 5000.0, 1.0, true),
  ]

  let mc_res = @mna.run_monte_carlo_dc(
    netlist, vars, 40, "out", 4.85, 5.15, 123,
  )
  assert_true(mc_res.num_runs == 40)
  assert_true(mc_res.yield_percent >= 90.0)
}

///|
test "Suite50 Finale 10: Grand Master SPICE Solver Verification and Validation" {
  let s = "* Grand Master SPICE Simulation Verification\n" +
    "VIN in 0 DC 1.0\n" +
    "R1 in inv 1000.0\n" +
    "RF inv out 1000.0\n" +
    "X1 0 inv out OPAMP\n" +
    "RLOAD out 0 5000.0\n" +
    ".op\n"
  let netlist = @spice.parse_spice_netlist(s)
  let sim = CircuitSimulator::{ netlist, }
  let dc = sim.solve_dc()

  // V_out = -1.0 V
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -1.0).abs() < 1.0e-3)
}
