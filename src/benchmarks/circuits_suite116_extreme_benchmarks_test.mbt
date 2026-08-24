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
test "Suite116 Extreme 01: 600-Node 1D Resistor Grid Sparse BiCGSTAB Benchmark" {
  let n = 600
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

  let sol = @linalg.bicgstab_solve(csr, b, 300, 1.0e-6)
  assert_true(sol.converged)
  assert_true(sol.solution.length() == n)
}

///|
test "Suite116 Extreme 02: 1000-Node Pentadiagonal Sparse Matrix Benchmark" {
  let n = 1000
  let builder = @linalg.SparseBuilder::new(n, n)
  for i in 0..<n {
    builder.add_entry(i, i, 6.0)
    if i > 0 {
      builder.add_entry(i, i - 1, -1.0)
    }
    if i + 1 < n {
      builder.add_entry(i, i + 1, -1.0)
    }
    if i > 1 {
      builder.add_entry(i, i - 2, -0.5)
    }
    if i + 2 < n {
      builder.add_entry(i, i + 2, -0.5)
    }
  }
  let csr = builder.to_csr()
  let b = @linalg.Vector::zeros(n)
  for i in 0..<n {
    b.set(i, 1.0)
  }

  let sol = @linalg.bicgstab_solve(csr, b, 400, 1.0e-5)
  assert_true(sol.converged)
  assert_true(sol.solution.length() == n)
}

///|
test "Suite116 Extreme 03: 150x150 Dense Complex LU Linear System Solver" {
  let n = 150
  let mat = @linalg.ComplexMatrix::zeros(n, n)
  for i in 0..<n {
    mat.set(i, i, @linalg.Complex::new(5.0, 1.0))
    if i > 0 {
      mat.set(i, i - 1, @linalg.Complex::new(-1.0, 0.5))
    }
    if i + 1 < n {
      mat.set(i, i + 1, @linalg.Complex::new(-1.0, -0.5))
    }
  }
  let b = @linalg.ComplexVector::zeros(n)
  for i in 0..<n {
    b.set(i, @linalg.Complex::new(1.0, 0.0))
  }

  let lu = @linalg.ComplexLuDecomposition::decompose(mat)
  let x = lu.solve(b)
  assert_true(x.length() == n)
}

///|
test "Suite116 Extreme 04: Reverse Cuthill-McKee Bandwidth Reduction on 200-Node Band" {
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
  let rcm = @linalg.reverse_cuthill_mckee(csr)
  let band = @linalg.compute_matrix_bandwidth(csr, rcm)

  assert_true(rcm.length() == n)
  assert_true(band <= 2)
}

///|
test "Suite116 Extreme 05: Padé [6/6] Matrix Exponential on 4x4 Stiff Jordan Block" {
  let a_mat = @linalg.Matrix::zeros(4, 4)
  for i in 0..<4 {
    a_mat.set(i, i, -(i + 1).to_double())
  }
  let exp_m = @transient.compute_matrix_exp(a_mat)

  for i in 0..<4 {
    let expected = @math.exp(-(i + 1).to_double())
    assert_true((exp_m.get(i, i) - expected).abs() < 1.0e-4)
  }
}

///|
test "Suite116 Extreme 06: Fast Fourier Transform 128-Point THD Analysis" {
  let num_pts = 128
  let f_fund = 1000.0
  let times = Array::make(num_pts, 0.0)
  let sig = Array::make(num_pts, 0.0)

  for i in 0..<num_pts {
    let t = i.to_double() / (128.0 * f_fund)
    times[i] = t
    sig[i] = @math.sin(2.0 * @math.PI * f_fund * t) +
      0.03 * @math.sin(4.0 * @math.PI * f_fund * t)
  }

  let fft_res = @transient.compute_transient_fft_analysis(
    times,
    sig,
    f_fund,
    @transient.FftWindow::Hanning,
  )
  assert_true(fft_res.thd_percent > 0.0)
  assert_true(fft_res.harmonics.length() > 0)
}

///|
test "Suite116 Extreme 07: Tellegen Adjoint DC Sensitivity Multi-Node Ladder Network" {
  let s = "* Multi-Node Adjoint Grid\n" +
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
test "Suite116 Extreme 08: Monte Carlo Tolerance Envelope 100-Run Yield Verification" {
  let s = "* 100-Run MC Netlist\n" +
    "V1 in 0 DC 10.0\n" +
    "R1 in out 2000.0\n" +
    "R2 out 0 2000.0\n" +
    ".op\n"
  let netlist = @spice.parse_spice_netlist(s)
  let vars = [
    @mna.ComponentVariation::new("R1", 2000.0, 0.5, true),
    @mna.ComponentVariation::new("R2", 2000.0, 0.5, true),
  ]

  let mc = @mna.run_monte_carlo_dc(netlist, vars, 100, "out", 4.90, 5.10, 888)
  assert_true(mc.num_runs == 100)
  assert_true(mc.yield_percent >= 95.0)
}

///|
test "Suite116 Extreme 09: Vector SVG Waveform Exporter Multi-Point Output" {
  let t_pts = [0.0, 0.001, 0.002, 0.003, 0.004]
  let v_pts = [0.0, 3.3, 0.0, -3.3, 0.0]
  let cfg = @visualizer.SvgPlotConfig::default()

  let svg = @visualizer.render_waveform_svg(cfg, t_pts, v_pts)
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("</svg>"))
}

///|
test "Suite116 Extreme 10: Multi-Stage OpAmp Linear Solver Verification" {
  let netlist_str =
    #|* Extreme Multi-Stage Verification Netlist
    #|VIN in 0 DC 2.5
    #|R1 in inv 1000.0
    #|RF inv out 2000.0
    #|X1 0 inv out OPAMP
    #|RLOAD out 0 5000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let sim = @circuit.CircuitSimulator::new(netlist)
  let dc = sim.solve_dc()

  // V_out = -5.0 V
  let v_out = dc.get("out").unwrap()
  assert_true((v_out - -5.0).abs() < 1.0e-3)
}
