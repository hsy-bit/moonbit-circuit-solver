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
test "Krylov Solvers: FGMRES, TFQMR, and MINRES on sparse systems" {
  let n = 8
  let builder = SparseBuilder::new(n, n)
  for i in 0..<n {
    builder.add_entry(i, i, 6.0)
    if i > 0 {
      builder.add_entry(i, i - 1, -1.5)
    }
    if i + 1 < n {
      builder.add_entry(i, i + 1, -1.5)
    }
  }

  let csr = builder.to_csr()
  let b = Vector::zeros(n)
  for i in 0..<n {
    b.set(i, (i + 1).to_double() * 2.0)
  }

  // 1. Test FGMRES
  let fgmres_res = fgmres_solve(csr, b, 5, 20, 1.0e-8)
  assert_true(fgmres_res.converged)
  let ax_f = csr.multiply_vector(fgmres_res.solution)
  assert_true(ax_f.sub(b).norm_l2() < 1.0e-6)

  // 2. Test TFQMR
  let tfqmr_res = tfqmr_solve(csr, b, 50, 1.0e-4)
  assert_true(tfqmr_res.solution.length() == n)
  assert_true(tfqmr_res.iterations > 0)

  // 3. Test MINRES (symmetric system)
  let minres_res = minres_solve(csr, b, 50, 1.0e-4)
  assert_true(minres_res.solution.length() == n)
  assert_true(minres_res.iterations > 0)
}

///|
test "Preconditioners: Incomplete Cholesky IC0, Block Jacobi, and SSOR" {
  let n = 6
  let mat = Matrix::zeros(n, n)
  for i in 0..<n {
    mat.set(i, i, 5.0)
    if i > 0 {
      mat.set(i, i - 1, -1.0)
      mat.set(i - 1, i, -1.0)
    }
  }

  let csr = CsrMatrix::from_dense(mat)
  let r = Vector::zeros(n)
  for i in 0..<n {
    r.set(i, 1.0)
  }

  // 1. IC(0) Preconditioner application
  let ic0 = IncompleteCholeskyPreconditioner::new(csr)
  let z_ic0 = ic0.apply(r)
  assert_true(z_ic0.length() == n)
  assert_true(z_ic0.norm_l2() > 0.0)

  // 2. Block Jacobi Preconditioner
  let bj = BlockJacobiPreconditioner::new(mat, 2)
  let z_bj = bj.apply(r)
  assert_true(z_bj.length() == n)
  assert_true(z_bj.norm_l2() > 0.0)

  // 3. SSOR Preconditioner
  let ssor = SsorPreconditioner::new(mat, 1.2)
  let z_ssor = ssor.apply(r)
  assert_true(z_ssor.length() == n)
  assert_true(z_ssor.norm_l2() > 0.0)
}

///|
test "Advanced Eigenvalue: Francis QR algorithm and Arnoldi iteration" {
  // Test 3x3 matrix with known eigenvalues [1, 2, 3]
  // Characteristic matrix: upper triangular with diagonal 1, 2, 3
  let mat = Matrix::zeros(3, 3)
  mat.set(0, 0, 1.0)
  mat.set(0, 1, 2.0)
  mat.set(0, 2, 4.0)
  mat.set(1, 0, 0.0)
  mat.set(1, 1, 2.0)
  mat.set(1, 2, -1.0)
  mat.set(2, 0, 0.0)
  mat.set(2, 1, 0.0)
  mat.set(2, 2, 3.0)

  let spec = francis_qr_eigenvalues(mat, 50, 1.0e-10)
  assert_true(spec.is_converged)
  assert_true(spec.eigenvalues.length() == 3)

  // Check that eigenvalues 1, 2, 3 are present
  let mut has1 = false
  let mut has2 = false
  let mut has3 = false
  for i in 0..<3 {
    let re = spec.eigenvalues[i].re
    if (re - 1.0).abs() < 0.1 {
      has1 = true
    }
    if (re - 2.0).abs() < 0.1 {
      has2 = true
    }
    if (re - 3.0).abs() < 0.1 {
      has3 = true
    }
  }
  assert_true(has1 && has2 && has3)

  // Test Arnoldi iteration
  let csr = CsrMatrix::from_dense(mat)
  let (h_arnoldi, q_basis) = arnoldi_iteration(csr, 2)
  assert_true(h_arnoldi.num_rows() == 3)
  assert_true(h_arnoldi.num_cols() == 2)
  assert_true(q_basis.length() >= 1)
}

///|
test "Hager-Higham condition estimator and matrix equilibration" {
  // Construct ill-conditioned 3x3 matrix with scaling disparity
  let mat = Matrix::zeros(3, 3)
  mat.set(0, 0, 1.0e6)
  mat.set(0, 1, 2.0e6)
  mat.set(0, 2, 0.0)
  mat.set(1, 0, 0.0)
  mat.set(1, 1, 1.0e-3)
  mat.set(1, 2, 2.0e-3)
  mat.set(2, 0, 1.0)
  mat.set(2, 1, 0.0)
  mat.set(2, 2, 1.0)

  let cond_est = estimate_condition_1norm(mat, 5)
  assert_true(cond_est > 1.0e5)

  let eq_res = equilibrate_matrix(mat)
  assert_true(eq_res.condition_improvement >= 1.0)
  assert_true(eq_res.scaled_mat.num_rows() == 3)
}
