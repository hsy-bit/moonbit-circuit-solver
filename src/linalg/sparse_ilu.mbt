// Linear Algebra Module - Incomplete LU (ILU0) Preconditioner
// MoonBit Circuit Solver Engine

///|
/// Result of ILU0 Preconditioner decomposition.
pub struct Ilu0Preconditioner {
  l_mat : Matrix
  u_mat : Matrix
} derive(Debug, Eq)

///|
/// Creates a new Ilu0Preconditioner.
pub fn Ilu0Preconditioner::new(
  l_mat : Matrix,
  u_mat : Matrix,
) -> Ilu0Preconditioner {
  Ilu0Preconditioner::{ l_mat, u_mat }
}

///|
/// Solves preconditioned system M * y = r (L * U * y = r).
pub fn Ilu0Preconditioner::apply(
  self : Ilu0Preconditioner,
  r_vec : Vector,
) -> Vector {
  let n = r_vec.length()
  let y = Array::make(n, 0.0)

  // Forward substitution L * z = r
  for i = 0; i < n; i = i + 1 {
    let mut sum = r_vec.get(i)
    for j = 0; j < i; j = j + 1 {
      sum = sum - self.l_mat.get(i, j) * y[j]
    }
    let diag = self.l_mat.get(i, i)
    y[i] = if diag != 0.0 { sum / diag } else { sum }
  }

  // Backward substitution U * x = z
  let x = Array::make(n, 0.0)
  for i = n - 1; i >= 0; i = i - 1 {
    let mut sum = y[i]
    for j = i + 1; j < n; j = j + 1 {
      sum = sum - self.u_mat.get(i, j) * x[j]
    }
    let diag = self.u_mat.get(i, i)
    x[i] = if diag != 0.0 { sum / diag } else { sum }
  }

  Vector::from_array(x)
}
