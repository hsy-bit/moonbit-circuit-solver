// Linear Algebra Module - LU Decomposition & Triangular Solvers
// MoonBit Circuit Solver Engine

/// Represents the LU Decomposition result P * A = L * U.
pub struct LuDecomposition {
  n : Int
  lu_mat : Matrix
  pivots : Array[Int]
  sign : Int
} derive(Debug, Eq)

/// Decomposes matrix A into P * A = L * U.
pub fn LuDecomposition::decompose(a_mat : Matrix) -> LuDecomposition {
  let n = a_mat.num_rows()
  if n != a_mat.num_cols() {
    abort("LU decomposition requires square matrix")
  }
  let lu_mat = a_mat.copy()
  let pivots = Array::make(n, 0)
  for i = 0; i < n; i = i + 1 {
    pivots[i] = i
  }
  let mut sign = 1

  for k = 0; k < n; k = k + 1 {
    // Pivot selection
    let mut max_row = k
    let mut max_val = lu_mat.get(k, k)
    let mut abs_max = if max_val < 0.0 { -max_val } else { max_val }

    for r = k + 1; r < n; r = r + 1 {
      let v = lu_mat.get(r, k)
      let abs_v = if v < 0.0 { -v } else { v }
      if abs_v > abs_max {
        abs_max = abs_v
        max_row = r
      }
    }

    if max_row != k {
      lu_mat.swap_rows(k, max_row)
      let tmp = pivots[k]
      pivots[k] = pivots[max_row]
      pivots[max_row] = tmp
      sign = -sign
    }

    let pivot_val = lu_mat.get(k, k)
    if pivot_val != 0.0 {
      for r = k + 1; r < n; r = r + 1 {
        let factor = lu_mat.get(r, k) / pivot_val
        lu_mat.set(r, k, factor)
        for c = k + 1; c < n; c = c + 1 {
          let v = lu_mat.get(r, c) - factor * lu_mat.get(k, c)
          lu_mat.set(r, c, v)
        }
      }
    }
  }

  LuDecomposition::{ n, lu_mat, pivots, sign }
}

/// Solves L * y = P * b (forward substitution).
pub fn LuDecomposition::solve_lower(self : LuDecomposition, b_vec : Vector) -> Vector {
  let y = Array::make(self.n, 0.0)
  for i = 0; i < self.n; i = i + 1 {
    let perm_idx = self.pivots[i]
    let mut sum = b_vec.get(perm_idx)
    for j = 0; j < i; j = j + 1 {
      sum = sum - self.lu_mat.get(i, j) * y[j]
    }
    y[i] = sum
  }
  Vector::from_array(y)
}

/// Solves U * x = y (backward substitution).
pub fn LuDecomposition::solve_upper(self : LuDecomposition, y_vec : Vector) -> Vector {
  let x = Array::make(self.n, 0.0)
  for i = self.n - 1; i >= 0; i = i - 1 {
    let mut sum = y_vec.get(i)
    for j = i + 1; j < self.n; j = j + 1 {
      sum = sum - self.lu_mat.get(i, j) * x[j]
    }
    let diag = self.lu_mat.get(i, i)
    if diag == 0.0 {
      abort("LU Upper matrix is singular")
    }
    x[i] = sum / diag
  }
  Vector::from_array(x)
}

/// Solves A * x = b using pre-computed LU decomposition.
pub fn LuDecomposition::solve(self : LuDecomposition, b_vec : Vector) -> Vector {
  let y = self.solve_lower(b_vec)
  self.solve_upper(y)
}
