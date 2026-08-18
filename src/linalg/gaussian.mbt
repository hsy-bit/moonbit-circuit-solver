// Linear Algebra Module - Direct Solvers (Gaussian Elimination)
// MoonBit Circuit Solver Engine

///|
/// Result of linear system solution.
pub enum SolverResult {
  Success(Vector)
  SingularMatrix(String)
} derive(Debug, Eq)

///|
/// Solves dense linear system A * x = b using Gaussian elimination with partial pivoting.
pub fn gaussian_solve(a_mat : Matrix, b_vec : Vector) -> SolverResult {
  let n = a_mat.num_rows()
  if n != a_mat.num_cols() || n != b_vec.length() {
    return SingularMatrix("Dimension mismatch in linear system solve")
  }

  // Work on local augmented copy
  let aug = a_mat.copy()
  let x_data = Array::make(n, 0.0)
  for i = 0; i < n; i = i + 1 {
    x_data[i] = b_vec.get(i)
  }

  // Forward elimination
  for k = 0; k < n; k = k + 1 {
    // Find pivot row
    let mut max_row = k
    let max_val = aug.get(k, k)
    let abs_max_val = if max_val < 0.0 { -max_val } else { max_val }
    let mut max_abs = abs_max_val

    for i = k + 1; i < n; i = i + 1 {
      let v = aug.get(i, k)
      let abs_v = if v < 0.0 { -v } else { v }
      if abs_v > max_abs {
        max_abs = abs_v
        max_row = i
      }
    }

    if max_abs < 0.00000000000001 {
      return SingularMatrix("Matrix is singular or near-singular at pivot \{k}")
    }

    // Swap pivot row if needed
    if max_row != k {
      aug.swap_rows(k, max_row)
      let tmp = x_data[k]
      x_data[k] = x_data[max_row]
      x_data[max_row] = tmp
    }

    // Eliminate column below pivot
    let pivot = aug.get(k, k)
    for i = k + 1; i < n; i = i + 1 {
      let factor = aug.get(i, k) / pivot
      aug.set(i, k, 0.0)
      for j = k + 1; j < n; j = j + 1 {
        let v = aug.get(i, j) - factor * aug.get(k, j)
        aug.set(i, j, v)
      }
      x_data[i] = x_data[i] - factor * x_data[k]
    }
  }

  // Back substitution
  let x = Array::make(n, 0.0)
  for i = n - 1; i >= 0; i = i - 1 {
    let mut sum = x_data[i]
    for j = i + 1; j < n; j = j + 1 {
      sum = sum - aug.get(i, j) * x[j]
    }
    let diag = aug.get(i, i)
    if diag < 0.00000000000001 && diag > -0.00000000000001 {
      return SingularMatrix("Zero diagonal during back substitution at \{i}")
    }
    x[i] = sum / diag
  }

  Success(Vector::from_array(x))
}

///|
/// Inverts a square matrix using Gauss-Jordan elimination.
pub fn matrix_inverse(a_mat : Matrix) -> Matrix {
  let n = a_mat.num_rows()
  if n != a_mat.num_cols() {
    abort("Cannot invert non-square matrix")
  }
  let aug = Matrix::zeros(n, 2 * n)
  for r = 0; r < n; r = r + 1 {
    for c = 0; c < n; c = c + 1 {
      aug.set(r, c, a_mat.get(r, c))
    }
    aug.set(r, n + r, 1.0)
  }

  for k = 0; k < n; k = k + 1 {
    let mut pivot_row = k
    let max_val = aug.get(k, k)
    let mut abs_max = if max_val < 0.0 { -max_val } else { max_val }

    for r = k + 1; r < n; r = r + 1 {
      let v = aug.get(r, k)
      let abs_v = if v < 0.0 { -v } else { v }
      if abs_v > abs_max {
        abs_max = abs_v
        pivot_row = r
      }
    }

    if abs_max < 0.000000000000001 {
      abort("Matrix is singular, cannot invert")
    }

    if pivot_row != k {
      aug.swap_rows(k, pivot_row)
    }

    let p_val = aug.get(k, k)
    aug.scale_row(k, 1.0 / p_val)

    for r = 0; r < n; r = r + 1 {
      if r != k {
        let factor = aug.get(r, k)
        aug.add_row_multiple(r, k, -factor)
      }
    }
  }

  let inv = Matrix::zeros(n, n)
  for r = 0; r < n; r = r + 1 {
    for c = 0; c < n; c = c + 1 {
      inv.set(r, c, aug.get(r, n + c))
    }
  }
  inv
}

///|
/// Computes determinant of square matrix via LU reduction.
pub fn determinant(a_mat : Matrix) -> Double {
  let n = a_mat.num_rows()
  if n != a_mat.num_cols() {
    abort("Determinant requires square matrix")
  }
  let mat = a_mat.copy()
  let mut det = 1.0
  let mut swap_count = 0

  for k = 0; k < n; k = k + 1 {
    let mut max_r = k
    let max_v = mat.get(k, k)
    let mut abs_max = if max_v < 0.0 { -max_v } else { max_v }

    for r = k + 1; r < n; r = r + 1 {
      let v = mat.get(r, k)
      let abs_v = if v < 0.0 { -v } else { v }
      if abs_v > abs_max {
        abs_max = abs_v
        max_r = r
      }
    }

    if abs_max < 0.000000000000001 {
      return 0.0
    }

    if max_r != k {
      mat.swap_rows(k, max_r)
      swap_count = swap_count + 1
    }

    let pivot = mat.get(k, k)
    det = det * pivot

    for r = k + 1; r < n; r = r + 1 {
      let factor = mat.get(r, k) / pivot
      mat.set(r, k, 0.0)
      for c = k + 1; c < n; c = c + 1 {
        let v = mat.get(r, c) - factor * mat.get(k, c)
        mat.set(r, c, v)
      }
    }
  }

  if swap_count % 2 == 1 {
    det = -det
  }
  det
}
