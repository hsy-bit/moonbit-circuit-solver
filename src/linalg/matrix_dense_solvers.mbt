// Linear Algebra Module - Gauss-Jordan Elimination & Cramer Solvers
// MoonBit Circuit Solver Engine

///|
/// Solves 3x3 linear system A * x = b using Cramer's Rule.
pub fn cramer_solve_3x3(a_mat : Matrix, b_vec : Vector) -> Vector? {
  if a_mat.num_rows() != 3 || a_mat.num_cols() != 3 || b_vec.length() != 3 {
    return None
  }

  let det_a = a_mat.det_3x3()
  if det_a == 0.0 {
    return None
  }

  let a_x = a_mat.copy()
  let a_y = a_mat.copy()
  let a_z = a_mat.copy()

  for i = 0; i < 3; i = i + 1 {
    a_x.set(i, 0, b_vec.get(i))
    a_y.set(i, 1, b_vec.get(i))
    a_z.set(i, 2, b_vec.get(i))
  }

  let x = a_x.det_3x3() / det_a
  let y = a_y.det_3x3() / det_a
  let z = a_z.det_3x3() / det_a

  Some(Vector::from_array([x, y, z]))
}

///|
/// Computes determinant of 3x3 matrix.
pub fn Matrix::det_3x3(self : Matrix) -> Double {
  if self.num_rows() != 3 || self.num_cols() != 3 {
    return 0.0
  }
  let a00 = self.get(0, 0)
  let a01 = self.get(0, 1)
  let a02 = self.get(0, 2)

  let a10 = self.get(1, 0)
  let a11 = self.get(1, 1)
  let a12 = self.get(1, 2)

  let a20 = self.get(2, 0)
  let a21 = self.get(2, 1)
  let a22 = self.get(2, 2)

  a00 * (a11 * a22 - a12 * a21) -
  a01 * (a10 * a22 - a12 * a20) +
  a02 * (a10 * a21 - a11 * a20)
}
