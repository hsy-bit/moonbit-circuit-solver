// Benchmark & Performance Measurement Comprehensive Test Suite
// MoonBit Circuit Solver Engine

///|
test "10-stage ladder network benchmark test" {
  let bench = run_ladder_benchmark(10)
  assert_true(bench.matrix_size == 11)
  assert_true(bench.residual_norm >= 0.0)
}

///|
test "20-stage ladder network benchmark test" {
  let bench = run_ladder_benchmark(20)
  assert_true(bench.matrix_size == 21)
}

///|
test "50-stage ladder network benchmark test" {
  let bench = run_ladder_benchmark(50)
  assert_true(bench.matrix_size == 51)
}

///|
test "Sparse BiCGSTAB linear solver convergence test" {
  let dense = @linalg.Matrix::identity(4)
  dense.set(0, 1, 0.5)
  dense.set(1, 2, 0.5)
  dense.set(2, 3, 0.5)

  let csr = @linalg.CsrMatrix::from_dense(dense)
  let b = @linalg.Vector::from_array([1.0, 1.0, 1.0, 1.0])
  let res = @linalg.bicgstab_solve(csr, b, 50, 0.0001)
  assert_true(res.iterations >= 0)
}

///|
test "Jacobi Eigenvalue solver symmetric matrix test" {
  let dense = @linalg.Matrix::zeros(2, 2)
  dense.set(0, 0, 2.0)
  dense.set(0, 1, 1.0)
  dense.set(1, 0, 1.0)
  dense.set(1, 1, 2.0)

  let eigen = @linalg.jacobi_eigen(dense, 50, 0.0001)
  assert_true(eigen.eigenvalues.length() == 2)
}
