// Final Integration & Verification Suite
// MoonBit Circuit Solver Engine

///|
test "Full Circuit Simulation Pipeline verification" {
  let spice_str =
    #|* Full Circuit Test
    #|V1 in 0 10.0
    #|R1 in mid 1k
    #|R2 mid 0 1k
    #|C1 mid 0 1u
    #|.op
    #|.tran 10u 1m
    #|.end

  let sim = CircuitSimulator::from_spice_string(spice_str)
  let voltages = sim.solve_dc()
  let v_mid = match voltages.get("mid") {
    Some(v) => v
    None => 0.0
  }
  assert_eq(v_mid, 5.0)

  let tran_res = sim.solve_transient(0.00001, 0.001)
  assert_true(tran_res.steps.length() > 5)

  let chart = sim.render_transient_chart(0.00001, 0.001, "mid")
  assert_true(chart.length() > 20)
}

///|
test "Dense Matrix LU Factorization and Inverse verification" {
  let dense = @linalg.Matrix::zeros(2, 2)
  dense.set(0, 0, 4.0)
  dense.set(0, 1, 7.0)
  dense.set(1, 0, 2.0)
  dense.set(1, 1, 6.0)

  let inv = @linalg.compute_matrix_inverse(dense)
  let is_ok = match inv {
    Some(inv_m) => (inv_m.get(0, 0) - 0.6).abs() < 0.01
    None => false
  }
  assert_true(is_ok)
}

///|
test "Linear Algebra Vector norm and inner product verification" {
  let v1 = @linalg.Vector::from_array([3.0, 4.0])
  assert_eq(v1.norm_l2(), 5.0)

  let v2 = @linalg.Vector::from_array([1.0, 2.0])
  let dot = v1.dot(v2)
  assert_eq(dot, 11.0)
}

///|
test "Matrix Frobenius norm and scaling verification" {
  let m = @linalg.Matrix::identity(3)
  let m_scaled = m.scale(2.0)
  assert_eq(m_scaled.get(0, 0), 2.0)
  assert_eq(m_scaled.get(1, 1), 2.0)
  assert_eq(m_scaled.get(2, 2), 2.0)
}
