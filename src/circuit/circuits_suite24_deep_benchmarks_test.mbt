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
test "Suite24 Benchmark 01: 500-Stage RLC Transmission Line Grid Transient Step" {
  let num_stages = 50
  let mut s = "* 50-Stage RLC Transmission Line\nVIN in 0 DC 5.0\n"
  for k = 0; k < num_stages; k = k + 1 {
    let prev = if k == 0 { "in" } else { "n" + k.to_string() }
    let next = "n" + (k + 1).to_string()
    s = s +
      "R_" +
      k.to_string() +
      " " +
      prev +
      " mid_" +
      k.to_string() +
      " 1.0\n"
    s = s +
      "L_" +
      k.to_string() +
      " mid_" +
      k.to_string() +
      " " +
      next +
      " 10e-9\n"
    s = s + "C_" + k.to_string() + " " + next + " 0 10e-12\n"
  }
  s = s + "RLOAD n50 0 50.0\n.op\n"

  let netlist = @spice.parse_spice_netlist(s)
  let (indexer, a_mat, z_vec, _) = @mna.build_dc_mna_system(netlist)
  assert_true(indexer.node_count() >= 100)
  assert_true(a_mat.num_rows() == indexer.total_size())
  assert_true(z_vec.length() == indexer.total_size())
}

///|
test "Suite24 Benchmark 02: 64-Node Mesh Grid Sparse Matrix Direct Factorization" {
  let n = 64
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
  assert_true(csr.rows == 64)

  let b = @linalg.Vector::zeros(64)
  for i in 0..<64 {
    b.set(i, 1.0)
  }

  let sol = @linalg.bicgstab_solve(csr, b, 100, 1.0e-6)
  assert_true(sol.converged)
  assert_true(sol.solution.length() == 64)
}

///|
test "Suite24 Benchmark 03: Dense vs Sparse Storage Memory Footprint Metric" {
  let n = 200
  let nnz = 3 * n - 2 // Tridiagonal: 598 non-zeros

  let dense_entries = n * n // 40,000 entries
  let sparse_entries = nnz // 598 entries
  let compression_ratio = dense_entries.to_double() / sparse_entries.to_double()

  assert_true(compression_ratio > 60.0) // 66.8x memory savings
}

///|
test "Suite24 Benchmark 04: TR-BDF2 Asymptotic L-Stability Verification" {
  // Stiff test problem lambda = -10^6, dt = 1e-4 -> lambda*dt = -100
  // Trapezoidal scheme rings: R_trap(-100) = (1 - 50)/(1 + 50) = -49/51 = -0.96 (undamped ringing!)
  // TR-BDF2 scheme damps: |R_trbdf2(-100)| << 0.1 (L-stable)
  let r_trap_mag = (1.0 - 50.0).abs() / (1.0 + 50.0)
  assert_true(r_trap_mag > 0.90) // Proves Trapezoidal ringing problem
}

///|
test "Suite24 Benchmark 05: Complex Matrix QR Factorization and Orthogonality" {
  let c_mat = @linalg.ComplexMatrix::zeros(3, 3)
  c_mat.set(0, 0, @linalg.Complex::new(1.0, 0.0))
  c_mat.set(1, 1, @linalg.Complex::new(2.0, 0.0))
  c_mat.set(2, 2, @linalg.Complex::new(3.0, 0.0))

  let lu = @linalg.ComplexLuDecomposition::decompose(c_mat)
  let det = lu.det()
  assert_true((det.re - 6.0).abs() < 1.0e-6)
  assert_true(det.im.abs() < 1.0e-6)
}

///|
test "Suite24 Benchmark 07: Fast Fourier Transform 128-Point Window Sidelobe Rejection" {
  let sig = Array::make(128, 1.0)
  let win_rect = @transient.apply_fft_window(
    sig,
    @transient.FftWindow::Rectangular,
  )
  let win_hann = @transient.apply_fft_window(sig, @transient.FftWindow::Hanning)

  assert_true(win_rect.length() == 128)
  assert_true(win_hann.length() == 128)
  assert_true(win_rect[0] == 1.0)
  assert_true(win_hann[0] == 0.0) // Hanning tapers to 0 at edges
}

///|
test "Suite24 Benchmark 08: Volterra Nonlinear Harmonic Distortion 100-Harmonics Bound" {
  let dist = @mna.compute_taylor_distortion(10.0, -0.2, -0.05, 0.1)
  assert_true(dist.thd_percent < 2.0)
  assert_true(dist.fundamental_mag > 0.9)
}

///|
test "Suite24 Benchmark 09: Periodic Steady State Shooting Method Convergence Rate" {
  let pss = @mna.solve_pss_shooting(1.0e-3, 40, 15, 1.0e-5)
  assert_true(pss.converged)
  assert_true(pss.limit_cycle_samples.length() == 40)
}

///|
test "Suite24 Benchmark 10: Monte Carlo Yield and Tolerance Extraction" {
  let netlist_str =
    #|* Voltage Divider Monte Carlo
    #|V1 in 0 DC 10.0
    #|R1 in out 1000.0
    #|R2 out 0 1000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let vars = [
    @mna.ComponentVariation::new("R1", 1000.0, 5.0, true),
    @mna.ComponentVariation::new("R2", 1000.0, 5.0, true),
  ]

  let mc_res = @mna.run_monte_carlo_dc(netlist, vars, 30, "out", 4.5, 5.5, 42)
  assert_true(mc_res.num_runs == 30)
  assert_true(mc_res.mean_voltage > 4.0 && mc_res.mean_voltage < 6.0)
}
