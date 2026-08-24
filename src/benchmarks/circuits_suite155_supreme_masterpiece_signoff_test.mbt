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
test "Suite155 Supreme 01: Multi-Stage OpAmp Pipeline Stage-by-Stage DC Output" {
  let netlist_str =
    #|* Supreme OpAmp Pipeline
    #|VIN in 0 DC 2.0
    #|* Stage 1: Non-Inverting Buffer
    #|X1 in out1 out1 OPAMP
    #|* Stage 2: Sallen-Key Low Pass Filter
    #|R1 out1 n1 10000.0
    #|R2 n1 n2 10000.0
    #|C1 n1 out2 10e-9
    #|C2 n2 0 10e-9
    #|X2 n2 out2 out2 OPAMP
    #|* Stage 3: Inverting Scaling Gain (-4.0)
    #|R3 out2 n3 1000.0
    #|RF3 n3 out3 4000.0
    #|X3 0 n3 out3 OPAMP
    #|RLOAD out3 0 10000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = @circuit.CircuitSimulator::new(netlist)
  let dc = sim.solve_dc()

  // Stage 1: 2.0V, Stage 2: 2.0V, Stage 3: -8.0V
  let v1 = dc.get("out1").unwrap()
  let v2 = dc.get("out2").unwrap()
  let v3 = dc.get("out3").unwrap()

  assert_true((v1 - 2.0).abs() < 1.0e-3)
  assert_true((v2 - 2.0).abs() < 1.0e-3)
  assert_true((v3 - -8.0).abs() < 1.0e-3)
}

///|
test "Suite155 Supreme 02: Sparse 6000-Node BiCGSTAB Solver on Large Grid" {
  let n = 6000
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

  let sol = @linalg.bicgstab_solve(csr, b, 2500, 1.0e-5)
  assert_true(sol.converged)
  assert_true(sol.solution.length() == n)
}

///|
test "Suite155 Supreme 03: 26th-Order Chebyshev Low-Pass Synthesis Stability" {
  let poles = @symbolic.synthesize_chebyshev1_poles(26, 0.01)
  assert_true(poles.length() == 26)
  for p in poles {
    assert_true(p.re < 0.0) // Strictly LHP
  }
}

///|
test "Suite155 Supreme 04: Reverse Cuthill-McKee Matrix Permutation on 2000-Node Band" {
  let n = 2000
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

  assert_true(rcm.length() == 2000)
}

///|
test "Suite155 Supreme 05: Padé [6/6] Matrix Exponential Evolution Verification" {
  let a_mat = @linalg.Matrix::zeros(2, 2)
  a_mat.set(0, 0, -10.0)
  a_mat.set(0, 1, 0.0)
  a_mat.set(1, 0, 0.0)
  a_mat.set(1, 1, -11.0)

  let exp_m = @transient.compute_matrix_exp(a_mat)
  let e_10 = @math.exp(-10.0)
  let e_11 = @math.exp(-11.0)

  assert_true((exp_m.get(0, 0) - e_10).abs() < 1.0e-4)
  assert_true((exp_m.get(1, 1) - e_11).abs() < 1.0e-4)
}

///|
test "Suite155 Supreme 06: Tellegen Adjoint DC Sensitivity Multi-Node Ladder Network" {
  let s = "* Multi-Node Adjoint Grid\n" +
    "V1 in 0 DC 40.0\n" +
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
test "Suite155 Supreme 07: Monte Carlo Yield Confidence Interval Verification" {
  let s = "* Monte Carlo Verification Netlist\n" +
    "V1 in 0 DC 10.0\n" +
    "R1 in out 10000.0\n" +
    "R2 out 0 10000.0\n" +
    ".op\n"
  let netlist = @spice.parse_spice_netlist(s)
  let vars = [
    @mna.ComponentVariation::new("R1", 10000.0, 0.5, true),
    @mna.ComponentVariation::new("R2", 10000.0, 0.5, true),
  ]

  let mc = @mna.run_monte_carlo_dc(netlist, vars, 50, "out", 4.90, 5.10, 999)
  assert_true(mc.num_runs == 50)
  assert_true(mc.yield_percent >= 95.0)
}

///|
test "Suite155 Supreme 08: Vector SVG Smith Chart Generation with S11 Locus" {
  let gamma_pts = [
    @linalg.Complex::new(0.0, 0.0),
    @linalg.Complex::new(0.2, 0.7),
    @linalg.Complex::new(0.6, -0.3),
  ]
  let smith_svg = @visualizer.render_smith_chart_svg(
    gamma_pts, 400.0, "Supreme S11 Locus",
  )
  assert_true(smith_svg.contains("Supreme S11 Locus"))
  assert_true(smith_svg.contains("</svg>"))
}

///|
test "Suite155 Supreme 09: Vector SVG Waveform Exporter Multi-Point Output" {
  let t_pts = [0.0, 0.001, 0.002, 0.003]
  let v_pts = [0.0, 8.0, 0.0, -8.0]
  let cfg = @visualizer.SvgPlotConfig::default()

  let svg = @visualizer.render_waveform_svg(cfg, t_pts, v_pts)
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("</svg>"))
}

///|
test "Suite155 Supreme 10: Grand Final SPICE Solver Verification Validation" {
  let netlist_str =
    #|* Master EDA Solver Verification Netlist
    #|VIN in 0 DC 3.0
    #|R1 in inv 1000.0
    #|RF inv out 5000.0
    #|X1 0 inv out OPAMP
    #|RLOAD out 0 5000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = @circuit.CircuitSimulator::new(netlist)
  let dc = sim.solve_dc()

  // V_out = -15.0 V
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -15.0).abs() < 1.0e-3)
}
