// RK4 & Cramer Solvers Integration Unit Tests
// MoonBit Circuit Solver Engine

///|
test "Cramer 3x3 linear system solver test" {
  let a_mat = @linalg.Matrix::zeros(3, 3)
  a_mat.set(0, 0, 1.0)
  a_mat.set(0, 1, 2.0)
  a_mat.set(0, 2, 3.0)

  a_mat.set(1, 0, 0.0)
  a_mat.set(1, 1, 1.0)
  a_mat.set(1, 2, 4.0)

  a_mat.set(2, 0, 5.0)
  a_mat.set(2, 1, 6.0)
  a_mat.set(2, 2, 0.0)

  let b_vec = @linalg.Vector::from_array([14.0, 11.0, 17.0])
  let res = @linalg.cramer_solve_3x3(a_mat, b_vec)
  let is_found = match res {
    Some(_) => true
    None => false
  }
  assert_true(is_found)
}

///|
test "RK4 transient solver integration test" {
  let netlist_str =
    #|* RC RK4 Step Response
    #|V1 in 0 5.0
    #|R1 in out 1k
    #|C1 out 0 1u
    #|.tran 10u 1m
    #|.end

  let netlist = @spice.parse_spice_netlist(netlist_str)
  let tran_res = @transient.solve_transient_rk4(netlist, 0.00001, 0.001)
  assert_true(tran_res.steps.length() > 5)
}
