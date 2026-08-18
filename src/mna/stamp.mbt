// Modified Nodal Analysis - Matrix Stamping Engine
// MoonBit Circuit Solver Engine

/// Helper to safely stamp value into MNA matrix A.
pub fn stamp_matrix_entry(a_mat : @linalg.Matrix, r : Int, c : Int, val : Double) -> Unit {
  if r >= 0 && c >= 0 {
    a_mat.add_to_element(r, c, val)
  }
}

/// Helper to safely stamp value into RHS vector z.
pub fn stamp_vector_entry(z_vec : @linalg.Vector, r : Int, val : Double) -> Unit {
  if r >= 0 {
    let curr = z_vec.get(r)
    z_vec.set(r, curr + val)
  }
}

/// Stamps a resistor R into MNA matrix A.
pub fn stamp_resistor(a_mat : @linalg.Matrix, n1 : Int, n2 : Int, r_val : Double) -> Unit {
  if r_val <= 0.0 {
    abort("Resistor value must be positive")
  }
  let g = 1.0 / r_val
  stamp_matrix_entry(a_mat, n1, n1, g)
  stamp_matrix_entry(a_mat, n2, n2, g)
  stamp_matrix_entry(a_mat, n1, n2, -g)
  stamp_matrix_entry(a_mat, n2, n1, -g)
}

/// Stamps an independent voltage source V into MNA matrix A and RHS vector z.
pub fn stamp_vsource(a_mat : @linalg.Matrix, z_vec : @linalg.Vector, n1 : Int, n2 : Int, aux_idx : Int, v_val : Double) -> Unit {
  stamp_matrix_entry(a_mat, n1, aux_idx, 1.0)
  stamp_matrix_entry(a_mat, n2, aux_idx, -1.0)
  stamp_matrix_entry(a_mat, aux_idx, n1, 1.0)
  stamp_matrix_entry(a_mat, aux_idx, n2, -1.0)
  stamp_vector_entry(z_vec, aux_idx, v_val)
}

/// Stamps an independent current source I into RHS vector z.
pub fn stamp_isource(z_vec : @linalg.Vector, n1 : Int, n2 : Int, i_val : Double) -> Unit {
  stamp_vector_entry(z_vec, n1, -i_val)
  stamp_vector_entry(z_vec, n2, i_val)
}

/// Stamps Voltage-Controlled Voltage Source (VCVS / E element).
pub fn stamp_vcvs(a_mat : @linalg.Matrix, n1 : Int, n2 : Int, nc1 : Int, nc2 : Int, aux_idx : Int, gain : Double) -> Unit {
  stamp_matrix_entry(a_mat, n1, aux_idx, 1.0)
  stamp_matrix_entry(a_mat, n2, aux_idx, -1.0)
  stamp_matrix_entry(a_mat, aux_idx, n1, 1.0)
  stamp_matrix_entry(a_mat, aux_idx, n2, -1.0)
  stamp_matrix_entry(a_mat, aux_idx, nc1, -gain)
  stamp_matrix_entry(a_mat, aux_idx, nc2, gain)
}

/// Stamps Voltage-Controlled Current Source (VCCS / G element).
pub fn stamp_vccs(a_mat : @linalg.Matrix, n1 : Int, n2 : Int, nc1 : Int, nc2 : Int, gm : Double) -> Unit {
  stamp_matrix_entry(a_mat, n1, nc1, gm)
  stamp_matrix_entry(a_mat, n1, nc2, -gm)
  stamp_matrix_entry(a_mat, n2, nc1, -gm)
  stamp_matrix_entry(a_mat, n2, nc2, gm)
}

/// Stamps ideal or finite gain Operational Amplifier (OpAmp).
pub fn stamp_opamp(a_mat : @linalg.Matrix, in_pos : Int, in_neg : Int, out : Int, aux_idx : Int, gain : Double) -> Unit {
  // E-type representation or ideal OpAmp constraint
  stamp_matrix_entry(a_mat, out, aux_idx, 1.0)
  stamp_matrix_entry(a_mat, aux_idx, out, 1.0)
  stamp_matrix_entry(a_mat, aux_idx, in_pos, -gain)
  stamp_matrix_entry(a_mat, aux_idx, in_neg, gain)
}
