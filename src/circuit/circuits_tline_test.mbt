// Transmission Line & ILU Unit Tests
// MoonBit Circuit Solver Engine

///|
test "Transmission Line Lumped Cascade synthesis test" {
  let line = @mna.RlgcTransmissionLine::new(
    0.1, 0.000001, 0.000001, 0.0000000001, 1.0, 5,
  )
  let comps = @mna.synthesize_tline_lumped_cascade(line, "in", "out", "0")
  assert_true(comps.length() >= 5)
}

///|
test "ILU0 Preconditioner solve test" {
  let l_mat = @linalg.Matrix::identity(3)
  let u_mat = @linalg.Matrix::identity(3)
  let ilu = @linalg.Ilu0Preconditioner::new(l_mat, u_mat)
  let r = @linalg.Vector::from_array([1.0, 2.0, 3.0])
  let y = ilu.apply(r)
  assert_true(y.length() == 3)
}
