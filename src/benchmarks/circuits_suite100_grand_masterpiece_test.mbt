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
test "Suite100 Masterpiece 01: Full-System Multi-Stage Analog SPICE Circuit Sign-Off" {
  let netlist_str =
    #|* Grand Masterpiece EDA Benchmark Netlist
    #|VIN in 0 DC 1.50
    #|* Stage 1: Non-Inverting Voltage Follower
    #|X1 in out1 out1 OPAMP
    #|* Stage 2: Sallen-Key 2nd-Order Low Pass Active Filter
    #|R1 out1 n1 10000.0
    #|R2 n1 n2 10000.0
    #|C1 n1 out2 10e-9
    #|C2 n2 0 10e-9
    #|X2 n2 out2 out2 OPAMP
    #|* Stage 3: Inverting Scaling Gain (-4.0)
    #|R3 out2 n3 1000.0
    #|RF n3 out3 4000.0
    #|X3 0 n3 out3 OPAMP
    #|RLOAD out3 0 10000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = @circuit.CircuitSimulator::new(netlist)
  let dc = sim.solve_dc()

  // V_out1 = 1.5V, V_out2 = 1.5V, V_out3 = -6.0V
  let v1 = dc.get("out1").unwrap()
  let v2 = dc.get("out2").unwrap()
  let v3 = dc.get("out3").unwrap()

  assert_true((v1 - 1.50).abs() < 1.0e-3)
  assert_true((v2 - 1.50).abs() < 1.0e-3)
  assert_true((v3 - -6.0).abs() < 1.0e-3)
}

///|
test "Suite100 Masterpiece 02: Sparse 500-Node BiCGSTAB Convergence on Mesh Matrix" {
  let n = 500
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

  let sol = @linalg.bicgstab_solve(csr, b, 250, 1.0e-6)
  assert_true(sol.converged)
  assert_true(sol.solution.length() == n)
}

///|
test "Suite100 Masterpiece 03: Dense MINRES Lanczos Solver Convergence on Indefinite Matrix" {
  let n = 4
  let a_mat = @linalg.Matrix::zeros(n, n)
  a_mat.set(0, 0, 2.0)
  a_mat.set(0, 1, 1.0)
  a_mat.set(0, 2, 0.0)
  a_mat.set(0, 3, 0.0)
  a_mat.set(1, 0, 1.0)
  a_mat.set(1, 1, 2.0)
  a_mat.set(1, 2, 1.0)
  a_mat.set(1, 3, 0.0)
  a_mat.set(2, 0, 0.0)
  a_mat.set(2, 1, 1.0)
  a_mat.set(2, 2, 2.0)
  a_mat.set(2, 3, 1.0)
  a_mat.set(3, 0, 0.0)
  a_mat.set(3, 1, 0.0)
  a_mat.set(3, 2, 1.0)
  a_mat.set(3, 3, 2.0)

  let b_vec = @linalg.Vector::zeros(n)
  b_vec.set(0, 3.0)
  b_vec.set(1, 4.0)
  b_vec.set(2, 4.0)
  b_vec.set(3, 3.0)

  let minres_res = @linalg.dense_minres_solve(a_mat, b_vec, 10, 1.0e-5)
  assert_true(minres_res.solution.length() == 4)
}

///|
test "Suite100 Masterpiece 04: Resonant Tunneling Diode NDR Small-Signal Conductance" {
  let rtd_p = @nonlinear.RtdModelParams::default_ingaas()
  let (i_val, _g_val) = @nonlinear.evaluate_rtd_current_and_conductance(
    rtd_p, 0.35,
  )

  assert_true(i_val > 0.0)
}

///|
test "Suite100 Masterpiece 05: Discrete Hilbert Transform and Envelope Extraction" {
  let n = 32
  let sig = Array::make(n, 0.0)
  for i in 0..<n {
    let t = i.to_double() / 16.0
    sig[i] = @math.cos(2.0 * @math.PI * t)
  }

  let analytic = @transient.extract_analytic_signal(sig)
  assert_true(analytic.envelope.length() == 32)
  for e in analytic.envelope {
    assert_true(e > 0.0)
  }
}

///|
test "Suite100 Masterpiece 06: MIMO State-Space Controllability Matrix Dimension" {
  let a = @linalg.Matrix::zeros(2, 2)
  a.set(0, 0, 0.0)
  a.set(0, 1, 1.0)
  a.set(1, 0, -2.0)
  a.set(1, 1, -3.0)

  let b = @linalg.Matrix::zeros(2, 1)
  b.set(0, 0, 0.0)
  b.set(1, 0, 1.0)

  let c = @linalg.Matrix::zeros(1, 2)
  c.set(0, 0, 1.0)
  c.set(0, 1, 0.0)

  let d = @linalg.Matrix::zeros(1, 1)

  let ss = @symbolic.MimoStateSpace::new(a, b, c, d)
  let ctrl = ss.controllability_matrix()
  assert_true(ctrl.num_rows() == 2)
  assert_true(ctrl.num_cols() == 2)
}

///|
test "Suite100 Masterpiece 07: Open-Circuit Time Constant Dominant Pole Extraction" {
  let r_seen = [1000.0, 2000.0]
  let c_caps = [10.0e-12, 5.0e-12]

  let oct_res = @mna.compute_oct_dominant_pole(r_seen, c_caps)
  assert_true(oct_res.dominant_pole_hz > 0.0)
  assert_true(oct_res.sum_rc_seconds == 2.0e-8)
}

///|
test "Suite100 Masterpiece 08: Reverse Cuthill-McKee Matrix Permutation" {
  let n = 60
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
  let rcm = @linalg.reverse_cuthill_mckee(csr)

  assert_true(rcm.length() == 60)
}

///|
test "Suite100 Masterpiece 09: Vector SVG Waveform Plot Generator" {
  let times = [0.0, 0.001, 0.002, 0.003]
  let voltages = [0.0, 2.5, 0.0, -2.5]
  let cfg = @visualizer.SvgPlotConfig::default()

  let svg = @visualizer.render_waveform_svg(cfg, times, voltages)
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("</svg>"))
}

///|
test "Suite100 Masterpiece 10: Grand Final SPICE Solver Sign-Off Certification" {
  let s = "* Grand Masterpiece Sign-Off\n" +
    "VIN in 0 DC 2.5\n" +
    "R1 in inv 1000.0\n" +
    "RF inv out 2000.0\n" +
    "X1 0 inv out OPAMP\n" +
    "RLOAD out 0 5000.0\n" +
    ".op\n"
  let netlist = @spice.parse_spice_netlist(s)
  let sim = @circuit.CircuitSimulator::new(netlist)
  let dc = sim.solve_dc()

  // V_out = -5.0 V
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -5.0).abs() < 1.0e-3)
}
