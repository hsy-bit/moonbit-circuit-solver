// Sparse Cholesky Integration Unit Tests
// MoonBit Circuit Solver Engine

///|
test "Sparse Cholesky linear solver test" {
  let dense = @linalg.Matrix::zeros(2, 2)
  dense.set(0, 0, 4.0)
  dense.set(0, 1, 1.0)
  dense.set(1, 0, 1.0)
  dense.set(1, 1, 3.0)

  let csr = @linalg.CsrMatrix::from_dense(dense)
  let b_vec = @linalg.Vector::from_array([5.0, 4.0])

  let sol = @linalg.sparse_cholesky_solve(csr, b_vec)
  let is_ok = match sol {
    Some(v) => (v.get(0) - 1.0).abs() < 0.1
    None => false
  }
  assert_true(is_ok)
}

///|
test "Cholesky Decomposition matrix solver test" {
  let dense = @linalg.Matrix::zeros(3, 3)
  dense.set(0, 0, 25.0)
  dense.set(0, 1, 15.0)
  dense.set(0, 2, -5.0)

  dense.set(1, 0, 15.0)
  dense.set(1, 1, 18.0)
  dense.set(1, 2, 0.0)

  dense.set(2, 0, -5.0)
  dense.set(2, 1, 0.0)
  dense.set(2, 2, 11.0)

  let b = @linalg.Vector::from_array([35.0, 33.0, 6.0])
  let chol = @linalg.CholeskyDecomposition::decompose(dense)
  let x = chol.solve(b)
  assert_true(x.length() == 3)
}
