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
test "Suite75 Ultimate 01: Multi-Stage Cascaded Instrumentation Pipeline DC Sign-Off" {
  let netlist_str =
    #|* Master Ultimate EDA Sign-Off Netlist
    #|VIN in 0 DC 0.50
    #|* Stage 1: Differential Amplifier (Gain = 10)
    #|R1 in n1 1000.0
    #|RF1 n1 out1 10000.0
    #|X1 0 n1 out1 OPAMP
    #|* Stage 2: Sallen-Key Low Pass Filter Buffer
    #|R2 out1 n2 10000.0
    #|R3 n2 n3 10000.0
    #|C1 n2 out2 10e-9
    #|C2 n3 0 10e-9
    #|X2 n3 out2 out2 OPAMP
    #|* Stage 3: Inverting Output Scaler (Gain = -1)
    #|R4 out2 n4 2000.0
    #|RF2 n4 out3 2000.0
    #|X3 0 n4 out3 OPAMP
    #|RLOAD out3 0 10000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = @circuit.CircuitSimulator::new(netlist)
  let dc = sim.solve_dc()

  // Stage 1: -5.0V, Stage 2: -5.0V, Stage 3: +5.0V
  let v1 = dc.get("out1").unwrap()
  let v2 = dc.get("out2").unwrap()
  let v3 = dc.get("out3").unwrap()

  assert_true((v1 - -5.0).abs() < 1.0e-3)
  assert_true((v2 - -5.0).abs() < 1.0e-3)
  assert_true((v3 - 5.0).abs() < 1.0e-3)
}

///|
test "Suite75 Ultimate 02: Sparse 300-Node BiCGSTAB Convergence on Mesh Grid" {
  let n = 300
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

  let sol = @linalg.bicgstab_solve(csr, b, 200, 1.0e-6)
  assert_true(sol.converged)
  assert_true(sol.solution.length() == n)
}

///|
test "Suite75 Ultimate 03: GMRES 10-Iteration Convergence on 10x10 Convection Matrix" {
  let n = 10
  let a_mat = @linalg.Matrix::zeros(n, n)
  for i in 0..<n {
    a_mat.set(i, i, 4.0)
    if i > 0 {
      a_mat.set(i, i - 1, -1.0)
    }
    if i + 1 < n {
      a_mat.set(i, i + 1, -0.5)
    }
  }
  let b_vec = @linalg.Vector::zeros(n)
  for i in 0..<n {
    b_vec.set(i, 1.0)
  }

  let gmres_res = @linalg.gmres_solve(a_mat, b_vec, 10, 5, 1.0e-5)
  assert_true(gmres_res.converged)
}

///|
test "Suite75 Ultimate 04: Reverse Cuthill-McKee Bandwidth Optimization" {
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
test "Suite75 Ultimate 05: Padé [6/6] Matrix Exponential Evolution Verification" {
  let a_mat = @linalg.Matrix::zeros(2, 2)
  a_mat.set(0, 0, -2.0)
  a_mat.set(0, 1, 0.0)
  a_mat.set(1, 0, 0.0)
  a_mat.set(1, 1, -3.0)

  let exp_m = @transient.compute_matrix_exp(a_mat)
  let e_2 = @math.exp(-2.0)
  let e_3 = @math.exp(-3.0)

  assert_true((exp_m.get(0, 0) - e_2).abs() < 1.0e-4)
  assert_true((exp_m.get(1, 1) - e_3).abs() < 1.0e-4)
}

///|
test "Suite75 Ultimate 06: Tellegen Adjoint DC Sensitivity Multi-Node Ladder" {
  let s = "* Multi-Node Ladder Adjoint\n" +
    "V1 in 0 DC 10.0\n" +
    "R1 in n1 1000.0\n" +
    "R2 n1 n2 1000.0\n" +
    "R3 n2 0 1000.0\n" +
    "R4 n2 out 500.0\n" +
    "R5 out 0 500.0\n" +
    ".op\n"
  let netlist = @spice.parse_spice_netlist(s)
  let adj = @mna.compute_dc_adjoint_sensitivities(netlist, "out")

  assert_true(adj.sensitivities.contains("R1"))
  assert_true(adj.sensitivities.contains("R5"))
}

///|
test "Suite75 Ultimate 07: Monte Carlo Yield Robustness Envelope" {
  let s = "* MC Precision Robustness Netlist\n" +
    "V1 in 0 DC 5.0\n" +
    "R1 in out 10000.0\n" +
    "R2 out 0 10000.0\n" +
    ".op\n"
  let netlist = @spice.parse_spice_netlist(s)
  let vars = [
    @mna.ComponentVariation::new("R1", 10000.0, 0.5, true),
    @mna.ComponentVariation::new("R2", 10000.0, 0.5, true),
  ]

  let mc_res = @mna.run_monte_carlo_dc(
    netlist, vars, 50, "out", 2.45, 2.55, 999,
  )
  assert_true(mc_res.num_runs == 50)
  assert_true(mc_res.yield_percent >= 95.0)
}

///|
test "Suite75 Ultimate 08: 8th-Order Chebyshev Low-Pass Synthesis Stability" {
  let poles = @symbolic.synthesize_chebyshev1_poles(8, 0.1)
  assert_true(poles.length() == 8)
  for p in poles {
    assert_true(p.re < 0.0) // Strictly stable LHP poles
  }
}

///|
test "Suite75 Ultimate 09: Vector SVG Smith Chart Generation" {
  let gamma_pts = [
    @linalg.Complex::new(0.0, 0.0),
    @linalg.Complex::new(0.2, 0.1),
    @linalg.Complex::new(0.5, -0.2),
  ]
  let smith_svg = @visualizer.render_smith_chart_svg(
    gamma_pts, 400.0, "Ultimate S11 Trace",
  )
  assert_true(smith_svg.contains("Ultimate S11 Trace"))
  assert_true(smith_svg.contains("</svg>"))
}

///|
test "Suite75 Ultimate 10: Master Golden Benchmark Certification Sign-Off" {
  let netlist_str =
    #|* Master EDA Solver Grand Sign-Off
    #|VIN in 0 DC 2.0
    #|R1 in inv 1000.0
    #|RF inv out 5000.0
    #|X1 0 inv out OPAMP
    #|RLOAD out 0 10000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = @circuit.CircuitSimulator::new(netlist)
  let dc = sim.solve_dc()

  // V_out = -10.0 V
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -10.0).abs() < 1.0e-3)
}
