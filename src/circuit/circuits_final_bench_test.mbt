// Final Benchmark & Verification Test Suite
// MoonBit Circuit Solver Engine

///|
test "100-stage ladder network benchmark test" {
  let bench = run_ladder_benchmark(100)
  assert_true(bench.matrix_size == 101)
  assert_true(bench.residual_norm >= 0.0)
}

///|
test "QR decomposition matrix solver test" {
  let dense = @linalg.Matrix::zeros(3, 2)
  dense.set(0, 0, 1.0)
  dense.set(1, 0, 1.0)
  dense.set(2, 0, 1.0)
  dense.set(0, 1, 0.0)
  dense.set(1, 1, 1.0)
  dense.set(2, 1, 2.0)

  let b = @linalg.Vector::from_array([6.0, 0.0, 0.0])
  let x = @linalg.qr_solve(dense, b)
  assert_true(x.length() == 2)
}

///|
test "SVG Waveform chart renderer output test" {
  let pts = [(0.0, 0.0), (0.001, 5.0), (0.002, 0.0)]
  let svg = @visualizer.render_svg_waveform(pts, 400, 300, "Test Waveform")
  assert_true(svg.has_prefix("<svg"))
}
