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
test "Complex number basic arithmetic and polar conversions" {
  let z1 = Complex::new(3.0, 4.0)
  let z2 = Complex::new(1.0, -2.0)

  // Modulus and phase
  assert_true((z1.abs() - 5.0).abs() < 1.0e-12)
  assert_true((z1.abs_sq() - 25.0).abs() < 1.0e-12)

  // Addition: (3+4i) + (1-2i) = 4 + 2i
  let z_add = z1.add(z2)
  assert_true((z_add.re - 4.0).abs() < 1.0e-12)
  assert_true((z_add.im - 2.0).abs() < 1.0e-12)

  // Subtraction: (3+4i) - (1-2i) = 2 + 6i
  let z_sub = z1.sub(z2)
  assert_true((z_sub.re - 2.0).abs() < 1.0e-12)
  assert_true((z_sub.im - 6.0).abs() < 1.0e-12)

  // Multiplication: (3+4i)(1-2i) = 3 - 6i + 4i + 8 = 11 - 2i
  let z_mul = z1.mul(z2)
  assert_true((z_mul.re - 11.0).abs() < 1.0e-12)
  assert_true((z_mul.im - -2.0).abs() < 1.0e-12)

  // Division: z1 / z2 * z2 == z1
  let z_div = z1.div(z2)
  let z_back = z_div.mul(z2)
  assert_true((z_back.re - z1.re).abs() < 1.0e-12)
  assert_true((z_back.im - z1.im).abs() < 1.0e-12)

  // Polar conversion identity: exp(i * pi) = -1 + 0i
  let z_euler = Complex::from_polar(1.0, @math.PI)
  assert_true((z_euler.re - -1.0).abs() < 1.0e-12)
  assert_true(z_euler.im.abs() < 1.0e-12)
}

///|
test "ComplexMatrix and ComplexLU decomposition solver" {
  // 3x3 Complex Linear System A * x = b
  let mat = ComplexMatrix::zeros(3, 3)
  mat.set(0, 0, Complex::new(4.0, 1.0))
  mat.set(0, 1, Complex::new(1.0, -1.0))
  mat.set(0, 2, Complex::new(0.0, 2.0))

  mat.set(1, 0, Complex::new(1.0, 1.0))
  mat.set(1, 1, Complex::new(5.0, 0.0))
  mat.set(1, 2, Complex::new(-1.0, 1.0))

  mat.set(2, 0, Complex::new(0.0, -2.0))
  mat.set(2, 1, Complex::new(-1.0, -1.0))
  mat.set(2, 2, Complex::new(6.0, 3.0))

  let b = ComplexVector::zeros(3)
  b.set(0, Complex::new(1.0, 2.0))
  b.set(1, Complex::new(-2.0, 0.0))
  b.set(2, Complex::new(4.0, -1.0))

  let lu = ComplexLuDecomposition::decompose(mat)
  let x = lu.solve(b)

  // Verify A * x == b residual norm
  let ax = mat.multiply_vector(x)
  let diff = ax.sub(b)
  let residual = diff.norm_l2()
  assert_true(residual < 1.0e-10)

  // Verify complex matrix inversion A * inv(A) == I
  let inv_a = complex_matrix_inverse(mat)
  let ident_test = mat.multiply(inv_a)
  for r = 0; r < 3; r = r + 1 {
    for c = 0; c < 3; c = c + 1 {
      let expected_re = if r == c { 1.0 } else { 0.0 }
      let actual = ident_test.get(r, c)
      assert_true((actual.re - expected_re).abs() < 1.0e-10)
      assert_true(actual.im.abs() < 1.0e-10)
    }
  }
}

///|
test "Sparse LU Markowitz decomposition solver" {
  // Construct 5x5 sparse tridiagonal matrix
  let n = 5
  let mat = Matrix::zeros(n, n)
  for i in 0..<n {
    mat.set(i, i, 4.0)
    if i > 0 {
      mat.set(i, i - 1, -1.0)
    }
    if i + 1 < n {
      mat.set(i, i + 1, -1.0)
    }
  }

  let b = Vector::zeros(n)
  for i in 0..<n {
    b.set(i, (i + 1).to_double())
  }

  let sparse_lu = factorize_sparse_lu(mat, 0.1)
  let x = sparse_lu.solve(b)

  let ax = mat.multiply_vector(x)
  let res = ax.sub(b).norm_l2()
  assert_true(res < 1.0e-10)
  assert_true(sparse_lu.is_valid)
}

///|
test "Singular Value Decomposition (SVD) and Rank" {
  // 4x3 matrix with rank 2
  let mat = Matrix::zeros(4, 3)
  mat.set(0, 0, 1.0)
  mat.set(0, 1, 2.0)
  mat.set(0, 2, 3.0)
  mat.set(1, 0, 2.0)
  mat.set(1, 1, 4.0)
  mat.set(1, 2, 6.0) // Row 1 = 2 * Row 0
  mat.set(2, 0, 0.0)
  mat.set(2, 1, 1.0)
  mat.set(2, 2, 1.0)
  mat.set(3, 0, 1.0)
  mat.set(3, 1, 0.0)
  mat.set(3, 2, 1.0)

  let svd = compute_svd(mat, 60, 1.0e-12)
  assert_true(svd.rank >= 2)
  assert_true(svd.s.get(0) >= svd.s.get(1))
  assert_true(svd.s.get(1) >= svd.s.get(2))

  // Test SVD pseudoinverse
  let pinv = svd_pseudo_inverse(mat, 1.0e-10)
  assert_true(pinv.num_rows() == 3)
  assert_true(pinv.num_cols() == 4)
}

///|
test "Sparse QR Givens least-squares solver" {
  // Overdetermined 4x2 matrix A * x = b
  let mat = Matrix::zeros(4, 2)
  mat.set(0, 0, 1.0)
  mat.set(0, 1, 1.0)
  mat.set(1, 0, 1.0)
  mat.set(1, 1, 2.0)
  mat.set(2, 0, 1.0)
  mat.set(2, 1, 3.0)
  mat.set(3, 0, 1.0)
  mat.set(3, 1, 4.0)

  let b = Vector::zeros(4)
  b.set(0, 2.0)
  b.set(1, 3.0)
  b.set(2, 5.0)
  b.set(3, 6.0)

  let qr = sparse_qr_decompose(mat)
  let x_ls = qr.solve_least_squares(b)

  // Linear regression fit y = a + b*x: slope approx 1.4, intercept approx 0.5
  assert_true((x_ls.get(0) - 0.5).abs() < 0.2)
  assert_true((x_ls.get(1) - 1.4).abs() < 0.2)
}

///|
test "Matrix Market (.mtx) serialization and roundtrip parsing" {
  let builder = SparseBuilder::new(3, 3)
  builder.add_entry(0, 0, 10.5)
  builder.add_entry(0, 2, -2.1)
  builder.add_entry(1, 1, 4.0)
  builder.add_entry(2, 0, 1.5)
  builder.add_entry(2, 2, 7.8)

  let csr_orig = builder.to_csr()
  let mtx_str = serialize_matrix_market(csr_orig)
  let csr_parsed = parse_matrix_market(mtx_str)

  assert_true(csr_parsed.rows == 3)
  assert_true(csr_parsed.cols == 3)
  assert_true(csr_parsed.nnz() == 5)
  assert_true((csr_parsed.get(0, 0) - 10.5).abs() < 1.0e-12)
  assert_true((csr_parsed.get(0, 2) - -2.1).abs() < 1.0e-12)
  assert_true((csr_parsed.get(2, 2) - 7.8).abs() < 1.0e-12)
}
