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
/// Generates Hilbert Matrix H_ij = 1 / (i + j + 1) for ill-conditioned benchmarks.
pub fn generate_hilbert_matrix(n : Int) -> Matrix {
  let mat = Matrix::zeros(n, n)
  for i in 0..<n {
    for j in 0..<n {
      let v = 1.0 / (i + j + 1).to_double()
      mat.set(i, j, v)
    }
  }
  mat
}

///|
/// Generates Vandermonde Matrix V_ij = x_i^j.
pub fn generate_vandermonde_matrix(x_points : Array[Double]) -> Matrix {
  let n = x_points.length()
  let mat = Matrix::zeros(n, n)
  for i in 0..<n {
    let mut x_pow = 1.0
    for j in 0..<n {
      mat.set(i, j, x_pow)
      x_pow = x_pow * x_points[i]
    }
  }
  mat
}

///|
/// Generates Symmetric Toeplitz Matrix T_ij = r_|i-j|.
pub fn generate_toeplitz_matrix(r_row : Array[Double]) -> Matrix {
  let n = r_row.length()
  let mat = Matrix::zeros(n, n)
  for i in 0..<n {
    for j in 0..<n {
      let diff = if i >= j { i - j } else { j - i }
      mat.set(i, j, r_row[diff])
    }
  }
  mat
}

///|
/// Generates 2D 5-Point Laplacian Grid Matrix for an (m x m) spatial domain.
pub fn generate_laplacian_2d_csr(m : Int) -> CsrMatrix {
  let n = m * m
  let builder = SparseBuilder::new(n, n)

  for r in 0..<m {
    for c in 0..<m {
      let idx = r * m + c
      builder.add_entry(idx, idx, 4.0)

      if c > 0 {
        builder.add_entry(idx, idx - 1, -1.0)
      }
      if c + 1 < m {
        builder.add_entry(idx, idx + 1, -1.0)
      }
      if r > 0 {
        builder.add_entry(idx, idx - m, -1.0)
      }
      if r + 1 < m {
        builder.add_entry(idx, idx + m, -1.0)
      }
    }
  }

  builder.to_csr()
}

///|
test "Hilbert Matrix Ill-Conditioned Factorization Benchmark N=6" {
  let h6 = generate_hilbert_matrix(6)
  assert_true(h6.num_rows() == 6)
  assert_true(h6.num_cols() == 6)

  let b = Vector::zeros(6)
  for i in 0..<6 {
    b.set(i, 1.0)
  }

  let lu = LuDecomposition::decompose(h6)
  let sol = lu.solve(b)
  assert_true(sol.length() == 6)

  // Verify residual
  let res = h6.multiply_vector(sol).sub(b).norm_l2()
  assert_true(res < 1.0e-5)
}

///|
test "Vandermonde Polynomial Interpolation Matrix N=5" {
  let x = [0.0, 1.0, 2.0, 3.0, 4.0]
  let v_mat = generate_vandermonde_matrix(x)
  assert_true(v_mat.get(2, 0) == 1.0)
  assert_true(v_mat.get(2, 1) == 2.0)
  assert_true(v_mat.get(2, 2) == 4.0)
  assert_true(v_mat.get(2, 3) == 8.0)
  assert_true(v_mat.get(2, 4) == 16.0)

  let lu = LuDecomposition::decompose(v_mat)
  let det = lu.det()
  assert_true(det != 0.0) // Non-singular
}

///|
test "Toeplitz Autocorrelation Matrix Factorization N=8" {
  let r = [1.0, 0.5, 0.25, 0.125, 0.0625, 0.03125, 0.015625, 0.0078125]
  let t_mat = generate_toeplitz_matrix(r)
  assert_true(t_mat.num_rows() == 8)
  assert_true(t_mat.get(0, 0) == 1.0)
  assert_true(t_mat.get(0, 1) == 0.5)
  assert_true(t_mat.get(1, 0) == 0.5)

  let b = Vector::zeros(8)
  b.set(0, 1.0)

  let lu = LuDecomposition::decompose(t_mat)
  let sol = lu.solve(b)
  assert_true(sol.length() == 8)
}

///|
test "2D 5-Point Laplacian Poisson Solver Grid (20x20 = 400 nodes)" {
  let m = 20
  let csr = generate_laplacian_2d_csr(m)
  assert_true(csr.rows == 400)
  assert_true(csr.cols == 400)

  let rhs = Vector::zeros(400)
  for i in 0..<400 {
    rhs.set(i, 1.0)
  }

  let bicg = bicgstab_solve(csr, rhs, 200, 1.0e-6)
  assert_true(bicg.converged)
  assert_true(bicg.solution.length() == 400)
}
