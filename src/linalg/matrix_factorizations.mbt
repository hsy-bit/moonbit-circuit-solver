// Linear Algebra Module - Matrix Factorizations & Moore-Penrose Pseudo-Inverse
// MoonBit Circuit Solver Engine

///|
/// Inverts a square matrix using LU decomposition with partial pivoting.
pub fn compute_matrix_inverse(a_mat : Matrix) -> Matrix? {
  let n = a_mat.num_rows()
  if n != a_mat.num_cols() {
    return None
  }

  let lu = LuDecomposition::decompose(a_mat)
  if lu.det() == 0.0 {
    return None
  }

  let inv = Matrix::zeros(n, n)
  for col = 0; col < n; col = col + 1 {
    let e = Array::make(n, 0.0)
    e[col] = 1.0
    let col_sol = lu.solve(Vector::from_array(e))
    for row = 0; row < n; row = row + 1 {
      inv.set(row, col, col_sol.get(row))
    }
  }

  Some(inv)
}

///|
/// Result of Moore-Penrose Pseudo-Inverse calculation A^+.
pub struct PseudoInverseResult {
  pinv_mat : Matrix
  condition_number : Double
} derive(Debug, Eq)

///|
/// Computes Moore-Penrose Pseudo-Inverse matrix A^+ = (A^T * A)^(-1) * A^T for full column rank matrix A.
pub fn compute_pseudo_inverse(a_mat : Matrix) -> PseudoInverseResult {
  let a_t = a_mat.transpose()
  let ata = a_t.multiply(a_mat)

  // Invert (A^T * A)
  let ata_inv = match compute_matrix_inverse(ata) {
    Some(inv) => inv
    None => Matrix::identity(a_mat.num_cols())
  }

  let pinv = ata_inv.multiply(a_t)
  let cond = ata.norm_frobenius() * ata_inv.norm_frobenius()

  PseudoInverseResult::{ pinv_mat: pinv, condition_number: cond }
}

///|
/// Solves linear system using Moore-Penrose Pseudo-Inverse: x = A^+ * b.
pub fn pinv_solve(a_mat : Matrix, b_vec : Vector) -> Vector {
  let res = compute_pseudo_inverse(a_mat)
  res.pinv_mat.multiply_vector(b_vec)
}
