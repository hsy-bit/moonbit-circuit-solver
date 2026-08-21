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
test "Deep Test 01: DC Adjoint Sensitivity on Bridge Network" {
  let netlist_str =
    #|* Bridge Sensitivity Netlist
    #|V1 in 0 DC 10.0
    #|R1 in out 1000.0
    #|R2 out 0 1000.0
    #|.op
  let netlist = @spice.parse_spice_netlist(netlist_str)
  let adj_res = @mna.compute_dc_adjoint_sensitivities(netlist, "out")

  assert_true(adj_res.target_node == "out")
  assert_true(adj_res.sensitivities.contains("R1"))
  assert_true(adj_res.sensitivities.contains("R2"))

  // For Vout = 10 * R2 / (R1 + R2): dVout/dR2 = 10 * R1 / (R1+R2)^2 = 10*1000/4000000 = 0.0025 V/Ohm
  let s_r2 = adj_res.sensitivities.get("R2").unwrap()
  assert_true((s_r2 - 0.0025).abs() < 1.0e-5)
}

///|
test "Deep Test 02: Cash-Karp Adaptive RK Step on Exponential Decay" {
  // dy/dt = -10 * y
  let f_decay = fn(_t : Double, y : @linalg.Vector) -> @linalg.Vector {
    let res = @linalg.Vector::zeros(1)
    res.set(0, -10.0 * y.get(0))
    res
  }

  let y0 = @linalg.Vector::zeros(1)
  y0.set(0, 1.0)

  let step = @transient.cash_karp_step(f_decay, 0.0, y0, 0.01, 1.0e-4, 1.0e-6)
  assert_true(step.is_accepted)
  assert_true(step.error_estimate < 1.0e-4)

  // y(0.01) exact = exp(-0.1) approx 0.904837
  let y1 = step.y_next.get(0)
  assert_true((y1 - 0.904837).abs() < 1.0e-4)
}

///|
test "Deep Test 03: Chebyshev Type I Filter Poles Synthesis (n=4, 0.5dB ripple)" {
  let poles = @symbolic.synthesize_chebyshev1_poles(4, 0.5)
  assert_true(poles.length() == 4)

  for p in poles {
    // All poles must be in Left Half Plane
    assert_true(p.re < 0.0)
  }
}

///|
test "Deep Test 04: Reverse Bessel Polynomials for Linear Phase Filters" {
  let b2 = @symbolic.generate_bessel_polynomial(2)
  let b3 = @symbolic.generate_bessel_polynomial(3)

  // B_2(s) = s^2 + 3s + 3
  assert_true(b2.degree() == 2)
  assert_true((b2.coeff(0) - 3.0).abs() < 1.0e-12)
  assert_true((b2.coeff(1) - 3.0).abs() < 1.0e-12)
  assert_true((b2.coeff(2) - 1.0).abs() < 1.0e-12)

  // B_3(s) = s^3 + 6s^2 + 15s + 15
  assert_true(b3.degree() == 3)
  assert_true((b3.coeff(0) - 15.0).abs() < 1.0e-12)
  assert_true((b3.coeff(1) - 15.0).abs() < 1.0e-12)
  assert_true((b3.coeff(2) - 6.0).abs() < 1.0e-12)
  assert_true((b3.coeff(3) - 1.0).abs() < 1.0e-12)
}

///|
test "Deep Test 05: Successive Over-Relaxation SOR Solver on Diagonally Dominant Matrix" {
  let a_mat = @linalg.Matrix::zeros(3, 3)
  a_mat.set(0, 0, 4.0)
  a_mat.set(0, 1, -1.0)
  a_mat.set(0, 2, 0.0)
  a_mat.set(1, 0, -1.0)
  a_mat.set(1, 1, 4.0)
  a_mat.set(1, 2, -1.0)
  a_mat.set(2, 0, 0.0)
  a_mat.set(2, 1, -1.0)
  a_mat.set(2, 2, 4.0)

  let b_vec = @linalg.Vector::zeros(3)
  b_vec.set(0, 3.0)
  b_vec.set(1, 2.0)
  b_vec.set(2, 3.0)

  let sor_res = @linalg.sor_solve(a_mat, b_vec, 1.15, 100, 1.0e-6)
  assert_true(sor_res.converged)

  // Exact solution is x = [1.0, 1.0, 1.0]
  assert_true((sor_res.solution.get(0) - 1.0).abs() < 1.0e-4)
  assert_true((sor_res.solution.get(1) - 1.0).abs() < 1.0e-4)
  assert_true((sor_res.solution.get(2) - 1.0).abs() < 1.0e-4)
}

///|
test "Deep Test 06: Cholesky Factorization A = L * L^T on Symmetric Positive Definite Matrix" {
  let a_mat = @linalg.Matrix::zeros(2, 2)
  a_mat.set(0, 0, 4.0)
  a_mat.set(0, 1, 1.0)
  a_mat.set(1, 0, 1.0)
  a_mat.set(1, 1, 3.0)

  let chol = @linalg.CholeskyDecomposition::decompose(a_mat)
  assert_true(chol.n == 2)

  let b = @linalg.Vector::zeros(2)
  b.set(0, 5.0)
  b.set(1, 4.0)

  let x = chol.solve(b)
  assert_true(x.length() == 2)
  let res = a_mat.multiply_vector(x).sub(b).norm_l2()
  assert_true(res < 1.0e-5)
}

///|
test "Deep Test 07: Matrix Infinity Norm Computation" {
  let a_mat = @linalg.Matrix::zeros(2, 2)
  a_mat.set(0, 0, -3.0)
  a_mat.set(0, 1, 5.0) // Row sum = 8
  a_mat.set(1, 0, 2.0)
  a_mat.set(1, 1, -4.0) // Row sum = 6

  let norm_inf = @linalg.matrix_norm_inf(a_mat)
  assert_true((norm_inf - 8.0).abs() < 1.0e-12)
}
