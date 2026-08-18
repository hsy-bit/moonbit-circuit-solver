// Vector Signal Processing & Stats Integration Test Suite
// MoonBit Circuit Solver Engine

///|
test "Vector Signal Statistics computation test" {
  let v = @linalg.Vector::from_array([1.0, 2.0, 3.0, 4.0, 5.0])
  let stats = @linalg.VectorStats::compute(v)
  assert_eq(stats.mean, 3.0)
  assert_eq(stats.min_val, 1.0)
  assert_eq(stats.max_val, 5.0)
  assert_eq(stats.peak_to_peak, 4.0)
}

///|
test "Moving Average Filter smoothing test" {
  let v = @linalg.Vector::from_array([1.0, 10.0, 1.0, 10.0, 1.0])
  let smoothed = @linalg.moving_average_filter(v, 3)
  assert_true(smoothed.length() == 5)
  assert_true(smoothed.get(1) < 10.0)
}

///|
test "Sparse Matrix CSR conversion and vector product test" {
  let dense = @linalg.Matrix::zeros(3, 3)
  dense.set(0, 0, 10.0)
  dense.set(1, 1, 20.0)
  dense.set(2, 2, 30.0)

  let csr = @linalg.CsrMatrix::from_dense(dense)
  let x = @linalg.Vector::from_array([1.0, 1.0, 1.0])
  let y = csr.multiply_vector(x)
  assert_eq(y.get(0), 10.0)
  assert_eq(y.get(1), 20.0)
  assert_eq(y.get(2), 30.0)
}
